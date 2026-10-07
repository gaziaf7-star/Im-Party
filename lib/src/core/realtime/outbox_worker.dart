import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart' show DioException;
import 'package:general/src/core/database/app_database.dart';
import 'package:general/src/core/database/daos/media_uploads_dao.dart';
import 'package:general/src/core/database/db_contention.dart';
import 'package:general/src/core/database/daos/messages_dao.dart';
import 'package:general/src/core/database/daos/outbox_dao.dart';
import 'package:general/src/core/database/daos/rooms_dao.dart';
import 'package:general/src/core/database/tables/chat_tables.dart';
import 'package:general/src/core/realtime/outbox_backoff.dart';
import 'package:general/src/core/realtime/realtime_http.dart';
import 'package:general/src/core/utils/methods.dart';

/// Outcome of draining one tick, surfaced for tests + diagnostics.
class OutboxDrainReport {
  const OutboxDrainReport({
    required this.succeeded,
    required this.failed,
    required this.skipped,
  });

  final int succeeded;
  final int failed;
  final int skipped;

  int get total => succeeded + failed + skipped;
}

/// Durable, order-preserving sender for queued chat operations (Plan 7.2).
///
/// Pulls due ops from [OutboxDao] (FIFO per room), POSTs them to the backend
/// with an `Idempotency-Key` header equal to the message `client_uuid`, and on
/// success promotes the local message to `sent` with its `server_message_id` +
/// `server_seq`. On failure it records the attempt and schedules an
/// exponentially-backed-off retry with full jitter.
///
/// Ordering guarantee: a room is drained strictly in FIFO order and stops at the
/// first op that fails, so a stuck message never lets a later one overtake it.
/// The backend is idempotent on `client_uuid`, so a retry after a lost response
/// never duplicates a message.
class OutboxWorker {
  OutboxWorker({
    required RealtimeHttp http,
    required OutboxDao outboxDao,
    required MessagesDao messagesDao,
    required String sendMessagePath,
    RoomsDao? roomsDao,
    MediaUploadsDao? mediaUploadsDao,
    OutboxBackoff backoff = const OutboxBackoff(),
    Random? random,
    int Function()? clock,
    Duration tickInterval = const Duration(seconds: 3),
    RecoverableDbErrorReporter? onRecoverableDbError,
  })  : _http = http,
        _outboxDao = outboxDao,
        _messagesDao = messagesDao,
        _roomsDao = roomsDao,
        _sendMessagePath = sendMessagePath,
        _mediaUploadsDao = mediaUploadsDao,
        _backoff = backoff,
        _random = random ?? Random(),
        _clock = clock ?? (() => DateTime.now().millisecondsSinceEpoch),
        _tickInterval = tickInterval,
        _onRecoverableDbError = onRecoverableDbError;

  final RealtimeHttp _http;
  final String _sendMessagePath;
  final OutboxDao _outboxDao;
  final MessagesDao _messagesDao;
  final RoomsDao? _roomsDao;
  final MediaUploadsDao? _mediaUploadsDao;
  final OutboxBackoff _backoff;
  final Random _random;
  final int Function() _clock;
  final Duration _tickInterval;
  final RecoverableDbErrorReporter? _onRecoverableDbError;

  Timer? _timer;

  // Per-room drain guards (#15): each room is drained independently so a slow
  // HTTP request on room A never blocks room B's queue.
  final Set<int> _drainingRooms = {};
  // Rooms kicked while they were already being drained — re-drained once
  // the current pass finishes, but ONLY when that pass made actual progress
  // (succeeded > 0) to avoid a busy-loop on a permanently-stuck head op.
  final Set<int> _dirtyRooms = {};

  /// Begin periodic draining. Safe to call repeatedly (idempotent).
  void start() {
    _timer ??= Timer.periodic(_tickInterval, (_) => drainOnce());
    // Kick an immediate pass so a freshly-enqueued op doesn't wait a full tick.
    unawaited(drainOnce());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Drain every room that currently has due ops, concurrently. Each room is
  /// drained in strict FIFO order internally; rooms run in parallel so a slow
  /// request on room A never blocks room B. Re-entrancy per-room is guarded by
  /// [_drainingRooms]; overlapping [drainOnce] calls for the same room are
  /// coalesced into a dirty-re-run rather than a concurrent double-drain.
  Future<OutboxDrainReport> drainOnce() async {
    final now = _clock();
    final List<OutboxData> due;
    try {
      due = await _outboxDao.dueOps(nowMs: now);
    } catch (e, s) {
      // SQLITE_BUSY on the due-ops read is transient — skip this tick instead
      // of crashing; the periodic timer retries in [_tickInterval].
      if (!isDbLockedError(e)) rethrow;
      _onRecoverableDbError?.call(
          e, s, 'OutboxWorker.drainOnce: database locked — retried next tick');
      return const OutboxDrainReport(succeeded: 0, failed: 0, skipped: 0);
    }
    if (due.isEmpty) {
      return const OutboxDrainReport(succeeded: 0, failed: 0, skipped: 0);
    }
    final roomIds = <int>{for (final op in due) op.roomId};
    // Start all rooms that are not already being drained in parallel.
    final reports = await Future.wait<OutboxDrainReport>(
      roomIds.map((id) => drainRoom(id)),
    );
    return reports.fold<OutboxDrainReport>(
      const OutboxDrainReport(succeeded: 0, failed: 0, skipped: 0),
      (acc, r) => OutboxDrainReport(
        succeeded: acc.succeeded + r.succeeded,
        failed: acc.failed + r.failed,
        skipped: acc.skipped + r.skipped,
      ),
    );
  }

  /// Drain a single room in FIFO order, stopping at the first failure to keep
  /// ordering intact. Public so the realtime layer can prioritize the open room.
  /// Safe to call concurrently across different room IDs; same room ID is
  /// de-duplicated via [_drainingRooms]/[_dirtyRooms].
  Future<OutboxDrainReport> drainRoom(int roomId) async {
    if (_drainingRooms.contains(roomId)) {
      // Already draining: mark dirty so we re-run after the current pass.
      _dirtyRooms.add(roomId);
      return const OutboxDrainReport(succeeded: 0, failed: 0, skipped: 0);
    }
    _drainingRooms.add(roomId);
    try {
      final OutboxDrainReport report;
      try {
        report = await _drainRoom(roomId);
      } catch (e, s) {
        // A locked DB anywhere in the drain (due-ops read, markSent, remove,
        // recordFailure) must not crash the app: the op rows are untouched or
        // already idempotent, so the next tick simply retries the room.
        if (!isDbLockedError(e)) rethrow;
        _onRecoverableDbError?.call(e, s,
            'OutboxWorker.drainRoom($roomId): database locked — retried next tick');
        _dirtyRooms.remove(roomId);
        return const OutboxDrainReport(succeeded: 0, failed: 1, skipped: 0);
      }
      // Re-drain only when work was done; a permanently-failed head op must not
      // trigger an infinite retry loop.
      if (_dirtyRooms.remove(roomId) && report.succeeded > 0) {
        return drainRoom(roomId);
      }
      return report;
    } finally {
      _drainingRooms.remove(roomId);
    }
  }

  Future<OutboxDrainReport> _drainRoom(int roomId) async {
    var succeeded = 0;
    var failed = 0;
    var skipped = 0;

    while (true) {
      final now = _clock();
      final batch = await _outboxDao.dueOpsForRoom(
        roomId: roomId,
        nowMs: now,
        limit: 1,
      );
      if (batch.isEmpty) break;
      final op = batch.first;

      final handled = await _processOp(op);
      if (handled == _OpResult.success) {
        succeeded++;
        continue; // move to the next op in this room
      }
      if (handled == _OpResult.dropped) {
        skipped++;
        continue;
      }
      // Failure: stop draining THIS room to preserve FIFO ordering. The op has
      // been rescheduled with backoff; a later tick will retry it.
      failed++;
      break;
    }

    return OutboxDrainReport(
      succeeded: succeeded,
      failed: failed,
      skipped: skipped,
    );
  }

  Future<_OpResult> _processOp(OutboxData op) async {
    switch (op.opType) {
      case OutboxOpType.sendMsg:
        return _processSend(op);
      // Side-effect ops (react/delete/mark-read) are simple idempotent POSTs to
      // the path carried in the payload. The optimistic local change was already
      // applied by ChatRepository; here we only sync it to the backend.
      case OutboxOpType.react:
      case OutboxOpType.delete:
      case OutboxOpType.markRead:
        return _processSimplePost(op);
      // Not used yet — drop rather than wedge the queue head.
      case OutboxOpType.edit:
      case OutboxOpType.groupOp:
        await _outboxDao.remove(op.localId);
        return _OpResult.dropped;
    }
  }

  /// Generic idempotent POST for side-effect ops (react/delete/mark-read). The
  /// target endpoint travels on the reserved `__path` payload key; on a
  /// permanent 4xx the op is dropped (the optimistic local state stands — these
  /// are best-effort syncs, not message bodies), transient errors back off.
  Future<_OpResult> _processSimplePost(OutboxData op) async {
    final Map<String, dynamic> payload;
    try {
      final decoded = jsonDecode(op.payloadJson);
      payload = decoded is Map
          ? Map<String, dynamic>.from(decoded)
          : <String, dynamic>{};
    } catch (_) {
      await _outboxDao.remove(op.localId);
      return _OpResult.dropped;
    }

    final path = payload.remove('__path')?.toString();
    if (path == null || path.isEmpty) {
      await _outboxDao.remove(op.localId);
      return _OpResult.dropped;
    }

    try {
      await _http.post(
        path,
        data: payload,
        headers: {'Idempotency-Key': op.clientUuid},
      );
      await _outboxDao.remove(op.localId);
      return _OpResult.success;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status != null &&
          status >= 400 &&
          status < 500 &&
          status != 408 &&
          status != 429) {
        // A permanent 4xx drops the op (optimistic local state stands). A 422 is
        // almost always a body/contract mismatch (e.g. the wrong field key), which
        // otherwise vanishes silently and re-surfaces as "the action didn't take".
        // Surface it so a future mismatch is diagnosable instead of invisible.
        if (status == 422) {
          Methods.printLog(
            '[outbox] dropped op on 422 path=$path body=$payload resp=${e.response?.data}',
            name: 'outbox_worker',
          );
        }
        await _outboxDao.remove(op.localId);
        return _OpResult.dropped;
      }
      return _failSimple(op, 'http_${status ?? 'network'}');
    } catch (e) {
      return _failSimple(op, e.toString());
    }
  }

  /// Backoff for a failed side-effect op without touching any message row state
  /// (unlike [_fail], which flips a send back to `pending`).
  Future<_OpResult> _failSimple(OutboxData op, String error) async {
    await _outboxDao.recordFailure(
      localId: op.localId,
      nextRetryAt: _backoff.nextRetryAt(op.attempts, _clock(), _random),
      error: error,
    );
    return _OpResult.failure;
  }

  Future<_OpResult> _processSend(OutboxData op) async {
    final Map<String, dynamic> payload;
    try {
      final decoded = jsonDecode(op.payloadJson);
      payload = decoded is Map
          ? Map<String, dynamic>.from(decoded)
          : <String, dynamic>{};
    } catch (_) {
      // Corrupt payload can never succeed — drop it so it doesn't wedge the room.
      await _outboxDao.remove(op.localId);
      await _messagesDao.markFailed(op.clientUuid);
      return _OpResult.dropped;
    }

    // Per-op endpoint override (group messages target /api/groups/{id}/messages).
    // The reserved `__path` key is stripped before the body is sent; 1:1 sends
    // omit it and fall back to the default 1:1 [_sendMessagePath].
    final sendPath = payload.remove('__path')?.toString() ?? _sendMessagePath;

    // A media-bearing op must wait until its upload has produced a remote_url.
    // The media worker writes the URL into media_uploads (markDone); we read it
    // here by the media reference (client_uuid) and stamp it onto the payload at
    // send time. If the upload fails or is missing, or the op has been deferred
    // too many times (cap=8), we drop the op so it never wedges the FIFO queue.
    if (op.mediaLocalRef != null && payload['file'] == null) {
      final remoteUrl = await _resolveMediaUrl(op.mediaLocalRef!);
      if (remoteUrl == null) {
        if (await _isMediaUploadTerminal(op.mediaLocalRef!, op.attempts)) {
          await _outboxDao.remove(op.localId);
          await _messagesDao.markFailed(op.clientUuid);
          return _OpResult.dropped;
        }
        await _outboxDao.recordFailure(
          localId: op.localId,
          nextRetryAt: _backoff.nextRetryAt(op.attempts, _clock(), _random),
          error: 'awaiting_media_upload',
        );
        return _OpResult.failure;
      }
      payload['file'] = remoteUrl;
    }

    try {
      final response = await _http.post(
        sendPath,
        data: payload,
        headers: {'Idempotency-Key': op.clientUuid},
      );

      final parsed = _parseSendResponse(response.data);
      if (parsed == null) {
        // 2xx but unparseable — treat as retryable to be safe.
        return _fail(op, 'unparseable_send_response');
      }

      await _messagesDao.markSent(
        clientUuid: op.clientUuid,
        serverMessageId: parsed.serverMessageId,
        serverSeq: parsed.serverSeq,
        serverCreatedAt: parsed.serverCreatedAt,
      );

      // Bump the room's last-message metadata for OUR OWN send so the chats
      // list reorders this conversation to the top immediately. Incoming
      // messages already do this via RealtimeClient.applyIncomingMessageMeta,
      // but a self-send never produces an incoming event (the group fan-out
      // excludes the sender), so without this the room stayed frozen until
      // someone else messaged or the list was reopened. incrementUnread:false
      // — we sent it, it's already read by us.
      final roomsDao = _roomsDao;
      if (roomsDao != null) {
        final sent = await _messagesDao.findByClientUuid(op.clientUuid);
        if (sent != null) {
          await roomsDao.applyIncomingMessageMeta(
            roomLocalId: op.roomId,
            lastMessageLocalId: sent.localId,
            serverSeq: parsed.serverSeq,
            serverCreatedAt: parsed.serverCreatedAt ??
                DateTime.now().millisecondsSinceEpoch,
            incrementUnread: false,
          );
        }
      }

      await _outboxDao.remove(op.localId);
      return _OpResult.success;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      // 4xx (except 408/429) is a permanent client error: the same body will
      // never succeed, so drop the op and surface failure to the UI.
      if (status != null &&
          status >= 400 &&
          status < 500 &&
          status != 408 &&
          status != 429) {
        await _outboxDao.remove(op.localId);
        await _messagesDao.markFailed(op.clientUuid);
        return _OpResult.dropped;
      }
      return _fail(op, 'http_${status ?? 'network'}');
    } catch (e) {
      return _fail(op, e.toString());
    }
  }

  /// Remote URL for a media-bearing op, or null while the upload is unfinished.
  Future<String?> _resolveMediaUrl(String clientUuid) async {
    final dao = _mediaUploadsDao;
    if (dao == null) return null;
    final record = await dao.findByClientUuid(clientUuid);
    if (record == null) return null;
    if (record.uploadState != MediaUploadState.done) return null;
    final url = record.remoteUrl;
    return (url != null && url.isNotEmpty) ? url : null;
  }

  /// True when the media upload has permanently failed (or the op has been
  /// deferred so many times it's unlikely to ever succeed). Signals
  /// [_processSend] to drop the op and surface an error to the UI instead of
  /// wedging the FIFO queue forever.
  Future<bool> _isMediaUploadTerminal(String clientUuid, int attempts) async {
    if (attempts >= 8) return true;
    final dao = _mediaUploadsDao;
    if (dao == null) return true; // no DAO → can't upload → terminal
    final record = await dao.findByClientUuid(clientUuid);
    if (record == null) return true; // record missing → terminal
    return record.uploadState == MediaUploadState.failed;
  }

  Future<_OpResult> _fail(OutboxData op, String error) async {
    await _outboxDao.recordFailure(
      localId: op.localId,
      nextRetryAt: _backoff.nextRetryAt(op.attempts, _clock(), _random),
      error: error,
    );
    await _messagesDao.updateState(op.clientUuid, MessageState.pending);
    return _OpResult.failure;
  }

  /// Extracts server_message_id + server_seq from the send response. Handles
  /// both the new offline-sync shape and the legacy MessageResponse envelope.
  _SendAck? _parseSendResponse(dynamic body) {
    Map<String, dynamic>? msg;
    if (body is Map) {
      if (body['data'] is Map) {
        msg = Map<String, dynamic>.from(body['data'] as Map);
      } else if (body['message'] is Map) {
        msg = Map<String, dynamic>.from(body['message'] as Map);
      } else {
        msg = Map<String, dynamic>.from(body);
      }
    }
    if (msg == null) return null;

    final sid = _asInt(msg['id'] ?? msg['server_message_id']);
    final seq = _asInt(msg['server_seq']);
    if (sid == null || seq == null) return null;

    return _SendAck(
      serverMessageId: sid,
      serverSeq: seq,
      serverCreatedAt: _epochMs(msg['created_at'] ?? msg['server_created_at']),
    );
  }

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static int? _epochMs(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    final parsed = DateTime.tryParse(v.toString());
    return parsed?.millisecondsSinceEpoch;
  }
}

enum _OpResult { success, failure, dropped }

class _SendAck {
  const _SendAck({
    required this.serverMessageId,
    required this.serverSeq,
    this.serverCreatedAt,
  });

  final int serverMessageId;
  final int serverSeq;
  final int? serverCreatedAt;
}
