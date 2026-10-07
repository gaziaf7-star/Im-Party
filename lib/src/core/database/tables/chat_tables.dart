import 'package:drift/drift.dart';

/// Local conversation type (1:1 direct message or group).
enum RoomType { dm, group }

/// Local message kind — a normal user message or a system event line.
enum MessageKind { user, system }

/// Concrete media/content type of a message body.
// `cp` is appended at the end (not inserted alphabetically) since drift
// persists this enum as an int index (intEnum<MessageContentType>()) — the
// existing stored indices for text/image/audio/video must not shift.
enum MessageContentType { text, image, audio, video, cp }

/// Lifecycle of a message as it travels through the outbox + realtime layer.
enum MessageState { pending, sent, delivered, read, failed }

/// Local soft-delete marker for a message.
enum MessageDeleteState { none, deletedForMe, deletedForAll }

/// Outbox operation kinds the [OutboxWorker] (Phase 5) drains.
enum OutboxOpType { sendMsg, edit, delete, react, markRead, groupOp }

/// Upload pipeline state for an attachment.
enum MediaUploadState { queued, uploading, done, failed }

/// `rooms` — one row per conversation (dm or group). Local source of truth for
/// the conversation list + per-room read/unread bookkeeping.
class Rooms extends Table {
  @override
  String get tableName => 'rooms';

  IntColumn get localId => integer().autoIncrement()();

  /// Server-side conversation id. Null until the room is reconciled with the
  /// backend. UNIQUE so a server room maps to exactly one local row.
  IntColumn get serverRoomId => integer().nullable().unique()();

  IntColumn get type => intEnum<RoomType>()();

  TextColumn get title => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();

  /// For 1:1 (dm) rooms: the OTHER participant's user id. Needed to open the
  /// conversation (peer id drives the `chat:dm.{min}_{max}` realtime channel and
  /// the messages route). Null for group rooms. (schema v3)
  IntColumn get peerUserId => integer().nullable()();

  /// For group rooms: the `chat_groups.id` (distinct from serverRoomId which is
  /// the chat_room id). Needed to open/send in a group from the list. Null for
  /// 1:1 rooms. (schema v3)
  IntColumn get groupId => integer().nullable()();

  /// For group rooms: active members count (denormalized for the list row). 0 for
  /// 1:1 rooms. (schema v4)
  IntColumn get memberCount => integer().withDefault(const Constant(0))();

  /// Denormalized pointer to the last message row (for list previews).
  IntColumn get lastMessageLocalId => integer().nullable()();

  // --- Denormalized last-message preview (schema v6) -------------------------
  // The conversation-list stream used to LEFT JOIN `messages` to read the last
  // message's body/type/status for the preview line, which forced drift to
  // re-run the whole join on EVERY message write in ANY room (every
  // message/reaction/receipt app-wide). These columns mirror exactly the fields
  // the list needs so the list stream watches `rooms` alone and never re-runs a
  // join. They are kept in sync by applyIncomingMessageMeta /
  // applyOutgoingMessageMeta (which already own the last-message pointer) and by
  // the receipt/delete writers that can change the last message's tick.

  /// Last message body (null for media-only bodies). Drives the preview text.
  TextColumn get lastPreviewText => text().nullable()();

  /// Last message [MessageContentType] index — so the list renders the same
  /// glyph/icon ('img'/'voice'/'video'/text) the join-based path produced.
  IntColumn get lastPreviewType => integer().nullable()();

  /// Last message sender id (for the "You:" prefix + per-row isMe styling).
  IntColumn get lastPreviewSenderId => integer().nullable()();

  /// Last message server id (for LastMessageEntity.id / jump-to-message).
  IntColumn get lastPreviewServerMessageId => integer().nullable()();

  /// Last message raw server delivery status ('seen'/'sent'/...) — for the tick.
  TextColumn get lastPreviewStatus => text().nullable()();

  /// Last message [MessageState] index — for the tick when no raw status.
  IntColumn get lastPreviewState => integer().nullable()();

  /// Last message [MessageDeleteState] index — for the deleted-preview placeholder.
  IntColumn get lastPreviewDeleteState => integer().nullable()();

  /// Highest server_seq seen for this room (drives ordering + unread math).
  IntColumn get lastServerSeq => integer().withDefault(const Constant(0))();

  /// High-water-mark of what the current user has read in this room.
  IntColumn get myLastReadSeq => integer().withDefault(const Constant(0))();

  IntColumn get unreadCount => integer().withDefault(const Constant(0))();

  IntColumn get mutedUntil => integer().nullable()();

  TextColumn get draftText => text().nullable()();

  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  /// Current user's role in this room (member/admin/owner) — null for 1:1.
  TextColumn get myRole => text().nullable()();

  IntColumn get updatedAt => integer().nullable()();
}

/// `messages` — every message body, optimistic or confirmed. App-owned state:
/// the UI renders reactively from this table, never from the network directly.
class Messages extends Table {
  @override
  String get tableName => 'messages';

  IntColumn get localId => integer().autoIncrement()();

  /// Client-generated UUID. The dedup + idempotency key across the whole stack.
  TextColumn get clientUuid => text().unique()();

  /// Server message id. Null while pending. UNIQUE once assigned.
  IntColumn get serverMessageId => integer().nullable().unique()();

  /// FK -> rooms.local_id.
  IntColumn get roomId =>
      integer().references(Rooms, #localId, onDelete: KeyAction.cascade)();

  /// Atomic per-room sequence from the server. Null while pending; drives order.
  IntColumn get serverSeq => integer().nullable()();

  IntColumn get senderId => integer().nullable()();

  IntColumn get kind => intEnum<MessageKind>()();

  /// For [MessageKind.system] rows: the system event name (member_joined, ...).
  TextColumn get systemEvent => text().nullable()();

  IntColumn get type => intEnum<MessageContentType>()();

  TextColumn get body => text().nullable()();

  /// Reply target referenced by client_uuid (stable across pending->sent).
  TextColumn get replyToClientUuid => text().nullable()();

  /// Client clock at creation time (ms epoch) — fallback ordering for pending.
  IntColumn get createdAtClient => integer()();

  /// Server-assigned creation timestamp (ms epoch). Null while pending.
  IntColumn get serverCreatedAt => integer().nullable()();

  IntColumn get state => intEnum<MessageState>()();

  IntColumn get deleteState => intEnum<MessageDeleteState>()
      .withDefault(Constant(MessageDeleteState.none.index))();

  // --- Feature-parity columns with the legacy 1:1 chat (added schema v2) ---

  /// Raw server-side delivery status string for 1:1 receipts (e.g. 'seen',
  /// 'sent'). Mirrors the legacy `MessagesEntity.status`; null for groups.
  TextColumn get serverStatus => text().nullable()();

  /// Reactions cached as a JSON array (id, react, userReact{...}). Kept on the
  /// row so the UI renders without a join; toggled optimistically then synced.
  TextColumn get reactsJson => text().nullable()();

  /// Attachment payload as JSON (file url, type, first_frame/thumb, duration).
  /// Covers image/audio/video bodies for both sent and received messages.
  TextColumn get attachmentJson => text().nullable()();

  /// Cached preview of the replied-to message (id, user_id, text, type, album)
  /// so the reply bubble renders without resolving [replyToClientUuid].
  TextColumn get replyPreviewJson => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {clientUuid},
      ];
}

/// `conversation_members` — membership rows for unified 1:1 + group rooms.
class ConversationMembers extends Table {
  @override
  String get tableName => 'conversation_members';

  /// FK -> rooms.local_id.
  IntColumn get roomId =>
      integer().references(Rooms, #localId, onDelete: KeyAction.cascade)();

  IntColumn get userId => integer()();

  TextColumn get role => text().nullable()();
  TextColumn get status => text().nullable()();

  IntColumn get joinedSeq => integer().nullable()();
  IntColumn get removedSeq => integer().nullable()();

  TextColumn get nameCache => text().nullable()();
  TextColumn get avatarCache => text().nullable()();

  IntColumn get lastReadSeq => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {roomId, userId};
}

/// `outbox` — durable FIFO of pending operations the worker retries with backoff.
class Outbox extends Table {
  @override
  String get tableName => 'outbox';

  IntColumn get localId => integer().autoIncrement()();

  IntColumn get opType => intEnum<OutboxOpType>()();

  /// Idempotency-Key sent to the backend; ties this op to its message row.
  TextColumn get clientUuid => text()();

  IntColumn get roomId => integer()();

  TextColumn get payloadJson => text()();

  /// Optional reference into media_uploads for attachment-bearing ops.
  TextColumn get mediaLocalRef => text().nullable()();

  IntColumn get attempts => integer().withDefault(const Constant(0))();

  /// ms epoch — worker skips rows whose retry time is in the future.
  IntColumn get nextRetryAt => integer().nullable()();

  TextColumn get lastError => text().nullable()();

  IntColumn get createdAt => integer()();
}

/// `media_uploads` — resumable upload state per attachment, keyed by client_uuid.
class MediaUploads extends Table {
  @override
  String get tableName => 'media_uploads';

  TextColumn get clientUuid => text()();

  TextColumn get localPath => text()();
  TextColumn get remoteUrl => text().nullable()();

  TextColumn get thumbLocalPath => text().nullable()();
  TextColumn get thumbRemoteUrl => text().nullable()();

  TextColumn get mime => text().nullable()();

  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  IntColumn get durationMs => integer().nullable()();
  IntColumn get sizeBytes => integer().nullable()();

  IntColumn get uploadState => intEnum<MediaUploadState>()();

  IntColumn get bytesSent => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {clientUuid};
}

/// `sync_state` — per-room recovery cursor (last seq + Centrifugo epoch).
class SyncState extends Table {
  @override
  String get tableName => 'sync_state';

  IntColumn get roomId => integer()();

  IntColumn get lastKnownSeq => integer().withDefault(const Constant(0))();

  /// Centrifugo channel epoch. A mismatch on reconnect forces a full resync.
  TextColumn get epoch => text().nullable()();

  IntColumn get lastSyncedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {roomId};
}
