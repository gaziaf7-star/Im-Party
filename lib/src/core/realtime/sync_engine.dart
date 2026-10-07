import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:general/src/core/database/app_database.dart';
import 'package:general/src/core/database/db_contention.dart';
import 'package:general/src/core/database/daos/messages_dao.dart';
import 'package:general/src/core/database/daos/rooms_dao.dart';
import 'package:general/src/core/database/daos/sync_state_dao.dart';
import 'package:general/src/core/database/tables/chat_tables.dart';
import 'package:general/src/core/realtime/realtime_http.dart';
import 'package:general/src/core/realtime/realtime_message_mapper.dart';
import 'package:general/src/features/auth/data/model/my_data_model.dart';

/// REST gap-filler + recovery fallback (Plan section 7.3).
///
/// Drives the local store back to consistency with the server whenever the
/// realtime channel cannot guarantee it:
///  - on conversation open / reconnect (catch up from `my_last_read_seq`),
///  - when a publication arrives with a `server_seq` larger than expected
///    (a gap — fetch the missing range),
///  - when Centrifugo signals `recovered:false` or the channel `epoch` changed
///    (history was lost — full room resync).
///
/// All DB access goes through the injected DAOs and all HTTP through
/// [DioFactory], so the engine is exercisable with an in-memory drift database
/// and a stubbed dio in unit tests.
class SyncEngine {
  SyncEngine({
    required RealtimeHttp http,
    required MessagesDao messagesDao,
    required RoomsDao roomsDao,
    required SyncStateDao syncStateDao,
    required SinceSeqUrlBuilder sinceSeqUrl,
    BeforeSeqUrlBuilder? beforeSeqUrl,
    String? roomsListUrl,
    RealtimeMessageMapper mapper = const RealtimeMessageMapper(),
    RecoverableDbErrorReporter? onRecoverableDbError,
  })  : _http = http,
        _messagesDao = messagesDao,
        _roomsDao = roomsDao,
        _syncStateDao = syncStateDao,
        _sinceSeqUrl = sinceSeqUrl,
        _beforeSeqUrl = beforeSeqUrl,
        _roomsListUrl = roomsListUrl,
        _mapper = mapper,
        _onRecoverableDbError = onRecoverableDbError;

  final RealtimeHttp _http;
  final SinceSeqUrlBuilder _sinceSeqUrl;
  final BeforeSeqUrlBuilder? _beforeSeqUrl;
  final String? _roomsListUrl;
  final MessagesDao _messagesDao;
  final RoomsDao _roomsDao;
  final SyncStateDao _syncStateDao;
  final RealtimeMessageMapper _mapper;
  final RecoverableDbErrorReporter? _onRecoverableDbError;

  /// SQLITE_BUSY/LOCKED inside a sync is transient (another writer held the
  /// lock past busy_timeout): record it as non-fatal and bail — the next
  /// reconnect/open/tick re-runs the same idempotent sync. Anything else
  /// rethrows unchanged.
  Future<int> _guardedAgainstLock(
    String context,
    Future<int> Function() body,
  ) async {
    try {
      return await body();
    } catch (e, s) {
      if (!isDbLockedError(e)) rethrow;
      _onRecoverableDbError?.call(
          e, s, 'SyncEngine.$context: database locked — retried on next sync');
      return 0;
    }
  }

  /// Guards against overlapping rooms-list syncs.
  bool _roomsListInFlight = false;
  bool _phantomsPurged = false;

  /// Guards against two overlapping syncs racing the same room.
  final Set<int> _inFlight = <int>{};

  /// Catch a room up from the highest seq we already hold. Used on open and on
  /// reconnect. No-op while another sync for the same room is running.
  ///
  /// Returns the number of messages applied.
  Future<int> syncRoom({
    required int roomLocalId,
    required int serverRoomId,
  }) async {
    // Defense-in-depth: never run a room sync against an unresolved server id —
    // it would hit GET /api/v1/rooms/0/messages (404). The open path resolves
    // the real id before calling here, but a stray caller must not bypass that.
    if (serverRoomId <= 0) return 0;
    if (_inFlight.contains(roomLocalId)) return 0;
    _inFlight.add(roomLocalId);
    try {
      return await _guardedAgainstLock('syncRoom', () async {
        final sinceSeq = await _recoveryCursor(roomLocalId);
        return _fetchAndApply(
          roomLocalId: roomLocalId,
          serverRoomId: serverRoomId,
          sinceSeq: sinceSeq,
        );
      });
    } finally {
      _inFlight.remove(roomLocalId);
    }
  }

  /// Cold-open backfill: pull the NEWEST page of a room's history via
  /// `?before_seq=<max>` and upsert it into drift, so an opened conversation
  /// shows recent messages immediately — even when the forward `since_seq`
  /// cursor has already advanced past the locally-held rows (which makes
  /// [syncRoom] return nothing and leaves the screen empty/sparse). Does NOT
  /// move the forward recovery cursor nor the room's last-message pointer; it
  /// only guarantees the message rows exist locally for the stream to render.
  /// Returns the number of messages applied. No-op without a `beforeSeqUrl`.
  Future<int> backfillLatest({
    required int roomLocalId,
    required int serverRoomId,
    int limit = 50,
  }) async {
    // Defense-in-depth: an unresolved server id would request the newest page
    // of room 0 (404). Skip — the local cache renders and the next sync fills in.
    if (serverRoomId <= 0) return 0;
    final builder = _beforeSeqUrl;
    if (builder == null) return 0;
    try {
      // before_seq returns messages with seq < N (newest-first); a max int
      // grabs the absolute latest page.
      final response =
          await _http.get(builder(serverRoomId, 2147483647, limit: limit));
      final items = _extractList(response.data);
      var applied = 0;
      for (final raw in items) {
        if (raw is! Map) continue;
        final companion = _mapper.toCompanion(
          Map<String, dynamic>.from(raw),
          roomLocalId: roomLocalId,
        );
        if (companion == null) continue;
        try {
          await _messagesDao.upsertFromServer(companion);
          applied++;
          if (raw['type'] == 'img') {
            debugPrint('[ChatImage] backfill upsert id=${raw['id']} attachmentJson=${companion.attachmentJson.value}');
          }
        } catch (e) {
          debugPrint('[ChatImage] backfill upsert FAILED id=${raw['id']} err=$e');
        }
      }
      return applied;
    } catch (e) {
      debugPrint('[ChatImage] backfill FAILED err=$e');
      return 0; // best-effort; the forward sync + local cache still stand
    }
  }

  /// Seed/refresh the WHOLE conversation list into drift from
  /// `GET /api/v1/sync/rooms`. This is the cold-start + reconnect entry point for
  /// the chats list, which now reads from drift (the local source of truth).
  /// Each room header is upserted (name/avatar/peer/role/seq/unread/updatedAt)
  /// and its last message is persisted so the list shows the preview + time.
  /// No-op when no rooms-list URL was provided or a sync is already running.
  /// Returns the number of room headers applied.
  Future<int> syncRoomsList() async {
    final url = _roomsListUrl;
    if (url == null || _roomsListInFlight) return 0;
    _roomsListInFlight = true;
    try {
      return await _guardedAgainstLock('syncRoomsList', () async {
        // One-time cleanup of phantom empty rows left by the pre-routing bug.
        if (!_phantomsPurged) {
          _phantomsPurged = true;
          try {
            await _messagesDao.purgePhantomMessages();
          } catch (_) {/* cleanup must never block the rooms sync */}
        }
        final response = await _http.get(url);
        final items = _extractList(response.data);
        var applied = 0;
        try {
          // ONE transaction for the whole list: a single write-lock
          // acquisition + commit instead of 2-3 standalone writes per room.
          // The per-room write storm raced the outbox/realtime writers and
          // was the main SQLITE_BUSY ("database is locked") crash source.
          await _roomsDao.transaction(() async {
            for (final raw in items) {
              if (raw is! Map) continue;
              await _applyRoomHeader(Map<String, dynamic>.from(raw));
              applied++;
            }
          });
        } on CouldNotRollBackException {
          // The drift isolate is gone (app teardown mid-sync). Stop quietly —
          // the next launch re-runs the full rooms sync anyway.
          return 0;
        }
        // After the authoritative server list is applied, drop any phantom 1:1
        // rooms (no real serverRoomId) whose peer now has a real room — these
        // are the duplicate conversations that showed the app-logo avatar.
        try {
          await _roomsDao.deleteOrphanDmRooms();
        } catch (_) {/* cleanup must never block the rooms sync */}
        return applied;
      });
    } finally {
      _roomsListInFlight = false;
    }
  }

  /// Upsert a single `GET /sync/rooms` row into drift (room header + its last
  /// message). Group rooms read name/avatar from the embedded `group`; 1:1 rooms
  /// read `title`/`avatar`/`peer_user_id` injected by [SyncRoomResource].
  Future<void> _applyRoomHeader(Map<String, dynamic> json) async {
    final serverRoomId = _asInt(json['room_id']);
    if (serverRoomId == null) return;

    final isGroup = json['type']?.toString() == 'group';
    final group =
        json['group'] is Map ? Map<String, dynamic>.from(json['group']) : null;

    final title = isGroup
        ? (group == null ? null : group['name']?.toString())
        : json['title']?.toString();
    final avatar = isGroup
        ? (group == null ? null : group['avatar']?.toString())
        : json['avatar']?.toString();
    final peerUserId = isGroup ? null : _asInt(json['peer_user_id']);
    final groupId = (isGroup && group != null) ? _asInt(group['id']) : null;
    final memberCount =
        (isGroup && group != null) ? (_asInt(group['members_count']) ?? 0) : 0;
    final myRole = json['my_role']?.toString();
    final lastSeq = _asInt(json['last_seq']) ?? 0;
    final myLastReadSeq = _asInt(json['my_last_read_seq']) ?? 0;
    // Compute unread from the (consistent) seq pair rather than the server's
    // `unread_count` field, which can be stale/off-by-one for groups (observed
    // 46 while last_seq==my_last_read_seq==45 → must be 0). Computing it here
    // keeps a freshly-opened room's badge at 0 after mark-read instead of the
    // rooms-list sync re-stamping a stale count over the local clear.
    final unread = lastSeq > myLastReadSeq ? lastSeq - myLastReadSeq : 0;

    final lastMsgJson = json['last_message'] is Map
        ? Map<String, dynamic>.from(json['last_message'])
        : null;

    // Order rooms by the LAST MESSAGE's own timestamp — the same basis the
    // realtime path stamps updatedAt from. The room's `last_message_at` column is
    // written in a different timezone basis than message timestamps (observed ~3h
    // ahead), which floated stale rooms above freshly-active ones; so the nested
    // message's created_at wins when present, and last_message_at is only a
    // fallback for rooms with no last_message object.
    final updatedAt = (lastMsgJson != null
            ? _epochOf(lastMsgJson['server_created_at'] ?? lastMsgJson['created_at'])
            : null) ??
        _epochOf(json['last_message_at']) ??
        _epochOf(json['updated_at']) ??
        DateTime.now().millisecondsSinceEpoch;

    final localId = await _roomsDao.upsertByServerRoomId(RoomsCompanion(
      serverRoomId: Value(serverRoomId),
      type: Value(isGroup ? RoomType.group : RoomType.dm),
      title: title == null ? const Value.absent() : Value(title),
      avatarUrl: avatar == null ? const Value.absent() : Value(avatar),
      peerUserId: peerUserId == null ? const Value.absent() : Value(peerUserId),
      groupId: groupId == null ? const Value.absent() : Value(groupId),
      memberCount: Value(memberCount),
      myRole: myRole == null ? const Value.absent() : Value(myRole),
      lastServerSeq: Value(lastSeq),
      myLastReadSeq: Value(myLastReadSeq),
      unreadCount: Value(unread),
      updatedAt: Value(updatedAt),
    ));

    if (lastMsgJson != null) {
      final companion = _mapper.toCompanion(lastMsgJson, roomLocalId: localId);
      if (companion != null) {
        try {
          if (lastMsgJson['type'] == 'img') {
            debugPrint(
                '[ChatImage] rooms-sync upsert id=${lastMsgJson['id']} albumsRaw=${lastMsgJson['albums']} -> attachmentJson=${companion.attachmentJson.value}');
          }
          await _messagesDao.upsertFromServer(companion);
          final msgLocalId = await _resolveLocalId(lastMsgJson, localId);
          if (msgLocalId != null) {
            await _roomsDao.updateRoom(
              localId,
              RoomsCompanion(lastMessageLocalId: Value(msgLocalId)),
            );
          }
        } catch (e) {
          debugPrint(
              '[ChatImage] rooms-sync upsert FAILED id=${lastMsgJson['id']} err=$e');
          // A bad last-message row must not abort applying the room header.
        }
      }
    }
  }

  /// Parse an epoch (int/num) or ISO-8601 string into ms-since-epoch.
  static int? _epochOf(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    final parsed = DateTime.tryParse(v.toString());
    return parsed?.millisecondsSinceEpoch;
  }

  /// Fill a detected gap: a publication carried [expectedAfterSeq] but the
  /// local max BEFORE that publication was applied ([beforeMax]) is lower, so the
  /// range in between must be pulled over REST. Only fetches when there is an
  /// actual hole.
  ///
  /// [beforeMax] MUST be the local max captured by the caller *before* it stored
  /// the publication — reading it here (after the row is upserted) would see the
  /// jumped seq and mask the hole, and would fetch from the wrong cursor.
  Future<int> fillGap({
    required int roomLocalId,
    required int serverRoomId,
    required int expectedAfterSeq,
    required int beforeMax,
  }) async {
    // Defense-in-depth: a gap fill needs a real room id (the range fetch hits
    // /api/v1/rooms/<id>/messages). Bail on an unresolved id rather than 404.
    if (serverRoomId <= 0) return 0;
    if (expectedAfterSeq <= beforeMax + 1) return 0;
    return _guardedAgainstLock(
      'fillGap',
      () => _fetchAndApply(
        roomLocalId: roomLocalId,
        serverRoomId: serverRoomId,
        sinceSeq: beforeMax,
      ),
    );
  }

  /// React to a Centrifugo subscribe result. When recovery failed or the epoch
  /// rotated, do a full resync from the user's last read high-water-mark;
  /// otherwise a normal catch-up from the local max is enough.
  ///
  /// Returns the number of messages applied.
  Future<int> onSubscribed({
    required int roomLocalId,
    required int serverRoomId,
    required bool recovered,
    String? epoch,
  }) async {
    return _guardedAgainstLock('onSubscribed', () async {
      final epochChanged = epoch != null &&
          await _syncStateDao.hasEpochChanged(roomLocalId, epoch);

      if (epoch != null) {
        await _syncStateDao.setCursor(
          roomId: roomLocalId,
          lastKnownSeq: await _messagesDao.maxServerSeq(roomLocalId) ?? 0,
          epoch: epoch,
          nowMs: DateTime.now().millisecondsSinceEpoch,
        );
      }

      if (recovered && !epochChanged) {
        // The realtime layer already replayed the missed publications in order.
        return 0;
      }

      final sinceSeq = epochChanged
          ? await _lastReadSeq(roomLocalId)
          : await _recoveryCursor(roomLocalId);

      return syncRoomFrom(
        roomLocalId: roomLocalId,
        serverRoomId: serverRoomId,
        sinceSeq: sinceSeq,
      );
    });
  }

  /// Explicit-cursor variant used by [onSubscribed] (and tests). Respects the
  /// same single-flight guard as [syncRoom].
  Future<int> syncRoomFrom({
    required int roomLocalId,
    required int serverRoomId,
    required int sinceSeq,
  }) async {
    // Defense-in-depth: see [syncRoom] — never sync against an unresolved id.
    if (serverRoomId <= 0) return 0;
    if (_inFlight.contains(roomLocalId)) return 0;
    _inFlight.add(roomLocalId);
    try {
      return await _guardedAgainstLock(
        'syncRoomFrom',
        () => _fetchAndApply(
          roomLocalId: roomLocalId,
          serverRoomId: serverRoomId,
          sinceSeq: sinceSeq,
        ),
      );
    } finally {
      _inFlight.remove(roomLocalId);
    }
  }

  /// Where to resume from: the larger of the locally stored max seq and the
  /// recovery cursor in sync_state (app-owned state survives restarts).
  Future<int> _recoveryCursor(int roomLocalId) async {
    final localMax = await _messagesDao.maxServerSeq(roomLocalId) ?? 0;
    final state = await _syncStateDao.forRoom(roomLocalId);
    final cursor = state?.lastKnownSeq ?? 0;
    return localMax > cursor ? localMax : cursor;
  }

  Future<int> _lastReadSeq(int roomLocalId) async {
    final room = await _roomsDao.findByLocalId(roomLocalId);
    return room?.myLastReadSeq ?? 0;
  }

  /// Pull `?since_seq=N`, upsert every returned message, advance the cursor.
  Future<int> _fetchAndApply({
    required int roomLocalId,
    required int serverRoomId,
    required int sinceSeq,
  }) async {
    // Final line of defense: every public sync entry funnels through here, so an
    // unresolved server id (0) must never reach _sinceSeqUrl → /rooms/0/messages.
    if (serverRoomId <= 0) return 0;
    final response = await _http.get(_sinceSeqUrl(serverRoomId, sinceSeq));
    final items = _extractList(response.data);
    if (items.isEmpty) return 0;

    var applied = 0;
    var maxSeq = sinceSeq;
    // The room's last-message pointer must reflect the NEWEST message in the
    // batch, not whichever row happens to be iterated last. A `since_seq` page
    // is usually newest-first, so calling applyIncomingMessageMeta per-row left
    // the OLDEST row as the room's last message (stale preview + downward
    // reorder), plus N redundant room writes. Track the highest-seq row through
    // the loop and apply meta ONCE after it.
    int? newestLocalId;
    int? newestSeq;
    int? newestCreatedAt;
    for (final raw in items) {
      if (raw is! Map) continue;
      final json = Map<String, dynamic>.from(raw);
      final companion = _mapper.toCompanion(
        json,
        roomLocalId: roomLocalId,
        myUserId: MyDataModel.getInstance().id,
      );
      if (companion == null) continue;
      try {
        await _messagesDao.upsertFromServer(companion);
        applied++;

        final seq =
            companion.serverSeq.present ? companion.serverSeq.value : null;
        final createdAt = companion.serverCreatedAt.present
            ? companion.serverCreatedAt.value
            : null;
        if (seq != null) {
          if (seq > maxSeq) maxSeq = seq;
          if (newestSeq == null || seq > newestSeq) {
            final localId = await _resolveLocalId(json, roomLocalId);
            if (localId != null) {
              newestLocalId = localId;
              newestSeq = seq;
              newestCreatedAt = createdAt;
            }
          }
        }
      } catch (_) {
        // A single malformed/rejected row must not abort the whole batch (and
        // thus block the cursor advance). Skip it and keep applying the rest.
        continue;
      }
    }

    if (newestLocalId != null && newestSeq != null) {
      await _roomsDao.applyIncomingMessageMeta(
        roomLocalId: roomLocalId,
        lastMessageLocalId: newestLocalId,
        serverSeq: newestSeq,
        serverCreatedAt:
            newestCreatedAt ?? DateTime.now().millisecondsSinceEpoch,
      );
    }

    if (maxSeq > sinceSeq) {
      await _syncStateDao.setCursor(
        roomId: roomLocalId,
        lastKnownSeq: maxSeq,
        nowMs: DateTime.now().millisecondsSinceEpoch,
      );
    }
    return applied;
  }

  Future<int?> _resolveLocalId(
    Map<String, dynamic> json,
    int roomLocalId,
  ) async {
    final clientUuid = json['client_uuid']?.toString();
    if (clientUuid != null && clientUuid.isNotEmpty) {
      final row = await _messagesDao.findByClientUuid(clientUuid);
      if (row != null) return row.localId;
    }
    final sid = _mapper.serverRoomId(json);
    if (sid == null) {
      final id = _asInt(json['id']);
      if (id != null) {
        final row = await _messagesDao.findByServerMessageId(id);
        return row?.localId;
      }
    }
    final id = _asInt(json['id']);
    if (id != null) {
      final row = await _messagesDao.findByServerMessageId(id);
      return row?.localId;
    }
    return null;
  }

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  /// Server may return a bare list or wrap it under `data`/`messages`.
  static List<dynamic> _extractList(dynamic body) {
    if (body is List) return body;
    if (body is Map) {
      final data = body['data'] ?? body['messages'];
      if (data is List) return data;
      if (data is Map && data['messages'] is List) {
        return data['messages'] as List;
      }
    }
    return const [];
  }
}

/// Builds the `?since_seq=N` gap-fill URL for a room. Injected so the engine
/// stays free of the app's endpoint barrel and is unit-testable in isolation.
typedef SinceSeqUrlBuilder = String Function(int serverRoomId, int sinceSeq);

/// Builds the `?before_seq=N&limit=L` history-page URL (newest-first). Injected
/// like [SinceSeqUrlBuilder] so the engine stays endpoint-agnostic + testable.
typedef BeforeSeqUrlBuilder = String Function(int serverRoomId, int beforeSeq,
    {int limit});
