import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/chat_tables.dart';

part 'rooms_dao.g.dart';

/// The denormalized last-message preview for a conversation-list row, read
/// straight off the `rooms` columns (no join). [RoomToConversationMapper] uses
/// this to render the preview line + tick when [RoomWithLast.last] is absent
/// (the live list path). The search paths still pass a full [Message] as `last`.
class LastPreview {
  const LastPreview({
    this.text,
    this.type,
    this.senderId,
    this.serverMessageId,
    this.status,
    this.state,
    this.deleteState,
  });

  final String? text;
  final MessageContentType? type;
  final int? senderId;
  final int? serverMessageId;
  final String? status;
  final MessageState? state;
  final MessageDeleteState? deleteState;

  /// True when no last message has been recorded for the room yet.
  bool get isEmpty =>
      type == null &&
      (text == null || text!.isEmpty) &&
      serverMessageId == null &&
      state == null;

  static LastPreview fromRoom(Room room) {
    return LastPreview(
      text: room.lastPreviewText,
      type: room.lastPreviewType == null
          ? null
          : MessageContentType.values[room.lastPreviewType!],
      senderId: room.lastPreviewSenderId,
      serverMessageId: room.lastPreviewServerMessageId,
      status: room.lastPreviewStatus,
      state: room.lastPreviewState == null
          ? null
          : MessageState.values[room.lastPreviewState!],
      deleteState: room.lastPreviewDeleteState == null
          ? null
          : MessageDeleteState.values[room.lastPreviewDeleteState!],
    );
  }
}

/// A conversation-list row: the room plus its last-message preview. On the live
/// list path [preview] is read from the denormalized `rooms` columns (no join)
/// and [last] is null. The search/jump paths pass the matched [Message] as
/// [last]; consumers prefer [last] when present and fall back to [preview].
class RoomWithLast {
  const RoomWithLast({required this.room, this.last, LastPreview? preview})
      : _preview = preview;
  final Room room;
  final Message? last;
  final LastPreview? _preview;

  /// Denormalized preview for this row (never null): the explicit [_preview] when
  /// supplied (live list), otherwise derived from the [room] columns.
  LastPreview get preview => _preview ?? LastPreview.fromRoom(room);
}

/// A message search hit: the matched message plus the room it lives in (for the
/// avatar/title shown next to the highlighted snippet in search results).
class MessageHit {
  const MessageHit({required this.message, required this.room});
  final Message message;
  final Room room;
}

@DriftAccessor(tables: [Rooms, Messages])
class RoomsDao extends DatabaseAccessor<AppDatabase> with _$RoomsDaoMixin {
  RoomsDao(super.db);

  /// Reactive conversation list, newest activity first. The preview line + tick
  /// are read from the DENORMALIZED `rooms` columns (populated by
  /// applyIncomingMessageMeta / applyOutgoingMessageMeta), so the stream watches
  /// `rooms` ALONE and is no longer re-run on every message/reaction/receipt
  /// write in any room — only when a ROOM actually changes (which is exactly when
  /// the preview/order should update). Ordering is served by
  /// `idx_rooms_archived_updated`.
  Stream<List<RoomWithLast>> watchRoomsWithLast() {
    final query = select(rooms)
      ..where((r) => r.isArchived.equals(false))
      ..orderBy([
        (r) => OrderingTerm(expression: r.updatedAt, mode: OrderingMode.desc),
      ]);
    return query.watch().map(
          (rows) => rows
              .map((room) => RoomWithLast(
                    room: room,
                    preview: LastPreview.fromRoom(room),
                  ))
              .toList(),
        );
  }

  Stream<Room?> watchRoomByLocalId(int localId) {
    return (select(rooms)..where((r) => r.localId.equals(localId)))
        .watchSingleOrNull();
  }

  /// Conversations whose title matches [query] (name search for the inline
  /// chats search). Includes the last message so the result row mirrors the list.
  Future<List<RoomWithLast>> searchRooms(String query) async {
    final like = '%${query.trim()}%';
    final q = select(rooms).join([
      leftOuterJoin(
        messages,
        messages.localId.equalsExp(rooms.lastMessageLocalId),
      ),
    ])
      ..where(rooms.isArchived.equals(false) & rooms.title.like(like))
      ..orderBy([
        OrderingTerm(expression: rooms.updatedAt, mode: OrderingMode.desc),
      ]);
    final rows = await q.get();
    return rows
        .map((row) => RoomWithLast(
              room: row.readTable(rooms),
              last: row.readTableOrNull(messages),
            ))
        .toList();
  }

  /// Full-text-ish message search across ALL conversations (offline, from the
  /// local cache). Matches the message body and returns each hit with its room
  /// for the WhatsApp-style highlighted snippet. Deleted-for-all rows are
  /// filtered out in Dart (small result set).
  Future<List<MessageHit>> searchMessages(String query, {int limit = 60}) async {
    final like = '%${query.trim()}%';
    final q = select(messages).join([
      innerJoin(rooms, rooms.localId.equalsExp(messages.roomId)),
    ])
      ..where(messages.body.like(like))
      ..orderBy([
        OrderingTerm(
          expression: messages.serverCreatedAt,
          mode: OrderingMode.desc,
        ),
      ])
      ..limit(limit);
    final rows = await q.get();
    return rows
        .map((row) => MessageHit(
              message: row.readTable(messages),
              room: row.readTable(rooms),
            ))
        .where((hit) =>
            hit.message.deleteState != MessageDeleteState.deletedForAll &&
            (hit.message.body ?? '').isNotEmpty)
        .toList();
  }

  Future<Room?> findByServerRoomId(int serverRoomId) {
    return (select(rooms)..where((r) => r.serverRoomId.equals(serverRoomId)))
        .getSingleOrNull();
  }

  /// Find the best existing DM room by the peer's user ID.
  /// Prefers rooms with a known server ID (not 0) to avoid returning a stale
  /// orphan. Safe when multiple duplicates exist — returns the first valid one.
  Future<Room?> findByPeerUserId(int peerUserId) async {
    final rows = await (select(rooms)
          ..where((r) =>
              r.peerUserId.equals(peerUserId) &
              r.type.equalsValue(RoomType.dm))
          ..orderBy([(r) => OrderingTerm.desc(r.serverRoomId)]))
        .get();
    if (rows.isEmpty) return null;
    // Prefer rows with a real serverRoomId (> 0); fall back to any match.
    return rows.firstWhere((r) => (r.serverRoomId ?? 0) > 0,
        orElse: () => rows.first);
  }

  Future<Room?> findByLocalId(int localId) {
    return (select(rooms)..where((r) => r.localId.equals(localId)))
        .getSingleOrNull();
  }

  /// Upsert a room keyed by server_room_id. Returns the room's local_id.
  /// Used when reconciling the room list / first message of a server room.
  ///
  /// When a REAL room (serverRoomId > 0) is materialized for a DM peer, this
  /// also deletes any leftover ORPHAN row for the same peer (serverRoomId 0/null,
  /// created when a chat was opened from a profile before the server id was
  /// known). Without this the chats list shows two rows for one person — the
  /// real one (correct avatar) and the orphan (app-logo). This runs at the single
  /// merge point every real-room create path flows through (list sync, realtime
  /// first-message, openConversation), so the duplicate never lingers.
  Future<int> upsertByServerRoomId(RoomsCompanion entry) async {
    return transaction(() async {
      int realLocalId;
      if (entry.serverRoomId.present && entry.serverRoomId.value != null) {
        final existing = await findByServerRoomId(entry.serverRoomId.value!);
        if (existing != null) {
          await (update(rooms)..where((r) => r.localId.equals(existing.localId)))
              .write(entry);
          realLocalId = existing.localId;
        } else {
          realLocalId = await into(rooms).insert(entry);
        }
      } else {
        return into(rooms).insert(entry);
      }

      // Orphan cleanup: only for real DM rooms that carry a peerUserId.
      final sid = entry.serverRoomId.value ?? 0;
      final isDm = entry.type.present && entry.type.value == RoomType.dm;
      if (sid > 0 && isDm) {
        int? peerId;
        if (entry.peerUserId.present) {
          peerId = entry.peerUserId.value;
        } else {
          peerId = (await findByLocalId(realLocalId))?.peerUserId;
        }
        if (peerId != null) {
          // Find the orphan DM rows for this peer (serverRoomId null/0) that are
          // about to be removed in favour of the real room.
          final orphans = await (select(rooms)
                ..where((r) =>
                    r.peerUserId.equals(peerId!) &
                    r.type.equalsValue(RoomType.dm) &
                    r.localId.isNotValue(realLocalId) &
                    (r.serverRoomId.isNull() | r.serverRoomId.equals(0))))
              .get();
          for (final orphan in orphans) {
            // CRITICAL: migrate the orphan's messages onto the surviving real
            // room BEFORE deleting it. messages.roomId has onDelete:cascade, so
            // deleting an orphan that still holds messages would permanently
            // destroy them (the original B1 data-loss bug).
            await _migrateMessages(
              fromRoomLocalId: orphan.localId,
              toRoomLocalId: realLocalId,
            );
            await (delete(rooms)..where((r) => r.localId.equals(orphan.localId)))
                .go();
          }
        }
      }
      return realLocalId;
    });
  }

  /// Re-parents every message from [fromRoomLocalId] onto [toRoomLocalId] in a
  /// single set-based UPDATE, so an orphan DM room can be deleted without losing
  /// its messages to the FK cascade. `messages.client_uuid` is UNIQUE, so a
  /// message already present in the target room (same uuid received over another
  /// path) would collide; `OR IGNORE` skips those duplicates and the orphan's
  /// stale copy is then dropped with the orphan room. `updates: {messages}` so
  /// the conversation stream refreshes once the rows move.
  Future<void> _migrateMessages({
    required int fromRoomLocalId,
    required int toRoomLocalId,
  }) async {
    await customUpdate(
      'UPDATE OR IGNORE messages SET room_id = ? WHERE room_id = ?',
      variables: [
        Variable.withInt(toRoomLocalId),
        Variable.withInt(fromRoomLocalId),
      ],
      updates: {messages},
      updateKind: UpdateKind.update,
    );
  }

  /// Atomic get-or-create for a 1:1 DM room. Resolves the peer to a SINGLE local
  /// room and reconciles duplicates in one transaction, so a peer can never end
  /// up with two rooms regardless of which path (profile open, realtime first
  /// message, list sync) materializes the room first.
  ///
  /// - serverRoomId > 0: routes through [upsertByServerRoomId], which keys on the
  ///   server id and (with message migration) folds any orphan for this peer in.
  /// - serverRoomId == 0/unknown (opened from a profile before the chat id is
  ///   known): reuse the peer's existing room if any (real one preferred); only
  ///   when none exists create the placeholder. This avoids spawning a second
  ///   orphan next to a row that already holds the conversation.
  ///
  /// Returns the surviving room's local_id.
  Future<int> getOrCreateDmRoom({
    required int serverRoomId,
    int? peerUserId,
    String? title,
    String? avatarUrl,
  }) async {
    return transaction(() async {
      final meta = RoomsCompanion(
        serverRoomId: Value(serverRoomId),
        type: const Value(RoomType.dm),
        peerUserId:
            peerUserId == null ? const Value.absent() : Value(peerUserId),
        title: title == null ? const Value.absent() : Value(title),
        avatarUrl: avatarUrl == null ? const Value.absent() : Value(avatarUrl),
      );

      if (serverRoomId > 0) {
        return upsertByServerRoomId(meta);
      }

      // Unknown server id: bind to the peer's existing room when present so we
      // never create a duplicate alongside it.
      if (peerUserId != null) {
        final existing = await findByPeerUserId(peerUserId);
        if (existing != null) {
          await (update(rooms)
                ..where((r) => r.localId.equals(existing.localId)))
              .write(RoomsCompanion(
            title: title == null ? const Value.absent() : Value(title),
            avatarUrl:
                avatarUrl == null ? const Value.absent() : Value(avatarUrl),
          ));
          return existing.localId;
        }
      }
      return into(rooms).insert(meta);
    });
  }

  Future<int> insertRoom(RoomsCompanion entry) => into(rooms).insert(entry);

  Future<bool> updateRoom(int localId, RoomsCompanion entry) async {
    final count = await (update(rooms)
          ..where((r) => r.localId.equals(localId)))
        .write(entry);
    return count > 0;
  }

  /// Bump denormalized last-message pointers + sequence after a new message.
  Future<void> applyIncomingMessageMeta({
    required int roomLocalId,
    required int lastMessageLocalId,
    required int serverSeq,
    required int serverCreatedAt,
    bool incrementUnread = false,
  }) async {
    await transaction(() async {
      final room = await findByLocalId(roomLocalId);
      if (room == null) return;
      // Only treat this as genuinely new when the seq advances. A 1:1 message is
      // published to BOTH the shared chat:dm channel AND the recipient's
      // user:#{id} channel, so when the conversation is open the SAME publication
      // is applied twice; Centrifugo recovery can also re-deliver it. The row is
      // de-duped by upsertFromServer, but the unread bump must be idempotent too —
      // gate it on the seq actually advancing so the badge never double-counts.
      final advanced = serverSeq > room.lastServerSeq;
      final newLastSeq = advanced ? serverSeq : room.lastServerSeq;
      // The last-message pointer + ordering timestamp must only move FORWARD.
      // A re-delivered / out-of-order publication (dual-channel 1:1 fan-out,
      // recovery replay, gap-fill) carries a seq that does NOT advance the room;
      // writing its older row as `lastMessage` would rewind the chats-list
      // preview + reorder the room downwards (flicker + stale preview). Only
      // re-stamp them when the seq genuinely advanced — or when the room has no
      // pointer yet (first message of a freshly-created room).
      final setLast = advanced || room.lastMessageLocalId == null;
      // Denormalize the new last message's preview onto the room (only when the
      // pointer actually advances), so the conversation-list stream renders the
      // preview/tick without re-joining `messages`. Computed from the just-stored
      // row — the single source of truth for both this path and the upgrade
      // backfill.
      final preview = setLast ? await _lastPreviewFor(lastMessageLocalId) : null;
      await (update(rooms)..where((r) => r.localId.equals(roomLocalId))).write(
        RoomsCompanion(
          lastMessageLocalId:
              setLast ? Value(lastMessageLocalId) : const Value.absent(),
          lastServerSeq: Value(newLastSeq),
          updatedAt: setLast ? Value(serverCreatedAt) : const Value.absent(),
          unreadCount: (incrementUnread && advanced)
              ? Value(room.unreadCount + 1)
              : const Value.absent(),
          lastPreviewText: preview?.text ?? const Value.absent(),
          lastPreviewType: preview?.type ?? const Value.absent(),
          lastPreviewSenderId: preview?.senderId ?? const Value.absent(),
          lastPreviewServerMessageId:
              preview?.serverMessageId ?? const Value.absent(),
          lastPreviewStatus: preview?.status ?? const Value.absent(),
          lastPreviewState: preview?.state ?? const Value.absent(),
          lastPreviewDeleteState: preview?.deleteState ?? const Value.absent(),
        ),
      );
    });
  }

  /// Bump the denormalized last-message pointer + ordering timestamp for a
  /// locally sent (still `pending`) message, so the chats list reorders and
  /// refreshes its preview the instant the message is sent — instead of only
  /// after the server echo arrives. Unlike [applyIncomingMessageMeta] this never
  /// touches `lastServerSeq` (an outgoing message has no server_seq yet) nor
  /// `unreadCount` (my own message must not bump my unread).
  Future<void> applyOutgoingMessageMeta({
    required int roomLocalId,
    required int lastMessageLocalId,
    required int createdAtClient,
  }) async {
    await transaction(() async {
      final preview = await _lastPreviewFor(lastMessageLocalId);
      await (update(rooms)..where((r) => r.localId.equals(roomLocalId))).write(
        RoomsCompanion(
          lastMessageLocalId: Value(lastMessageLocalId),
          updatedAt: Value(createdAtClient),
          lastPreviewText: preview.text,
          lastPreviewType: preview.type,
          lastPreviewSenderId: preview.senderId,
          lastPreviewServerMessageId: preview.serverMessageId,
          lastPreviewStatus: preview.status,
          lastPreviewState: preview.state,
          lastPreviewDeleteState: preview.deleteState,
        ),
      );
    });
  }

  /// Re-stamp ONLY the denormalized last-message preview columns for [roomLocalId]
  /// from its current `last_message_local_id` row, WITHOUT touching ordering
  /// (`updated_at`) or the pointer. Called after a writer mutates a message's
  /// status / reaction / delete-state so the list tick/preview stays fresh even
  /// though the list stream no longer joins `messages`. A no-op when the room has
  /// no last message yet.
  Future<void> refreshLastMessagePreview(int roomLocalId) async {
    await transaction(() async {
      final room = await findByLocalId(roomLocalId);
      if (room == null || room.lastMessageLocalId == null) return;
      final preview = await _lastPreviewFor(room.lastMessageLocalId!);
      await (update(rooms)..where((r) => r.localId.equals(roomLocalId))).write(
        RoomsCompanion(
          lastPreviewText: preview.text,
          lastPreviewType: preview.type,
          lastPreviewSenderId: preview.senderId,
          lastPreviewServerMessageId: preview.serverMessageId,
          lastPreviewStatus: preview.status,
          lastPreviewState: preview.state,
          lastPreviewDeleteState: preview.deleteState,
        ),
      );
    });
  }

  /// Build the denormalized preview column values for the message at
  /// [messageLocalId]. Mirrors the columns the upgrade backfill copies. All
  /// `Value.absent()` when the message row is gone (defensive — pointer should
  /// always reference a live row).
  Future<_PreviewCompanion> _lastPreviewFor(int messageLocalId) async {
    final m = await (select(messages)
          ..where((x) => x.localId.equals(messageLocalId)))
        .getSingleOrNull();
    if (m == null) return const _PreviewCompanion.absent();
    return _PreviewCompanion(
      text: Value(m.body),
      type: Value(m.type.index),
      senderId: Value(m.senderId),
      serverMessageId: Value(m.serverMessageId),
      status: Value(m.serverStatus),
      state: Value(m.state.index),
      deleteState: Value(m.deleteState.index),
    );
  }

  /// Mark a room read up to [upToSeq]; clears unread when caught up.
  Future<void> markRead(int roomLocalId, int upToSeq) async {
    await transaction(() async {
      final room = await findByLocalId(roomLocalId);
      if (room == null) return;
      if (upToSeq <= room.myLastReadSeq) return;
      // Reaching (or passing) the room's high-water-mark means everything is
      // read → unread is exactly 0. Deriving `lastServerSeq - upToSeq` from the
      // raw seq SPAN overcounts: the span includes MY OWN messages (which were
      // never unread), inflating the badge after reading a conversation with
      // back-and-forth traffic. Only a read that stops SHORT of the HWM leaves a
      // genuine remainder, and even then the span is an upper bound — so clamp
      // to a full clear at the HWM and otherwise leave the existing count alone
      // rather than re-deriving an inflated number.
      final caughtUp = upToSeq >= room.lastServerSeq;
      await (update(rooms)..where((r) => r.localId.equals(roomLocalId))).write(
        RoomsCompanion(
          myLastReadSeq: Value(upToSeq),
          unreadCount: caughtUp ? const Value(0) : const Value.absent(),
        ),
      );
    });
  }

  /// Fully clear a room's unread (open-conversation = everything read). Sets
  /// my_last_read_seq to the room's high-water-mark and unread_count to 0.
  Future<void> clearUnread(int roomLocalId) async {
    await transaction(() async {
      final room = await findByLocalId(roomLocalId);
      if (room == null) return;
      await (update(rooms)..where((r) => r.localId.equals(roomLocalId))).write(
        RoomsCompanion(
          myLastReadSeq: Value(room.lastServerSeq),
          unreadCount: const Value(0),
        ),
      );
    });
  }

  Future<void> setDraft(int roomLocalId, String? draft) {
    return (update(rooms)..where((r) => r.localId.equals(roomLocalId)))
        .write(RoomsCompanion(draftText: Value(draft)));
  }

  Future<int> deleteRoom(int localId) {
    return (delete(rooms)..where((r) => r.localId.equals(localId))).go();
  }

  /// Deletes the room for [serverRoomId]. Used when a group is deleted/left or
  /// reported gone by the server, where only the server room id is known. A no-op
  /// (returns 0) when the room was never materialized locally.
  Future<int> deleteRoomByServerRoomId(int serverRoomId) {
    return (delete(rooms)..where((r) => r.serverRoomId.equals(serverRoomId)))
        .go();
  }

  /// Deletes the 1:1 room for [peerUserId]. Used when clearing a conversation
  /// from inside the messages screen, where only the peer id is known.
  Future<int> deleteRoomByPeer(int peerUserId) {
    return (delete(rooms)..where((r) => r.peerUserId.equals(peerUserId))).go();
  }

  /// Removes phantom 1:1 rooms that carry no real [serverRoomId] but whose peer
  /// already has a sibling row with a real serverRoomId (> 0). Such orphans are
  /// created when a Centrifugo message arrives before the rooms-list sync; left
  /// in place they surface as a duplicate conversation (with the app-logo
  /// avatar, since they have no peer metadata). Returns the number removed.
  ///
  /// Runs in a single transaction so each orphan's messages are migrated onto
  /// the surviving real room BEFORE the orphan is deleted — without this the FK
  /// cascade on `messages.roomId` would permanently destroy the orphan's
  /// messages (the original B1 data-loss bug).
  Future<int> deleteOrphanDmRooms() async {
    return transaction(() async {
      final all =
          await (select(rooms)..where((r) => r.peerUserId.isNotNull())).get();
      // Map each peer to its surviving real room (serverRoomId > 0), preferring
      // the highest serverRoomId so the migration target is deterministic.
      final realRoomForPeer = <int, int>{}; // peerUserId -> room.localId
      final realServerIdForPeer = <int, int>{}; // peerUserId -> serverRoomId
      for (final r in all) {
        if ((r.serverRoomId ?? 0) > 0 && r.peerUserId != null) {
          final bestSid = realServerIdForPeer[r.peerUserId!];
          if (bestSid == null || r.serverRoomId! > bestSid) {
            realServerIdForPeer[r.peerUserId!] = r.serverRoomId!;
            realRoomForPeer[r.peerUserId!] = r.localId;
          }
        }
      }
      var removed = 0;
      for (final r in all) {
        if ((r.serverRoomId ?? 0) <= 0 &&
            r.peerUserId != null &&
            realRoomForPeer.containsKey(r.peerUserId)) {
          await _migrateMessages(
            fromRoomLocalId: r.localId,
            toRoomLocalId: realRoomForPeer[r.peerUserId]!,
          );
          removed +=
              await (delete(rooms)..where((x) => x.localId.equals(r.localId)))
                  .go();
        }
      }
      return removed;
    });
  }
}

/// Internal carrier of the denormalized last-message preview column values,
/// mapped directly onto the corresponding [RoomsCompanion] fields. Each field is
/// a drift [Value] so an absent message produces `Value.absent()` everywhere.
class _PreviewCompanion {
  const _PreviewCompanion({
    required this.text,
    required this.type,
    required this.senderId,
    required this.serverMessageId,
    required this.status,
    required this.state,
    required this.deleteState,
  });

  const _PreviewCompanion.absent()
      : text = const Value.absent(),
        type = const Value.absent(),
        senderId = const Value.absent(),
        serverMessageId = const Value.absent(),
        status = const Value.absent(),
        state = const Value.absent(),
        deleteState = const Value.absent();

  final Value<String?> text;
  final Value<int?> type;
  final Value<int?> senderId;
  final Value<int?> serverMessageId;
  final Value<String?> status;
  final Value<int?> state;
  final Value<int?> deleteState;
}
