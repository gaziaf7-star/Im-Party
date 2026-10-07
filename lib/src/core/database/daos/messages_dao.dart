import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/chat_tables.dart';

part 'messages_dao.g.dart';

@DriftAccessor(tables: [Messages])
class MessagesDao extends DatabaseAccessor<AppDatabase> with _$MessagesDaoMixin {
  MessagesDao(super.db);

  /// Reactive newest-first page for the open conversation.
  /// Ordering: server_seq DESC with NULLS FIRST so just-sent pending messages
  /// (null server_seq) sit at the newest position; created_at_client DESC
  /// breaks ties among pending rows.
  Stream<List<Message>> watchRoomMessages(int roomId, {int limit = 50}) {
    return (select(messages)
          ..where((m) => m.roomId.equals(roomId))
          ..orderBy([
            (m) => OrderingTerm(
                  expression: m.serverSeq,
                  mode: OrderingMode.desc,
                  nulls: NullsOrder.first,
                ),
            (m) => OrderingTerm(
                  expression: m.createdAtClient,
                  mode: OrderingMode.desc,
                ),
          ])
          ..limit(limit))
        .watch();
  }

  /// Keyset pagination (older page):
  /// WHERE room_id=? AND server_seq < ? ORDER BY server_seq DESC LIMIT n.
  /// No OFFSET — stable under inserts and index-backed.
  Future<List<Message>> getOlderPage({
    required int roomId,
    required int beforeServerSeq,
    int limit = 50,
  }) {
    return (select(messages)
          ..where((m) =>
              m.roomId.equals(roomId) &
              m.serverSeq.isNotNull() &
              m.serverSeq.isSmallerThanValue(beforeServerSeq))
          ..orderBy([
            (m) => OrderingTerm(
                  expression: m.serverSeq,
                  mode: OrderingMode.desc,
                ),
          ])
          ..limit(limit))
        .get();
  }

  Future<Message?> findByClientUuid(String clientUuid) {
    return (select(messages)..where((m) => m.clientUuid.equals(clientUuid)))
        .getSingleOrNull();
  }

  Future<Message?> findByServerMessageId(int serverMessageId) {
    return (select(messages)
          ..where((m) => m.serverMessageId.equals(serverMessageId)))
        .getSingleOrNull();
  }

  /// Insert an optimistic (pending) message. Caller supplies a fresh
  /// client_uuid; the UNIQUE constraint guards against double-send.
  Future<int> insertPending(MessagesCompanion entry) {
    return into(messages)
        .insert(entry, mode: InsertMode.insertOrIgnore);
  }

  /// Upsert an incoming/confirmed message with full dedup. Resolution order:
  /// 1) match an existing local row by client_uuid (our own optimistic send)
  /// 2) else match by server_message_id (already received via another path)
  /// 3) else insert fresh.
  /// Returns the resolved local_id. Idempotent — safe to call from both the
  /// REST send-ack path and the realtime publication path.
  Future<int> upsertFromServer(MessagesCompanion incoming) async {
    // A payload without an attachment (e.g. a lean realtime push or a text
    // echo) must never wipe the attachment an existing row already holds.
    final entry = (incoming.attachmentJson.present &&
            incoming.attachmentJson.value == null)
        ? incoming.copyWith(attachmentJson: const Value.absent())
        : incoming;
    return transaction(() async {
      if (entry.clientUuid.present) {
        final byUuid = await findByClientUuid(entry.clientUuid.value);
        if (byUuid != null) {
          // The canonical (uuid-matched) row is being stamped with its
          // serverMessageId. If that id is already held by a DIFFERENT row
          // (a `srv:<id>` phantom received over another path before this echo),
          // writing it would violate UNIQUE(serverMessageId) and abort the
          // whole transaction — dropping a live message + skipping its meta/
          // cursor update. Reconcile by deleting the duplicate phantom first so
          // the id can move onto its true (own optimistic) row.
          if (entry.serverMessageId.present &&
              entry.serverMessageId.value != null) {
            final bySid =
                await findByServerMessageId(entry.serverMessageId.value!);
            if (bySid != null && bySid.localId != byUuid.localId) {
              await (delete(messages)
                    ..where((m) => m.localId.equals(bySid.localId)))
                  .go();
            }
          }
          await (update(messages)
                ..where((m) => m.localId.equals(byUuid.localId)))
              .write(entry);
          return byUuid.localId;
        }
      }
      if (entry.serverMessageId.present && entry.serverMessageId.value != null) {
        final bySid =
            await findByServerMessageId(entry.serverMessageId.value!);
        if (bySid != null) {
          await (update(messages)
                ..where((m) => m.localId.equals(bySid.localId)))
              .write(entry);
          return bySid.localId;
        }
      }
      return into(messages).insert(entry);
    });
  }

  /// Promote a pending message to sent after the REST ack returns its
  /// server_message_id + server_seq. Also stamp serverStatus='sent' so the tick
  /// renderers (conversation + chats list) have an explicit single-check signal:
  /// the list mapper reads serverStatus and, with it null, would otherwise fall
  /// through to the default grey done_all (a double check) for a message that is
  /// only sent — not yet delivered/seen. A later read receipt overwrites this
  /// with 'seen' via [markMineSeenUpToSeq].
  Future<void> markSent({
    required String clientUuid,
    required int serverMessageId,
    required int serverSeq,
    int? serverCreatedAt,
  }) {
    return (update(messages)..where((m) => m.clientUuid.equals(clientUuid)))
        .write(MessagesCompanion(
      serverMessageId: Value(serverMessageId),
      serverSeq: Value(serverSeq),
      serverCreatedAt: Value(serverCreatedAt),
      state: const Value(MessageState.sent),
      serverStatus: const Value('sent'),
    ));
  }

  Future<void> updateState(String clientUuid, MessageState state) {
    return (update(messages)..where((m) => m.clientUuid.equals(clientUuid)))
        .write(MessagesCompanion(state: Value(state)));
  }

  /// Re-stamp a failed outbound message for a manual resend: flip it back to
  /// `pending` AND move its client timestamp to [createdAtClient] (now) so the
  /// row reorders to the bottom of the conversation with a fresh time instead of
  /// staying frozen at its original (old) position. A never-delivered message
  /// has no serverSeq, so ordering (serverSeq NULLS FIRST, createdAtClient) keys
  /// purely off this timestamp. Mirrors [updateState] but for the resend path.
  Future<void> requeueForRetry(String clientUuid, int createdAtClient) {
    return (update(messages)..where((m) => m.clientUuid.equals(clientUuid)))
        .write(MessagesCompanion(
      state: const Value(MessageState.pending),
      createdAtClient: Value(createdAtClient),
    ));
  }

  Future<void> markFailed(String clientUuid) =>
      updateState(clientUuid, MessageState.failed);

  Future<void> setDeleteState(
    String clientUuid,
    MessageDeleteState deleteState,
  ) {
    return (update(messages)..where((m) => m.clientUuid.equals(clientUuid)))
        .write(MessagesCompanion(deleteState: Value(deleteState)));
  }

  /// Largest server_seq stored locally for a room (gap-detection / sync cursor).
  Future<int?> maxServerSeq(int roomId) async {
    final maxExp = messages.serverSeq.max();
    final query = selectOnly(messages)
      ..addColumns([maxExp])
      ..where(messages.roomId.equals(roomId));
    final row = await query.getSingleOrNull();
    return row?.read(maxExp);
  }

  Future<int> deleteRoomMessages(int roomId) {
    return (delete(messages)..where((m) => m.roomId.equals(roomId))).go();
  }

  /// Remove phantom rows that were wrongly inserted from non-message realtime
  /// events (open_chat / getChatUsersBloc) before the event-name routing filtered
  /// them out: a user-kind text row with no body and no attachment whose
  /// client_uuid is the synthetic `srv:<id>` form (its server_message_id was
  /// actually a room id). A genuine user text message always carries a body and a
  /// genuine media row an attachment, so this never deletes a real message.
  /// `updates: {messages}` so the rooms/messages streams refresh after the purge.
  Future<int> purgePhantomMessages() {
    return customUpdate(
      "DELETE FROM messages WHERE kind = 0 AND type = 0 "
      "AND (body IS NULL OR body = '') AND attachment_json IS NULL "
      "AND client_uuid LIKE 'srv:%'",
      updates: {messages},
      updateKind: UpdateKind.delete,
    );
  }

  // --- feature-parity writers (reactions / receipts / attachments) ----------

  /// Replace the cached reactions JSON on an own (optimistic) message.
  Future<void> setReacts(String clientUuid, String? reactsJson) {
    return (update(messages)..where((m) => m.clientUuid.equals(clientUuid)))
        .write(MessagesCompanion(reactsJson: Value(reactsJson)));
  }

  /// Replace the cached reactions JSON on a server-identified message (the
  /// realtime `react-event` carries the server message id, not client_uuid).
  Future<void> setReactsByServerId(int serverMessageId, String? reactsJson) {
    return (update(messages)
          ..where((m) => m.serverMessageId.equals(serverMessageId)))
        .write(MessagesCompanion(reactsJson: Value(reactsJson)));
  }

  /// Store the raw server delivery status (e.g. 'seen') for a message.
  Future<void> setServerStatus(String clientUuid, String status) {
    return (update(messages)..where((m) => m.clientUuid.equals(clientUuid)))
        .write(MessagesCompanion(serverStatus: Value(status)));
  }

  /// Mark every message in a room as seen (legacy `open_chat` semantics):
  /// peer opened the conversation, so our delivered messages are now read.
  Future<void> markRoomSeen(int roomId) {
    return (update(messages)..where((m) => m.roomId.equals(roomId)))
        .write(const MessagesCompanion(serverStatus: Value('seen')));
  }

  /// Apply a realtime `status_update` read receipt: the peer read everything I
  /// sent in [roomId] up to [upToSeq], so flip MY messages (senderId==me) with
  /// server_seq <= upToSeq to read + serverStatus='seen'. Their own messages and
  /// my newer (not-yet-read) messages are untouched.
  Future<void> markMineSeenUpToSeq({
    required int roomId,
    required int upToSeq,
    required int myUserId,
  }) {
    return (update(messages)
          ..where((m) =>
              m.roomId.equals(roomId) &
              m.senderId.equals(myUserId) &
              m.serverSeq.isNotNull() &
              m.serverSeq.isSmallerOrEqualValue(upToSeq)))
        .write(const MessagesCompanion(
      state: Value(MessageState.read),
      serverStatus: Value('seen'),
    ));
  }

  /// Cache an attachment payload (image/audio/video) on a message.
  Future<void> setAttachment(String clientUuid, String? attachmentJson) {
    return (update(messages)..where((m) => m.clientUuid.equals(clientUuid)))
        .write(MessagesCompanion(attachmentJson: Value(attachmentJson)));
  }

  /// Apply a delete marker by server message id (realtime `delete-message`).
  Future<void> setDeleteStateByServerIds(
    List<int> serverMessageIds,
    MessageDeleteState deleteState,
  ) {
    if (serverMessageIds.isEmpty) return Future.value();
    return (update(messages)
          ..where((m) => m.serverMessageId.isIn(serverMessageIds)))
        .write(MessagesCompanion(deleteState: Value(deleteState)));
  }
}
