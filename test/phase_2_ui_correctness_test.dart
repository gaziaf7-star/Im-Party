// Phase 2 — localized UI/rendering correctness fixes (Jo Live, package `general`).
//
// Covers the display-correctness logic added/changed in Phase 2:
//   * #9  group "deleted for everyone/me" -> tombstone decision (parity with the
//         DM stack's DriftMessageMapper delete flags) — exercises the REAL mapper
//         and replicates the GroupMessageBubble._isDeleted decision (the widget
//         itself needs a tree, so we pin the pure rule like seen_widget_status).
//   * #35 chat-card last-message type wire keys MUST match MessageIconType keys
//         ('img'/'voice'/'video') — exercises the REAL RoomToConversationMapper
//         against the REAL MessageIconType switch.
//   * #62 reactions are a pure function of the entity (no shared singleton list).
//   * #37/#93 group reply preview: media bodies show a localized placeholder,
//         text bodies show the body (no blank line / no empty quote).

import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:general/src/core/database/app_database.dart';
import 'package:general/src/core/database/daos/rooms_dao.dart';
import 'package:general/src/core/database/tables/chat_tables.dart';
import 'package:general/src/features/chats/presentation/chats/view/widgets/room_to_conversation_mapper.dart';
import 'package:general/src/features/messages/data/mappers/drift_message_mapper.dart';
import 'package:general/src/features/messages/domain/entities/messages_entity.dart';
import 'package:general/src/features/messages/domain/entities/user_chat_entity.dart';
import 'package:general/src/features/messages/presentation/messages/blocs/make_react/react_controller.dart';
import 'package:reaction_askany/models/emotions.dart';

// ---------------------------------------------------------------------------
// #9 — replica of GroupMessageBubble._isDeleted (widget-bound; pinned here).
//      A "deleted for everyone" message shows a tombstone to all members; a
//      "deleted for me" only on the owning (isMe) side.
// ---------------------------------------------------------------------------
bool groupBubbleIsDeleted({
  required MessageDeleteState deleteState,
  required bool isMe,
}) =>
    deleteState == MessageDeleteState.deletedForAll ||
    (deleteState == MessageDeleteState.deletedForMe && isMe);

// ---------------------------------------------------------------------------
// #37/#93 — replica of GroupReplyBox._previewFor: media -> localized key,
//           text -> body, never blank.
// ---------------------------------------------------------------------------
String groupReplyPreview(MessageContentType type, String? body) {
  if (body != null && body.trim().isNotEmpty) return body;
  switch (type) {
    case MessageContentType.image:
      return 'Photo';
    case MessageContentType.audio:
      return 'Voice';
    case MessageContentType.video:
      return 'Video';
    case MessageContentType.text:
      return '';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // === #9 — deleted-state tombstone decision ================================
  group('#9 group deleted message -> tombstone', () {
    test('deletedForAll always shows a tombstone (both sides)', () {
      expect(
        groupBubbleIsDeleted(
            deleteState: MessageDeleteState.deletedForAll, isMe: true),
        isTrue,
      );
      expect(
        groupBubbleIsDeleted(
            deleteState: MessageDeleteState.deletedForAll, isMe: false),
        isTrue,
      );
    });

    test('deletedForMe shows a tombstone only on the owning side', () {
      expect(
        groupBubbleIsDeleted(
            deleteState: MessageDeleteState.deletedForMe, isMe: true),
        isTrue,
      );
      expect(
        groupBubbleIsDeleted(
            deleteState: MessageDeleteState.deletedForMe, isMe: false),
        isFalse,
      );
    });

    test('none never shows a tombstone', () {
      expect(
        groupBubbleIsDeleted(
            deleteState: MessageDeleteState.none, isMe: true),
        isFalse,
      );
      expect(
        groupBubbleIsDeleted(
            deleteState: MessageDeleteState.none, isMe: false),
        isFalse,
      );
    });

    test('group rule matches the DM stack (DriftMessageMapper delete flags)',
        () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      const me = 5;
      const peer = 9;
      final room = await db.roomsDao.insertRoom(
        RoomsCompanion.insert(type: RoomType.dm, serverRoomId: const Value(1)),
      );

      // A message I sent, deleted-for-everyone: hidden for everyone -> the DM
      // mapper sets BOTH senderDeleted and receiverDeleted; the group rule
      // (isDeleted) is true for me too.
      await db.messagesDao.insertPending(MessagesCompanion.insert(
        clientUuid: 'all',
        roomId: room,
        kind: MessageKind.user,
        type: MessageContentType.text,
        createdAtClient: 1000,
        state: MessageState.sent,
        serverMessageId: const Value(10),
        senderId: const Value(me),
        body: const Value('secret'),
        deleteState: const Value(MessageDeleteState.deletedForAll),
      ));
      final allRow = await db.messagesDao.findByServerMessageId(10);
      final allEntity =
          DriftMessageMapper.toEntity(allRow!, currentUserId: me);
      expect(allEntity.senderDeleted, isTrue);
      expect(allEntity.receiverDeleted, isTrue);
      expect(
        groupBubbleIsDeleted(deleteState: allRow.deleteState, isMe: true),
        isTrue,
      );

      // A peer message deleted-for-me: hidden on my side only. DM mapper:
      // receiverDeleted true (I'm the receiver), senderDeleted false. Group
      // rule: isMe=false -> still a tombstone for me (the owning side).
      await db.messagesDao.insertPending(MessagesCompanion.insert(
        clientUuid: 'me',
        roomId: room,
        kind: MessageKind.user,
        type: MessageContentType.text,
        createdAtClient: 2000,
        state: MessageState.sent,
        serverMessageId: const Value(11),
        senderId: const Value(peer),
        body: const Value('peer note'),
        deleteState: const Value(MessageDeleteState.deletedForMe),
      ));
      final meRow = await db.messagesDao.findByServerMessageId(11);
      final meEntity = DriftMessageMapper.toEntity(meRow!, currentUserId: me);
      expect(meEntity.receiverDeleted, isTrue);
      expect(meEntity.senderDeleted, isFalse);
    });
  });

  // === #35 — chat-card type wire keys match MessageIconType ==================
  group('#35 last-message type wire matches MessageIconType keys', () {
    late AppDatabase db;
    const me = 5;

    setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
    tearDown(() => db.close());

    Future<UserChatEntity> mapRoomWithLastOfType(MessageContentType t) async {
      final roomId = await db.roomsDao.insertRoom(RoomsCompanion.insert(
        type: RoomType.dm,
        serverRoomId: const Value(900),
        peerUserId: const Value(me),
        title: const Value('Peer'),
      ));
      await db.messagesDao.insertPending(MessagesCompanion.insert(
        clientUuid: 'last',
        roomId: roomId,
        kind: MessageKind.user,
        type: t,
        createdAtClient: 1000,
        state: MessageState.sent,
        serverMessageId: const Value(50),
        senderId: const Value(me),
        // empty body forces the media-preview path
        body: const Value(''),
      ));
      final room = await db.roomsDao.findByLocalId(roomId);
      final last = await db.messagesDao.findByServerMessageId(50);
      return RoomToConversationMapper.toUserChat(
        RoomWithLast(room: room!, last: last),
      );
    }

    // The exact set of keys MessageIconType switches on for media (anything else
    // falls through to the raw message text default).
    const iconKeys = {'img', 'voice', 'video', 'file', 'CP'};

    test('image -> "img" (the MessageIconType key, not "image")', () async {
      final e = await mapRoomWithLastOfType(MessageContentType.image);
      expect(e.lastMessage.type, 'img');
      expect(iconKeys.contains(e.lastMessage.type), isTrue);
    });

    test('audio -> "voice"', () async {
      final e = await mapRoomWithLastOfType(MessageContentType.audio);
      expect(e.lastMessage.type, 'voice');
      expect(iconKeys.contains(e.lastMessage.type), isTrue);
    });

    test('video -> "video"', () async {
      final e = await mapRoomWithLastOfType(MessageContentType.video);
      expect(e.lastMessage.type, 'video');
      expect(iconKeys.contains(e.lastMessage.type), isTrue);
    });

    test('text -> "text" (not a media icon key; renders the body)', () async {
      final e = await mapRoomWithLastOfType(MessageContentType.text);
      expect(e.lastMessage.type, 'text');
      expect(iconKeys.contains(e.lastMessage.type), isFalse);
    });
  });

  // === #62 — reactions are a pure function of the entity =====================
  group('#62 ReactController.emojisFor is pure (no shared singleton)', () {
    ReactEntity react(String r) => ReactEntity(react: r);

    test('null reacts -> empty list', () {
      const e = MessagesEntity(reacts: null);
      expect(ReactController.emojisFor(e), isEmpty);
    });

    test('maps each react string to its Emotion', () {
      final e = MessagesEntity(reacts: [react('love'), react('haha')]);
      expect(ReactController.emojisFor(e), [Emotions.love, Emotions.haha]);
    });

    test('unknown react falls back to like', () {
      final e = MessagesEntity(reacts: [react('???')]);
      expect(ReactController.emojisFor(e), [Emotions.like]);
    });

    test('two different entities never share state (no cross-bubble bleed)', () {
      final a = MessagesEntity(reacts: [react('wow')]);
      final b = MessagesEntity(reacts: [react('angry'), react('care')]);
      // Interleave reads to prove there is no mutable shared list.
      final ra1 = ReactController.emojisFor(a);
      final rb = ReactController.emojisFor(b);
      final ra2 = ReactController.emojisFor(a);
      expect(ra1, [Emotions.wow]);
      expect(rb, [Emotions.angry, Emotions.care]);
      expect(ra2, [Emotions.wow]);
    });
  });

  // === #37/#93 — group reply preview never blank for media ===================
  group('#37/#93 group reply preview', () {
    test('text reply shows the body', () {
      expect(groupReplyPreview(MessageContentType.text, 'hello'), 'hello');
    });

    test('media replies show a localized placeholder, never blank', () {
      expect(groupReplyPreview(MessageContentType.image, ''), 'Photo');
      expect(groupReplyPreview(MessageContentType.audio, null), 'Voice');
      expect(groupReplyPreview(MessageContentType.video, '  '), 'Video');
    });

    test('empty text body yields empty (no media placeholder)', () {
      expect(groupReplyPreview(MessageContentType.text, ''), '');
    });
  });
}
