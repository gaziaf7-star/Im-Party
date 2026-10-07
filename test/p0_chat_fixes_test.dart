// P0 chat fixes — unit tests.
//
// Covers the two user-reported production bugs fixed in P0:
//   * #6 cross-account leak: AppDatabase.wipeChatData() clears ALL chat tables
//     so a newly signed-in account never reads the previous account's cache.
//   * #5 delete-for-everyone: RealtimeMessageMapper now reflects a server-side
//     delete-for-everyone (both sides deleted) into MessageDeleteState.deletedForAll
//     so the deletion survives a resync/reinstall, while a single-side flag is
//     left absent (must not hide a message we can still see / preserves local).

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:general/src/core/database/app_database.dart';
import 'package:general/src/core/database/tables/chat_tables.dart';
import 'package:general/src/core/realtime/realtime_message_mapper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppDatabase.wipeChatData (#6 cross-account leak)', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('wipes every chat table so the next account starts clean', () async {
      final room = await db.roomsDao.insertRoom(
        RoomsCompanion.insert(type: RoomType.dm, serverRoomId: const Value(10)),
      );

      await db.into(db.messages).insert(MessagesCompanion.insert(
            clientUuid: 'c1',
            roomId: room,
            kind: MessageKind.user,
            type: MessageContentType.text,
            createdAtClient: 0,
            state: MessageState.sent,
            body: const Value('secret of account A'),
          ));
      await db.into(db.conversationMembers).insert(
            ConversationMembersCompanion.insert(roomId: room, userId: 5),
          );
      await db.into(db.outbox).insert(OutboxCompanion.insert(
            opType: OutboxOpType.sendMsg,
            clientUuid: 'o1',
            roomId: room,
            payloadJson: '{}',
            createdAt: 0,
          ));
      await db.into(db.mediaUploads).insert(MediaUploadsCompanion.insert(
            clientUuid: 'm1',
            localPath: '/tmp/x.jpg',
            uploadState: MediaUploadState.queued,
          ));
      await db.into(db.syncState).insert(
            SyncStateCompanion.insert(roomId: Value(room)),
          );

      // Sanity: everything is populated before the wipe.
      expect((await db.select(db.rooms).get()), isNotEmpty);
      expect((await db.select(db.messages).get()), isNotEmpty);
      expect((await db.select(db.conversationMembers).get()), isNotEmpty);
      expect((await db.select(db.outbox).get()), isNotEmpty);
      expect((await db.select(db.mediaUploads).get()), isNotEmpty);
      expect((await db.select(db.syncState).get()), isNotEmpty);

      await db.wipeChatData();

      expect((await db.select(db.rooms).get()), isEmpty);
      expect((await db.select(db.messages).get()), isEmpty);
      expect((await db.select(db.conversationMembers).get()), isEmpty);
      expect((await db.select(db.outbox).get()), isEmpty);
      expect((await db.select(db.mediaUploads).get()), isEmpty);
      expect((await db.select(db.syncState).get()), isEmpty);
    });

    test('is a no-op on an already-empty database', () async {
      await db.wipeChatData();
      expect((await db.select(db.rooms).get()), isEmpty);
      expect((await db.select(db.messages).get()), isEmpty);
    });
  });

  group('RealtimeMessageMapper deleteState (#5 delete-for-everyone)', () {
    const mapper = RealtimeMessageMapper();

    MessagesCompanion mapWith(Object? sender, Object? receiver) {
      final c = mapper.toCompanion(
        {
          'client_uuid': 'u1',
          'chat_room_id': 1,
          'message': 'hello',
          'sender_deleted': sender,
          'receiver_deleted': receiver,
        },
        roomLocalId: 1,
      );
      expect(c, isNotNull);
      return c!;
    }

    test('both sides deleted -> deletedForAll (survives resync)', () {
      final c = mapWith(true, true);
      expect(c.deleteState.present, isTrue);
      expect(c.deleteState.value, MessageDeleteState.deletedForAll);
    });

    test('accepts non-bool truthy encodings (1 / "1" / "true")', () {
      for (final pair in <List<Object?>>[
        [1, 1],
        ['1', '1'],
        ['true', 'true'],
      ]) {
        final c = mapWith(pair[0], pair[1]);
        expect(c.deleteState.present, isTrue, reason: 'for $pair');
        expect(c.deleteState.value, MessageDeleteState.deletedForAll,
            reason: 'for $pair');
      }
    });

    test('only one side deleted -> column left absent (preserves local state)',
        () {
      expect(mapWith(true, false).deleteState.present, isFalse);
      expect(mapWith(false, true).deleteState.present, isFalse);
      expect(mapWith(1, 0).deleteState.present, isFalse);
    });

    test('neither side deleted -> column left absent', () {
      expect(mapWith(false, false).deleteState.present, isFalse);
      expect(mapWith(null, null).deleteState.present, isFalse);
    });
  });
}
