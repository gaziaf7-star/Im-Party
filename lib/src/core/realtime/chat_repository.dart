import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:general/src/core/database/app_database.dart';
import 'package:general/src/core/database/daos/media_uploads_dao.dart';
import 'package:general/src/core/database/daos/messages_dao.dart';
import 'package:general/src/core/database/daos/outbox_dao.dart';
import 'package:general/src/core/database/daos/rooms_dao.dart';
import 'package:general/src/core/database/tables/chat_tables.dart';
import 'package:general/src/core/realtime/realtime_http.dart';
import 'package:general/src/core/realtime/sync_engine.dart';
import 'package:uuid/uuid.dart';

/// Local-first chat repository over drift (Plan section 7.5).
///
/// The single seam the 1:1 chat BLoCs send/read through. It owns the
/// optimistic-send + offline-queue + recovery contract so the UI never touches
/// the network directly:
///
///  - [send] writes an optimistic `pending` row to drift (rendered immediately
///    off the stream) and enqueues a durable outbox op. The [OutboxWorker]
///    drains it with an `Idempotency-Key` = `client_uuid`; on ack the row is
///    promoted to `sent` and dedup keeps the realtime echo from duplicating it.
///  - [watchMessages] / [conversation] read newest-first from drift, so the
///    list survives reconnects and process death.
///  - [olderPage] is keyset pagination (`server_seq < cursor`), index-backed and
///    stable under concurrent inserts — no OFFSET, no page numbers.
///  - [syncRoom] / [openConversation] pull the REST delta after the local read
///    so a freshly-opened conversation catches up from `since_seq`.
///  - message-state transitions (pending -> sent -> delivered -> read, + failed)
///    and read-receipt bookkeeping go through here.
///
/// It depends ONLY on the DAOs, [SyncEngine] and drift companions (no app
/// barrel, no dio), so it compiles and is unit-testable against an in-memory
/// drift database exactly like the rest of the Phase 5 realtime layer.
class ChatRepository {
  ChatRepository({
    required RoomsDao roomsDao,
    required MessagesDao messagesDao,
    required OutboxDao outboxDao,
    required MediaUploadsDao mediaUploadsDao,
    required SyncEngine syncEngine,
    required int Function() currentUserId,
    RealtimeHttp? http,
    String? ensureRoomUrl,
    OutboxKick? onEnqueued,
    Uuid uuid = const Uuid(),
    int Function()? clock,
  })  : _roomsDao = roomsDao,
        _messagesDao = messagesDao,
        _outboxDao = outboxDao,
        _mediaUploadsDao = mediaUploadsDao,
        _syncEngine = syncEngine,
        _currentUserId = currentUserId,
        _http = http,
        _ensureRoomUrl = ensureRoomUrl,
        _onEnqueued = onEnqueued,
        _uuid = uuid,
        _clock = clock ?? (() => DateTime.now().millisecondsSinceEpoch);

  final RoomsDao _roomsDao;
  final MessagesDao _messagesDao;
  final OutboxDao _outboxDao;
  final MediaUploadsDao _mediaUploadsDao;
  final SyncEngine _syncEngine;
  final int Function() _currentUserId;
  // HTTP seam + URL for the lightweight 1:1 get-or-create-room resolution. Kept
  // nullable so existing unit tests (in-memory drift, no network) construct the
  // repository without them; [resolveServerRoomId] is a no-op (returns 0) when
  // unwired, and every caller already handles a 0 result.
  final RealtimeHttp? _http;
  final String? _ensureRoomUrl;
  final OutboxKick? _onEnqueued;
  final Uuid _uuid;
  final int Function() _clock;

  // --- rooms ----------------------------------------------------------------

  /// Resolve (or create) the local 1:1 room for a server conversation id.
  /// Returns the room's `local_id`, the stable key everything else uses.
  Future<int> ensureDmRoom({
    required int serverRoomId,
    int? peerUserId,
    String? title,
    String? avatarUrl,
  }) {
    // Single atomic get-or-create + reconciliation in the DAO: a peer can never
    // end up with two rooms, and any orphan (serverRoomId 0/null) is folded into
    // the real room WITH its messages migrated (no cascade data loss — B1).
    return _roomsDao.getOrCreateDmRoom(
      serverRoomId: serverRoomId,
      peerUserId: peerUserId,
      title: title,
      avatarUrl: avatarUrl,
    );
  }

  Future<RoomRef?> roomByServerId(int serverRoomId) async {
    final room = await _roomsDao.findByServerRoomId(serverRoomId);
    if (room == null) return null;
    return RoomRef(localId: room.localId, serverRoomId: serverRoomId);
  }

  /// Resolve the REAL server chat_room_id for a 1:1 peer via the lightweight
  /// get-or-create endpoint (POST /Chat-room/ensure {user_id}). This is the step
  /// the offline-first open lost when the legacy POST /Chat-room (which get-or-
  /// created the row and returned its id) was dropped: a conversation opened from
  /// a profile/picker carries only the peer id, so without this the whole stack
  /// (seq-keyed sync, durable read receipt) ran against server room 0 and 404'd.
  ///
  /// Returns the server room id (> 0) on success, or 0 when the repository was
  /// constructed without an HTTP seam (unit tests) or the call fails (offline) —
  /// callers fall back to the local-first path on 0 exactly as before.
  Future<int> resolveServerRoomId({required int peerUserId}) async {
    final http = _http;
    final url = _ensureRoomUrl;
    if (http == null || url == null || peerUserId <= 0) return 0;
    try {
      final response = await http.post(url, data: {'user_id': peerUserId});
      return _extractChatRoomId(response.data);
    } catch (_) {
      return 0; // offline / transient — local-first path still stands
    }
  }

  /// Ensure the local drift DM room exists AND is bound to the real server room
  /// id. When [serverRoomId] is already known (> 0) this is just [ensureDmRoom].
  /// Otherwise it resolves the id over the network and, on success, re-runs
  /// [ensureDmRoom] with it so [RoomsDao.getOrCreateDmRoom] folds the peer-keyed
  /// orphan (serverRoomId 0) into the real room and migrates its messages. The
  /// returned [RoomRef] carries the resolved server id (which may still be 0 when
  /// offline — the caller then runs purely local until the next sync upgrades it).
  Future<RoomRef> ensureDmRoomResolved({
    required int serverRoomId,
    required int peerUserId,
    String? title,
    String? avatarUrl,
  }) async {
    var resolvedServerId = serverRoomId;
    if (resolvedServerId <= 0) {
      resolvedServerId = await resolveServerRoomId(peerUserId: peerUserId);
    }
    final localId = await ensureDmRoom(
      serverRoomId: resolvedServerId,
      peerUserId: peerUserId,
      title: title,
      avatarUrl: avatarUrl,
    );
    return RoomRef(localId: localId, serverRoomId: resolvedServerId);
  }

  /// Pull the chat_room_id out of the ensure-room response. The endpoint wraps it
  /// as `{ data: { chat_room_id } }` (Common::apiResponse), but tolerate a bare
  /// `chat_room_id`/`id` too. Returns 0 when none is present.
  static int _extractChatRoomId(dynamic body) {
    dynamic node = body;
    if (node is Map && node['data'] is Map) node = node['data'];
    if (node is! Map) return 0;
    final raw = node['chat_room_id'] ?? node['id'];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  /// Reactive WhatsApp-style conversation list (room + last message), newest
  /// activity first. The chats list screen binds this; unread/last-message/order
  /// all update live as the realtime client writes into drift.
  Stream<List<RoomWithLast>> watchRooms() => _roomsDao.watchRoomsWithLast();

  /// Seed/refresh the whole conversation list into drift from the REST sync
  /// endpoint. Called on chats-list open and on reconnect/resume. Returns the
  /// number of rooms applied (0 when offline — the cached list still renders).
  Future<int> refreshRooms() => _syncEngine.syncRoomsList();

  // --- reads (local-first) ---------------------------------------------------

  /// Reactive newest-first window for the open conversation. The UI binds this;
  /// pending rows sort to the top until the server assigns a `server_seq`.
  Stream<List<Message>> watchMessages(int roomLocalId, {int limit = 50}) =>
      _messagesDao.watchRoomMessages(roomLocalId, limit: limit);

  /// One-shot snapshot of the newest window (e.g. on first open, before the
  /// stream subscription warms up). Mirrors [watchMessages] ordering, so it
  /// includes optimistic `pending` rows (null server_seq) at the top —
  /// [olderPage] is keyset over confirmed rows only and would drop them.
  Future<List<Message>> conversation(int roomLocalId, {int limit = 50}) {
    return _messagesDao.watchRoomMessages(roomLocalId, limit: limit).first;
  }

  /// Older keyset page before [beforeServerSeq] (newest-first, bounded). Returns
  /// an empty list when the top of history is reached.
  Future<List<Message>> olderPage({
    required int roomLocalId,
    required int beforeServerSeq,
    int limit = 50,
  }) {
    return _messagesDao.getOlderPage(
      roomId: roomLocalId,
      beforeServerSeq: beforeServerSeq,
      limit: limit,
    );
  }

  // --- send (optimistic + durable outbox) ------------------------------------

  /// Optimistically persist a message and enqueue it for delivery.
  ///
  /// Writes the `pending` row first (so the UI shows it instantly off the
  /// stream), then a matching outbox op carrying the wire payload. The returned
  /// [SentMessage] exposes the generated `client_uuid` + local id so the caller
  /// can correlate later state changes. A media-bearing send passes
  /// [mediaLocalRef] (the upload's `client_uuid`); the outbox holds the op until
  /// the [MediaUploadWorker] writes the remote url, then sends.
  ///
  /// Idempotent under double-send: the `client_uuid` UNIQUE constraint makes a
  /// re-issued identical [clientUuid] a no-op rather than a duplicate row.
  Future<SentMessage> send({
    required int roomLocalId,
    required int peerUserId,
    String? body,
    MessageContentType type = MessageContentType.text,
    String? replyToClientUuid,
    int? replyToServerMessageId,
    String? mediaLocalRef,
    String? mediaRemoteRef,
    String? attachmentJson,
    String? duration,
    String? clientUuid,
  }) async {
    final uuid = clientUuid ?? _uuid.v4();
    final now = _clock();
    final senderId = _currentUserId();

    // Explicit dedup on the idempotency key: a re-issued identical client_uuid
    // (retry races, double-tap) must not create a second row or outbox op. We
    // check before inserting rather than relying on the driver-specific return
    // value of INSERT OR IGNORE on conflict.
    final existing = await _messagesDao.findByClientUuid(uuid);
    if (existing != null) {
      return SentMessage(
        clientUuid: uuid,
        localId: existing.localId,
        alreadyQueued: true,
      );
    }

    final localId = await _messagesDao.insertPending(MessagesCompanion(
      clientUuid: Value(uuid),
      roomId: Value(roomLocalId),
      senderId: Value(senderId),
      kind: const Value(MessageKind.user),
      type: Value(type),
      body: body == null ? const Value.absent() : Value(body),
      // Optimistic attachment payload (local file path + isLocal:true) so the
      // media bubble renders the on-device file the instant it is sent, off the
      // same drift stream as text — no separate in-memory bubble. The server echo
      // (matched by client_uuid) overwrites this row with the remote url.
      attachmentJson: attachmentJson == null
          ? const Value.absent()
          : Value(attachmentJson),
      replyToClientUuid: replyToClientUuid == null
          ? const Value.absent()
          : Value(replyToClientUuid),
      createdAtClient: Value(now),
      state: const Value(MessageState.pending),
    ));

    // Optimistically bump the room so the chats list reorders + shows this
    // message's preview the instant it's sent (WhatsApp-style), instead of only
    // after the server echo. Mirrors applyIncomingMessageMeta for the outbound
    // side (no seq/unread bump).
    await _roomsDao.applyOutgoingMessageMeta(
      roomLocalId: roomLocalId,
      lastMessageLocalId: localId,
      createdAtClient: now,
    );

    final payload = <String, dynamic>{
      'client_uuid': uuid,
      'user_id': peerUserId,
      if (body != null) 'message': body,
      'type': _typeWire(type),
      // Video pre-uploads its bytes before enqueue, so the remote ref is known
      // up front — stamp it now. Image/audio carry [mediaLocalRef] instead and
      // the OutboxWorker stamps `file` once the MediaUploadWorker finishes.
      if (mediaRemoteRef != null) 'file': mediaRemoteRef,
      if (duration != null) 'duration': duration,
      // Reply target: the backend links a reply by the server message id
      // (`message_id`); reply-by-client-uuid is carried separately for the local
      // preview + future server-side uuid linking.
      if (replyToServerMessageId != null) 'message_id': replyToServerMessageId,
      if (replyToClientUuid != null)
        'reply_to_client_uuid': replyToClientUuid,
    };

    await _outboxDao.enqueue(OutboxCompanion(
      opType: const Value(OutboxOpType.sendMsg),
      clientUuid: Value(uuid),
      roomId: Value(roomLocalId),
      payloadJson: Value(jsonEncode(payload)),
      mediaLocalRef:
          mediaLocalRef == null ? const Value.absent() : Value(mediaLocalRef),
      createdAt: Value(now),
    ));

    // Nudge the worker so a queued message goes out now, not on the next tick.
    _onEnqueued?.call();

    return SentMessage(clientUuid: uuid, localId: localId);
  }

  /// Optimistically send a 1:1 attachment (image / voice) through the SAME outbox
  /// as text. Writes the optimistic drift row (rendering the on-device file) and
  /// a `media_uploads` record keyed by the message client_uuid; the
  /// [MediaUploadWorker] presigns + uploads the bytes, then the [OutboxWorker]
  /// stamps the resolved remote url onto the queued op and delivers it (idempotent
  /// on client_uuid). One system for text and media — no legacy REST multipart.
  Future<SentMessage> sendMedia({
    required int roomLocalId,
    required int peerUserId,
    required String localPath,
    required MessageContentType type,
    String? thumbLocalPath,
    String? duration,
    int? replyToServerMessageId,
  }) async {
    final uuid = _uuid.v4();

    await _mediaUploadsDao.upsert(MediaUploadsCompanion(
      clientUuid: Value(uuid),
      localPath: Value(localPath),
      thumbLocalPath: thumbLocalPath == null
          ? const Value.absent()
          : Value(thumbLocalPath),
      uploadState: const Value(MediaUploadState.queued),
    ));

    return send(
      roomLocalId: roomLocalId,
      peerUserId: peerUserId,
      type: type,
      mediaLocalRef: uuid,
      clientUuid: uuid,
      duration: duration,
      attachmentJson: _localAttachmentJson(
        file: localPath,
        type: _typeWire(type),
        firstFrame: thumbLocalPath,
        duration: duration,
      ),
      replyToServerMessageId: replyToServerMessageId,
    );
  }

  /// Optimistic attachment JSON for an own, still-uploading media message. Carries
  /// the on-device path + `isLocal:true` so [DriftMessageMapper] renders the local
  /// file (not a network url) until the server echo replaces it.
  static String _localAttachmentJson({
    required String file,
    required String type,
    String? firstFrame,
    String? duration,
  }) {
    return jsonEncode({
      'file': file,
      'type': type,
      'isLocal': true,
      if (firstFrame != null) 'firstFrame': firstFrame,
      'duration': duration ?? '',
    });
  }

  /// Public builder so callers that pre-upload (video) can persist the same
  /// optimistic local-attachment shape on the drift row via [send].
  static String localAttachmentJson({
    required String file,
    required String type,
    String? firstFrame,
    String? duration,
  }) =>
      _localAttachmentJson(
        file: file,
        type: type,
        firstFrame: firstFrame,
        duration: duration,
      );

  /// Optimistically persist a GROUP message and enqueue it for delivery.
  ///
  /// Same optimistic-insert + durable-outbox contract as [send], but the wire
  /// payload targets the group endpoint `POST /api/groups/{id}/messages` instead
  /// of the 1:1 path. The override is carried on the outbox op via the reserved
  /// `__path` key so the existing [OutboxWorker] FIFO/backoff/idempotency path is
  /// reused untouched — the 1:1 send path (no `__path`) keeps its default URL.
  Future<SentMessage> sendGroup({
    required int roomLocalId,
    required int serverGroupId,
    required String sendPath,
    String? body,
    MessageContentType type = MessageContentType.text,
    String? replyToClientUuid,
    String? mediaLocalRef,
    String? clientUuid,
  }) async {
    final uuid = clientUuid ?? _uuid.v4();
    final now = _clock();
    final senderId = _currentUserId();

    final existing = await _messagesDao.findByClientUuid(uuid);
    if (existing != null) {
      return SentMessage(
        clientUuid: uuid,
        localId: existing.localId,
        alreadyQueued: true,
      );
    }

    final localId = await _messagesDao.insertPending(MessagesCompanion(
      clientUuid: Value(uuid),
      roomId: Value(roomLocalId),
      senderId: Value(senderId),
      kind: const Value(MessageKind.user),
      type: Value(type),
      body: body == null ? const Value.absent() : Value(body),
      replyToClientUuid: replyToClientUuid == null
          ? const Value.absent()
          : Value(replyToClientUuid),
      createdAtClient: Value(now),
      state: const Value(MessageState.pending),
    ));

    // Optimistically bump the room so the chats list reorders + shows this
    // message's preview the instant it's sent (WhatsApp-style), mirroring the
    // 1:1 send path (no seq/unread bump).
    await _roomsDao.applyOutgoingMessageMeta(
      roomLocalId: roomLocalId,
      lastMessageLocalId: localId,
      createdAtClient: now,
    );

    final payload = <String, dynamic>{
      '__path': sendPath,
      'client_uuid': uuid,
      if (body != null) 'message': body,
      'type': _typeWire(type),
      if (replyToClientUuid != null)
        'reply_to_client_uuid': replyToClientUuid,
    };

    await _outboxDao.enqueue(OutboxCompanion(
      opType: const Value(OutboxOpType.sendMsg),
      clientUuid: Value(uuid),
      roomId: Value(roomLocalId),
      payloadJson: Value(jsonEncode(payload)),
      mediaLocalRef:
          mediaLocalRef == null ? const Value.absent() : Value(mediaLocalRef),
      createdAt: Value(now),
    ));

    _onEnqueued?.call();

    return SentMessage(clientUuid: uuid, localId: localId);
  }

  /// Open a GROUP conversation: ensure the local room row exists (typed
  /// [RoomType.group]) and pull the REST delta so the local store catches up
  /// from where it left off. Returns the room ref for stream + lifecycle wiring.
  Future<RoomRef> openGroupConversation({
    required int serverGroupRoomId,
    int? serverGroupId,
    String? title,
    String? avatarUrl,
    String? myRole,
  }) async {
    final localId = await _roomsDao.upsertByServerRoomId(RoomsCompanion(
      serverRoomId: Value(serverGroupRoomId),
      type: const Value(RoomType.group),
      groupId:
          serverGroupId == null ? const Value.absent() : Value(serverGroupId),
      title: title == null ? const Value.absent() : Value(title),
      avatarUrl: avatarUrl == null ? const Value.absent() : Value(avatarUrl),
      myRole: myRole == null ? const Value.absent() : Value(myRole),
    ));
    // Fire-and-forget background sync (mirrors the DM path) so the room opens
    // instantly from the cached local rows instead of blocking on two REST calls.
    // The drift stream re-renders as the backfill/sync results arrive.
    _syncEngine.backfillLatest(
      roomLocalId: localId,
      serverRoomId: serverGroupRoomId,
    ).catchError((_) => 0);
    _syncEngine.syncRoom(
      roomLocalId: localId,
      serverRoomId: serverGroupRoomId,
    ).catchError((_) => 0);
    return RoomRef(localId: localId, serverRoomId: serverGroupRoomId);
  }

  /// Re-queue a previously failed message for another delivery attempt without
  /// duplicating the drift row. Re-stamps the row's client time to now (so it
  /// reorders to the bottom of the conversation with a fresh time instead of
  /// returning to its frozen old position), flips it back to `pending`, and
  /// re-enqueues an outbox op if one is no longer present.
  Future<void> retry(String clientUuid) async {
    final message = await _messagesDao.findByClientUuid(clientUuid);
    if (message == null) return;
    if (message.state == MessageState.sent ||
        message.state == MessageState.delivered ||
        message.state == MessageState.read) {
      return; // already delivered; nothing to retry
    }

    final now = _clock();

    // Re-stamp + flip to pending in one write, then reorder the chats-list preview
    // off the new time — same optimistic reordering the original send() does.
    await _messagesDao.requeueForRetry(clientUuid, now);
    await _roomsDao.applyOutgoingMessageMeta(
      roomLocalId: message.roomId,
      lastMessageLocalId: message.localId,
      createdAtClient: now,
    );

    final existing = await _outboxDao.findByClientUuid(clientUuid);
    if (existing == null) {
      // The op was removed when the message failed permanently (4xx). Rebuild it
      // in the SAME shape as the normal send() path — crucially including
      // `user_id` (the peer), which the backend's getOrCreateChatRoom needs to
      // resolve/create the 1:1 room; without it store() can't route the message
      // and the resend fails again. peerUserId is read off the room.
      final peerUserId = (await _roomsDao.findByLocalId(message.roomId))?.peerUserId;
      final payload = <String, dynamic>{
        'client_uuid': clientUuid,
        if (peerUserId != null) 'user_id': peerUserId,
        if (message.body != null) 'message': message.body,
        'type': _typeWire(message.type),
        if (message.replyToClientUuid != null)
          'reply_to_client_uuid': message.replyToClientUuid,
      };
      await _outboxDao.enqueue(OutboxCompanion(
        opType: const Value(OutboxOpType.sendMsg),
        clientUuid: Value(clientUuid),
        roomId: Value(message.roomId),
        payloadJson: Value(jsonEncode(payload)),
        createdAt: Value(now),
      ));
    } else {
      // Clear the backoff so the worker retries on the next tick.
      await _outboxDao.recordFailure(
        localId: existing.localId,
        nextRetryAt: now,
        error: 'manual_retry',
      );
    }
    _onEnqueued?.call();
  }

  // --- recovery / catch-up ---------------------------------------------------

  /// Open a conversation: ensure the room exists, then pull the REST delta so
  /// the local store catches up from where it left off. Returns the room ref so
  /// the caller can wire the realtime subscription + stream.
  Future<RoomRef> openConversation({
    required int serverRoomId,
    int? peerUserId,
    String? title,
    String? avatarUrl,
  }) async {
    final localId = await ensureDmRoom(
      serverRoomId: serverRoomId,
      peerUserId: peerUserId,
      title: title,
      avatarUrl: avatarUrl,
    );
    await _syncEngine.syncRoom(roomLocalId: localId, serverRoomId: serverRoomId);
    return RoomRef(localId: localId, serverRoomId: serverRoomId);
  }

  /// Pull the REST delta for an already-open room (e.g. on reconnect / resume).
  Future<int> syncRoom({
    required int roomLocalId,
    required int serverRoomId,
  }) {
    return _syncEngine.syncRoom(
      roomLocalId: roomLocalId,
      serverRoomId: serverRoomId,
    );
  }

  /// Cold-open backfill: ensure the newest history page is in drift (via
  /// before_seq) so the conversation shows recent messages immediately, even
  /// when the forward since_seq cursor has passed the locally-held rows.
  Future<int> backfillLatest({
    required int roomLocalId,
    required int serverRoomId,
    int limit = 50,
  }) {
    return _syncEngine.backfillLatest(
      roomLocalId: roomLocalId,
      serverRoomId: serverRoomId,
      limit: limit,
    );
  }

  // --- read receipts / local state ------------------------------------------

  /// Mark the room read up to [upToSeq] (clears unread when caught up).
  Future<void> markRead({required int roomLocalId, required int upToSeq}) {
    return _roomsDao.markRead(roomLocalId, upToSeq);
  }

  /// Fully clear a room's unread badge (used the moment a conversation opens).
  Future<void> clearUnread(int roomLocalId) => _roomsDao.clearUnread(roomLocalId);

  /// The room's high-water-mark server sequence (0 when unknown / not synced).
  /// Used to fill `last_read_seq` on the durable read receipt.
  Future<int> roomLastSeq(int roomLocalId) async {
    final room = await _roomsDao.findByLocalId(roomLocalId);
    return room?.lastServerSeq ?? 0;
  }

  /// Tell the backend the conversation is read (durable, transport-agnostic).
  /// Enqueues an idempotent best-effort POST to [readPath] through the same
  /// outbox path the react/delete side-effects use, so the server unread counter
  /// doesn't bounce back after a refetch. [upToSeq] is the read high-water-mark
  /// the backend persists (and re-broadcasts as a seen receipt). The local badge
  /// is cleared separately via [clearUnread]; this only carries the read state
  /// to the backend.
  Future<void> markReadRemote({
    required int roomLocalId,
    required String readPath,
    required int upToSeq,
  }) async {
    await _outboxDao.enqueue(OutboxCompanion(
      opType: const Value(OutboxOpType.markRead),
      clientUuid: Value(_uuid.v4()),
      roomId: Value(roomLocalId),
      payloadJson:
          Value(jsonEncode({'__path': readPath, 'last_read_seq': upToSeq})),
      createdAt: Value(_clock()),
    ));
    _onEnqueued?.call();
  }

  /// Promote an own message to `delivered`/`read` from a server receipt.
  Future<void> setMessageState(String clientUuid, MessageState state) {
    return _messagesDao.updateState(clientUuid, state);
  }

  /// Local soft-delete marker (delete-for-me / delete-for-all).
  Future<void> setDeleteState(String clientUuid, MessageDeleteState state) {
    return _messagesDao.setDeleteState(clientUuid, state);
  }

  Future<void> setDraft(int roomLocalId, String? draft) =>
      _roomsDao.setDraft(roomLocalId, draft);

  // --- reactions / deletion (optimistic + best-effort sync) ------------------

  /// Toggle the current user's reaction on a message. Applies the change to the
  /// local row immediately (so the UI updates off the stream) and enqueues a
  /// best-effort sync op. [reactPath] is injected by the caller to keep this
  /// repository free of app endpoint constants.
  Future<void> react({
    required int roomLocalId,
    required int serverMessageId,
    required String reactType,
    required String reactPath,
  }) async {
    // The UI knows a message by its server id; resolve the local row to toggle
    // its cached reactions optimistically.
    final msg = await _messagesDao.findByServerMessageId(serverMessageId);
    if (msg == null) return;

    final updated = _toggleReact(msg.reactsJson, reactType, _currentUserId());
    await _messagesDao.setReactsByServerId(serverMessageId, updated);

    await _outboxDao.enqueue(OutboxCompanion(
      opType: const Value(OutboxOpType.react),
      clientUuid: Value(_uuid.v4()),
      roomId: Value(roomLocalId),
      payloadJson: Value(jsonEncode({
        '__path': reactPath,
        'message_id': serverMessageId,
        'react': reactType,
      })),
      createdAt: Value(_clock()),
    ));
    _onEnqueued?.call();
  }

  /// Delete messages (for-me or for-everyone). Marks the local rows immediately
  /// then enqueues a best-effort sync to [deletePath].
  Future<void> deleteMessages({
    required int roomLocalId,
    required List<int> serverMessageIds,
    required bool forEveryone,
    required String deletePath,
  }) async {
    if (serverMessageIds.isEmpty) return;

    await _messagesDao.setDeleteStateByServerIds(
      serverMessageIds,
      forEveryone
          ? MessageDeleteState.deletedForAll
          : MessageDeleteState.deletedForMe,
    );

    await _outboxDao.enqueue(OutboxCompanion(
      opType: const Value(OutboxOpType.delete),
      clientUuid: Value(_uuid.v4()),
      roomId: Value(roomLocalId),
      payloadJson: Value(jsonEncode({
        '__path': deletePath,
        // The server delete endpoints validate `id` (DeleteMessagesRequest /
        // DeleteForMeRequest: id required|array). The old `message_id` key failed
        // validation with a 422, which the outbox dropped silently — so the
        // server soft-delete + DeleteMessage broadcast never ran and the message
        // reappeared on the next sync. Use the contract key so the delete sticks.
        'id': serverMessageIds.map((e) => e.toString()).toList(),
      })),
      createdAt: Value(_clock()),
    ));
    _onEnqueued?.call();
  }

  /// Delete group messages FOR EVERYONE. Marks the affected local rows as
  /// deletedForAll immediately (so the open chat shows the tombstone off the
  /// stream) then enqueues a best-effort sync to [deletePath] using the server's
  /// `id` array contract. The server gate decides whether the caller may delete
  /// each id (own message for a member, anyone's for owner/admin); a forbidden id
  /// is rejected server-side and the outbox drops the op — the optimistic local
  /// state is reverted by the next sync only if the server still considers it
  /// visible, matching the 1:1 best-effort delete semantics.
  Future<void> deleteGroupMessages({
    required int roomLocalId,
    required List<int> serverMessageIds,
    required String deletePath,
  }) async {
    if (serverMessageIds.isEmpty) return;

    await _messagesDao.setDeleteStateByServerIds(
      serverMessageIds,
      MessageDeleteState.deletedForAll,
    );

    await _outboxDao.enqueue(OutboxCompanion(
      opType: const Value(OutboxOpType.delete),
      clientUuid: Value(_uuid.v4()),
      roomId: Value(roomLocalId),
      payloadJson: Value(jsonEncode({
        '__path': deletePath,
        'id': serverMessageIds.map((e) => e.toString()).toList(),
      })),
      createdAt: Value(_clock()),
    ));
    _onEnqueued?.call();
  }

  /// Apply a reaction toggle to the cached reactions JSON for [userId]:
  /// same emoji -> remove, different -> replace, none -> add. Returns null when
  /// the resulting list is empty so the column clears.
  static String? _toggleReact(String? raw, String reactType, int userId) {
    List<dynamic> list;
    try {
      final decoded = (raw == null || raw.isEmpty) ? <dynamic>[] : jsonDecode(raw);
      list = decoded is List ? List<dynamic>.from(decoded) : <dynamic>[];
    } catch (_) {
      list = <dynamic>[];
    }

    int indexOfMine() {
      for (var i = 0; i < list.length; i++) {
        final e = list[i];
        if (e is! Map) continue;
        final ur = e['userReact'];
        if (ur is Map && _eqInt(ur['userId'], userId)) return i;
      }
      return -1;
    }

    final idx = indexOfMine();
    if (idx >= 0) {
      final current = Map<String, dynamic>.from(list[idx] as Map);
      if ((current['react'] ?? '').toString() == reactType) {
        list.removeAt(idx); // toggle off
      } else {
        current['react'] = reactType; // switch emoji
        list[idx] = current;
      }
    } else {
      list.add({
        'react': reactType,
        'userReact': {'userId': userId},
      });
    }
    return list.isEmpty ? null : jsonEncode(list);
  }

  static bool _eqInt(dynamic a, int b) {
    if (a is int) return a == b;
    if (a is num) return a.toInt() == b;
    return int.tryParse(a?.toString() ?? '') == b;
  }

  static String _typeWire(MessageContentType type) {
    switch (type) {
      case MessageContentType.image:
        return 'image';
      case MessageContentType.audio:
        return 'audio';
      case MessageContentType.video:
        return 'video';
      case MessageContentType.cp:
        return 'CP';
      case MessageContentType.text:
        return 'text';
    }
  }
}

/// Stable handle to a conversation: its drift `local_id` + server id.
class RoomRef {
  const RoomRef({required this.localId, required this.serverRoomId});

  final int localId;
  final int serverRoomId;
}

/// Result of an optimistic [ChatRepository.send].
class SentMessage {
  const SentMessage({
    required this.clientUuid,
    required this.localId,
    this.alreadyQueued = false,
  });

  /// The dedup + idempotency key for this message across the whole stack.
  final String clientUuid;

  /// The drift `messages.local_id` of the optimistic row.
  final int localId;

  /// True when an identical [clientUuid] was already queued (double-send guard);
  /// no new row or outbox op was created.
  final bool alreadyQueued;
}

/// Fire-and-forget nudge so the outbox worker drains a freshly-enqueued op
/// immediately instead of waiting for its next tick.
typedef OutboxKick = void Function();
