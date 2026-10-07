import 'package:general/src/core/database/app_database.dart' as db;
import 'package:general/src/core/database/daos/rooms_dao.dart';
import 'package:general/src/core/database/tables/chat_tables.dart' as db;
import 'package:general/src/core/index.dart';
import 'package:general/src/core/utils/relative_time.dart';
import 'package:general/src/features/groups/domain/entities/group_entity.dart';
import 'package:general/src/features/groups/domain/entities/group_enums.dart';
import 'package:general/src/features/messages/data/mappers/drift_message_mapper.dart';
import 'package:general/src/features/messages/domain/entities/user_chat_entity.dart';

/// Bridges a drift conversation row ([RoomWithLast]) to the entities the
/// existing chat-list widgets already render. Centralising it here keeps the
/// time formatting identical to the message screen — both run the last-message
/// timestamp through [Methods.utcToLocal], so the list time always matches the
/// time shown inside the conversation (the old mismatch came from two different
/// formatting paths).
class RoomToConversationMapper {
  const RoomToConversationMapper._();

  /// drift dm room -> the 1:1 list entity ([ChatRoomCard] + messages nav).
  static UserChatEntity toUserChat(RoomWithLast row) {
    final room = row.room;
    // The live list path supplies the denormalized [RoomWithLast.preview] (no
    // join); the search/jump path supplies a real [Message] as `last`. Read the
    // preview through [_LastView] so both paths render identically.
    final last = _LastView.of(row);
    return UserChatEntity(
      userId: room.peerUserId ?? 0,
      chatId: room.serverRoomId ?? 0,
      unreadMessage: room.unreadCount,
      name: room.title ?? '',
      image: room.avatarUrl ?? '',
      hasColorName: false,
      inRoom: false,
      lastMessage: LastMessageEntity(
        id: last.serverMessageId,
        senderId: last.senderId,
        message: _previewText(last),
        type: last.type == null ? null : _typeWire(last.type!),
        time: timeLabel(row),
        status: _statusOf(last),
        senderDeleted: last.deleteState == db.MessageDeleteState.deletedForAll,
        receiverDeleted: last.deleteState == db.MessageDeleteState.deletedForAll,
      ),
    );
  }

  /// drift group room -> the group list entity ([GroupListCard] + group nav).
  /// Only the fields needed to open and chat are populated from the row; the
  /// group detail screen re-fetches full metadata (members/privacy) on open.
  static GroupEntity toGroup(RoomWithLast row) {
    final room = row.room;
    return GroupEntity(
      id: room.groupId ?? 0,
      chatRoomId: room.serverRoomId ?? 0,
      name: room.title ?? '',
      avatar: room.avatarUrl ?? '',
      myRole: GroupRole.fromString(room.myRole),
      membersCount: room.memberCount,
      unreadCount: room.unreadCount,
    );
  }

  /// WhatsApp-style relative last-activity label for the list:
  ///  - < 1 min   -> "الآن"
  ///  - < 60 min  -> "منذ N دقيقة"
  ///  - same day  -> time without seconds (h:mm a, locale-aware)
  ///  - yesterday -> "أمس"
  ///  - older     -> date (yyyy/MM/dd)
  /// The time/date cases reuse [Methods.utcToLocal] (the app's tested,
  /// locale-aware UTC->local formatter) so they match the conversation screen.
  static String timeLabel(RoomWithLast row) {
    // The live list path has no message row; the room's updated_at already tracks
    // the last activity (bumped by applyIncoming/OutgoingMessageMeta), so it is
    // the canonical time. The search path can use the matched message's time.
    final ms = row.last?.serverCreatedAt ??
        row.last?.createdAtClient ??
        row.room.updatedAt;
    if (ms == null) return '';
    return relativeLabel(ms);
  }

  static String relativeLabel(int ms) => RelativeTime.fromMs(ms);

  /// Public last-message preview for a row (used by group rows in the list).
  static String preview(RoomWithLast row) => _previewText(_LastView.of(row));

  /// Subtitle preview: the body for text, a compact glyph for media bodies.
  static String _previewText(_LastView last) {
    // Security: never reveal the content of a deleted message in the list.
    if (last.deleteState == db.MessageDeleteState.deletedForAll) {
      return StringManager.messageWasDeleted.tr();
    }
    // CP requests carry their payload (id/title/status) as JSON in `body` —
    // show a friendly label instead of the raw JSON the generic body check
    // below would otherwise surface.
    if (last.type == db.MessageContentType.cp) {
      return StringManager.cpRequestTitle.tr();
    }
    final body = last.body;
    if (body != null && body.trim().isNotEmpty) return body;
    switch (last.type) {
      case db.MessageContentType.image:
        return '📷';
      case db.MessageContentType.audio:
        return '🎙️';
      case db.MessageContentType.video:
        return '🎬';
      case db.MessageContentType.cp:
      case db.MessageContentType.text:
      case null:
        return '';
    }
  }

  /// Delegates to the single shared tick-status implementation in
  /// [DriftMessageMapper.statusOf] (#79: no duplication).
  static String? _statusOf(_LastView last) => DriftMessageMapper.statusOf(
        state: last.state,
        serverStatus: last.serverStatus,
      );

  /// Wire type for the chat-card preview. The keys MUST match the ones
  /// [MessageIconType] switches on ('img'/'voice'/'video') — the legacy/REST
  /// convention — otherwise the drift-sourced row falls through to the raw
  /// glyph instead of the proper icon + label.
  static String _typeWire(db.MessageContentType t) {
    switch (t) {
      case db.MessageContentType.image:
        return 'img';
      case db.MessageContentType.audio:
        return 'voice';
      case db.MessageContentType.video:
        return 'video';
      case db.MessageContentType.cp:
        return 'CP';
      case db.MessageContentType.text:
        return 'text';
    }
  }
}

/// Unified read view of a row's last message, sourced from either a full
/// [db.Message] (search/jump path, where `row.last` is a real matched message)
/// or the room's denormalized [LastPreview] (live list path, no join). Lets the
/// mapper render the preview/tick identically regardless of source.
class _LastView {
  const _LastView({
    this.body,
    this.type,
    this.senderId,
    this.serverMessageId,
    this.serverStatus,
    this.state,
    this.deleteState,
  });

  final String? body;
  final db.MessageContentType? type;
  final int? senderId;
  final int? serverMessageId;
  final String? serverStatus;
  final db.MessageState? state;
  final db.MessageDeleteState? deleteState;

  /// Prefer the explicit matched message (search path); fall back to the room's
  /// denormalized preview (live list path).
  factory _LastView.of(RoomWithLast row) {
    final m = row.last;
    if (m != null) {
      return _LastView(
        body: m.body,
        type: m.type,
        senderId: m.senderId,
        serverMessageId: m.serverMessageId,
        serverStatus: m.serverStatus,
        state: m.state,
        deleteState: m.deleteState,
      );
    }
    final p = row.preview;
    return _LastView(
      body: p.text,
      type: p.type,
      senderId: p.senderId,
      serverMessageId: p.serverMessageId,
      serverStatus: p.status,
      state: p.state,
      deleteState: p.deleteState,
    );
  }
}
