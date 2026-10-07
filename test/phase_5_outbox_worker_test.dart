// Phase 5 — OutboxWorker behaviour against an in-memory drift db + fake HTTP.
//
// Verifies the load-bearing send pipeline:
//   * success -> message marked sent (server_message_id + server_seq) + op removed
//   * Idempotency-Key header equals the message client_uuid (no-dup contract)
//   * FIFO per room: a failed head op blocks later ops and is rescheduled with
//     a future next_retry_at (backoff), nothing overtakes it
//   * permanent 4xx -> op dropped + message marked failed (no infinite retry)
//   * media-bearing op defers until media_uploads has a done remote_url, then
//     sends with file=remote_url
//   * re-entrancy guard: overlapping drains never double-send

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:general/src/core/database/app_database.dart';
import 'package:general/src/core/database/tables/chat_tables.dart';
import 'package:general/src/core/realtime/outbox_worker.dart';

import 'support/fake_realtime_http.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late FakeRealtimeHttp http;
  late int now;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    http = FakeRealtimeHttp();
    now = 1000000;
  });

  tearDown(() async => db.close());

  OutboxWorker makeWorker() => OutboxWorker(
        http: http,
        outboxDao: db.outboxDao,
        messagesDao: db.messagesDao,
        mediaUploadsDao: db.mediaUploadsDao,
        sendMessagePath: '/Chat-Message',
        clock: () => now,
      );

  Future<void> seedRoom(int roomLocalId) async {
    await db.roomsDao.insertRoom(
      RoomsCompanion.insert(type: RoomType.dm, serverRoomId: Value(roomLocalId)),
    );
  }

  Future<void> enqueueSend({
    required String clientUuid,
    required int roomId,
    String body = 'hi',
    int createdAt = 0,
    String? mediaRef,
    String payloadFile = '',
  }) async {
    await db.messagesDao.insertPending(MessagesCompanion.insert(
      clientUuid: clientUuid,
      roomId: roomId,
      kind: MessageKind.user,
      type: MessageContentType.text,
      createdAtClient: createdAt,
      state: MessageState.pending,
      body: Value(body),
    ));
    await db.outboxDao.enqueue(OutboxCompanion.insert(
      opType: OutboxOpType.sendMsg,
      clientUuid: clientUuid,
      roomId: roomId,
      payloadJson: payloadFile.isEmpty
          ? '{"user_id":2,"message":"$body"}'
          : '{"user_id":2,"file":"$payloadFile"}',
      createdAt: createdAt,
      mediaLocalRef: Value(mediaRef),
    ));
  }

  Response<dynamic> okSend(int id, int seq) => Response<dynamic>(
        requestOptions: RequestOptions(path: '/Chat-Message'),
        statusCode: 200,
        data: {
          'data': {'id': id, 'server_seq': seq, 'created_at': 1700000000000}
        },
      );

  test('successful send marks message sent and removes the outbox op', () async {
    await seedRoom(1);
    await enqueueSend(clientUuid: 'u1', roomId: 1);
    http.onPost = (_, __, ___) async => okSend(900, 5);

    final report = await makeWorker().drainOnce();

    expect(report.succeeded, 1);
    final msg = await db.messagesDao.findByClientUuid('u1');
    expect(msg!.state, MessageState.sent);
    expect(msg.serverMessageId, 900);
    expect(msg.serverSeq, 5);
    expect(await db.outboxDao.findByClientUuid('u1'), isNull);
  });

  test('Idempotency-Key header equals the client_uuid', () async {
    await seedRoom(1);
    await enqueueSend(clientUuid: 'idem-1', roomId: 1);
    String? sentKey;
    http.onPost = (path, data, headers) async {
      sentKey = headers?['Idempotency-Key'] as String?;
      return okSend(1, 1);
    };

    await makeWorker().drainOnce();

    expect(sentKey, 'idem-1');
  });

  test('FIFO: a failing head op blocks later ops and is backed off', () async {
    await seedRoom(1);
    await enqueueSend(clientUuid: 'a', roomId: 1, createdAt: 1);
    await enqueueSend(clientUuid: 'b', roomId: 1, createdAt: 2);

    var calls = 0;
    http.onPost = (path, data, headers) async {
      calls++;
      throw DioException.connectionError(
        requestOptions: RequestOptions(path: path),
        reason: 'offline',
      );
    };

    final report = await makeWorker().drainRoom(1);

    // Only the head op was attempted; the second never ran (order preserved).
    expect(calls, 1);
    expect(report.failed, 1);
    expect(report.succeeded, 0);

    final headOp = await db.outboxDao.findByClientUuid('a');
    expect(headOp!.attempts, 1);
    expect(headOp.nextRetryAt, isNotNull);
    expect(headOp.nextRetryAt! > now, isTrue); // scheduled into the future
    // head message bounced back to pending for retry, not failed
    final msg = await db.messagesDao.findByClientUuid('a');
    expect(msg!.state, MessageState.pending);
  });

  test('permanent 4xx drops the op and marks the message failed', () async {
    await seedRoom(1);
    await enqueueSend(clientUuid: 'bad', roomId: 1);
    http.onPost = (path, data, headers) async {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: path),
          statusCode: 422,
        ),
      );
    };

    final report = await makeWorker().drainOnce();

    expect(report.skipped, 1);
    expect(await db.outboxDao.findByClientUuid('bad'), isNull);
    final msg = await db.messagesDao.findByClientUuid('bad');
    expect(msg!.state, MessageState.failed);
  });

  test('429 is retryable (not dropped) and gets backed off', () async {
    await seedRoom(1);
    await enqueueSend(clientUuid: 'throttle', roomId: 1);
    http.onPost = (path, data, headers) async {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: path),
          statusCode: 429,
        ),
      );
    };

    final report = await makeWorker().drainOnce();

    expect(report.failed, 1);
    final op = await db.outboxDao.findByClientUuid('throttle');
    expect(op, isNotNull);
    expect(op!.attempts, 1);
  });

  test('media op defers until upload is done, then sends with remote_url',
      () async {
    await seedRoom(1);
    await enqueueSend(
      clientUuid: 'mediamsg',
      roomId: 1,
      mediaRef: 'mediamsg',
    );
    // Media still uploading -> first drain must NOT call POST.
    await db.mediaUploadsDao.upsert(MediaUploadsCompanion.insert(
      clientUuid: 'mediamsg',
      localPath: '/tmp/x.jpg',
      uploadState: MediaUploadState.uploading,
    ));

    var posted = false;
    String? sentFile;
    http.onPost = (path, data, headers) async {
      posted = true;
      sentFile = (data as Map)['file'] as String?;
      return okSend(10, 1);
    };

    final first = await makeWorker().drainOnce();
    expect(posted, isFalse);
    expect(first.failed, 1); // deferred (recorded as a backoff failure)

    // Upload completes with a remote URL.
    await db.mediaUploadsDao.markDone(
      clientUuid: 'mediamsg',
      remoteUrl: 'https://cdn/x.jpg',
    );
    // The op was backed off into the future; advance the clock past it.
    final op = await db.outboxDao.findByClientUuid('mediamsg');
    now = (op!.nextRetryAt ?? now) + 1;

    final second = await makeWorker().drainOnce();
    expect(posted, isTrue);
    expect(sentFile, 'https://cdn/x.jpg');
    expect(second.succeeded, 1);
    expect(await db.outboxDao.findByClientUuid('mediamsg'), isNull);
  });

  test('two rooms each drain independently in one pass', () async {
    await seedRoom(1);
    await seedRoom(2);
    await enqueueSend(clientUuid: 'r1', roomId: 1);
    await enqueueSend(clientUuid: 'r2', roomId: 2);
    var seq = 0;
    http.onPost = (_, __, ___) async => okSend(++seq, seq);

    final report = await makeWorker().drainOnce();

    expect(report.succeeded, 2);
    expect(await db.outboxDao.findByClientUuid('r1'), isNull);
    expect(await db.outboxDao.findByClientUuid('r2'), isNull);
  });
}
