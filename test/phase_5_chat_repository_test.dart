// Phase 5 — ChatRepository (Plan section 7.5) against an in-memory drift db +
// fake HTTP. Verifies the local-first send/receive contract:
//   * send writes an optimistic `pending` row visible on the stream AND a
//     matching outbox op (Idempotency-Key = client_uuid)
//   * double-send with the same client_uuid is a no-op (no duplicate row/op)
//   * the realtime/REST echo dedups onto the optimistic row by client_uuid
//   * openConversation creates the room and pulls the REST delta (since_seq)
//   * keyset pagination (olderPage) is bounded + newest-first
//   * retry flips a failed message back to pending and re-enqueues if needed
//   * read receipts / state transitions go through the repo

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:general/src/core/database/app_database.dart';
import 'package:general/src/core/database/tables/chat_tables.dart';
import 'package:general/src/core/realtime/chat_repository.dart';
import 'package:general/src/core/realtime/realtime_message_mapper.dart';
import 'package:general/src/core/realtime/sync_engine.dart';

import 'support/fake_realtime_http.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late FakeRealtimeHttp http;
  const me = 100;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    http = FakeRealtimeHttp();
  });

  tearDown(() async => db.close());

  SyncEngine makeEngine() => SyncEngine(
        http: http,
        messagesDao: db.messagesDao,
        roomsDao: db.roomsDao,
        syncStateDao: db.syncStateDao,
        sinceSeqUrl: (roomId, sinceSeq) =>
            '/rooms/$roomId/messages?since_seq=$sinceSeq',
      );

  ChatRepository makeRepo({
    void Function()? onEnqueued,
    int Function()? clock,
  }) =>
      ChatRepository(
        roomsDao: db.roomsDao,
        messagesDao: db.messagesDao,
        outboxDao: db.outboxDao,
        mediaUploadsDao: db.mediaUploadsDao,
        syncEngine: makeEngine(),
        currentUserId: () => me,
        onEnqueued: onEnqueued,
        clock: clock,
      );

  Future<int> seedRoom(int serverRoomId) => db.roomsDao.insertRoom(
        RoomsCompanion.insert(
          type: RoomType.dm,
          serverRoomId: Value(serverRoomId),
        ),
      );

  Response<dynamic> withMessages(List<Map<String, dynamic>> msgs) =>
      Response<dynamic>(
        requestOptions: RequestOptions(path: '/sync'),
        statusCode: 200,
        data: {'data': msgs},
      );

  test('send writes an optimistic pending row and a matching outbox op',
      () async {
    final localId = await seedRoom(1);
    var kicked = 0;
    final repo = makeRepo(onEnqueued: () => kicked++);

    final sent = await repo.send(
      roomLocalId: localId,
      peerUserId: 7,
      body: 'hello',
    );

    expect(sent.alreadyQueued, isFalse);
    expect(sent.clientUuid, isNotEmpty);

    final row = await db.messagesDao.findByClientUuid(sent.clientUuid);
    expect(row, isNotNull);
    expect(row!.state, MessageState.pending);
    expect(row.body, 'hello');
    expect(row.senderId, me);
    expect(row.serverSeq, isNull);

    final ops = await db.outboxDao.dueOps(nowMs: 1 << 50);
    expect(ops.length, 1);
    expect(ops.first.clientUuid, sent.clientUuid);
    expect(ops.first.opType, OutboxOpType.sendMsg);
    final payload = jsonDecode(ops.first.payloadJson) as Map<String, dynamic>;
    expect(payload['client_uuid'], sent.clientUuid);
    expect(payload['message'], 'hello');
    expect(payload['user_id'], 7);
    expect(payload['type'], 'text');

    expect(kicked, 1); // worker nudged exactly once
  });

  test('optimistic message is visible on the watch stream immediately',
      () async {
    final localId = await seedRoom(1);
    final repo = makeRepo();

    await repo.send(roomLocalId: localId, peerUserId: 7, body: 'first');

    final rows = await repo.watchMessages(localId).first;
    expect(rows.length, 1);
    expect(rows.first.body, 'first');
    expect(rows.first.state, MessageState.pending);
  });

  test('double-send with the same client_uuid does not duplicate', () async {
    final localId = await seedRoom(1);
    var kicked = 0;
    final repo = makeRepo(onEnqueued: () => kicked++);

    final first = await repo.send(
      roomLocalId: localId,
      peerUserId: 7,
      body: 'dup',
      clientUuid: 'fixed-uuid',
    );
    final second = await repo.send(
      roomLocalId: localId,
      peerUserId: 7,
      body: 'dup',
      clientUuid: 'fixed-uuid',
    );

    expect(first.alreadyQueued, isFalse);
    expect(second.alreadyQueued, isTrue);

    final rows = await repo.conversation(localId, limit: 100);
    expect(rows.length, 1);
    final ops = await db.outboxDao.dueOps(nowMs: 1 << 50);
    expect(ops.length, 1);
    expect(kicked, 1); // second send did not re-nudge
  });

  test('server echo dedups onto the optimistic row by client_uuid', () async {
    final localId = await seedRoom(1);
    final repo = makeRepo();

    final sent = await repo.send(
      roomLocalId: localId,
      peerUserId: 7,
      body: 'echo',
    );

    // Simulate the realtime/REST confirmation carrying the same client_uuid.
    const mapper = RealtimeMessageMapper();
    final companion = mapper.toCompanion({
      'id': 555,
      'client_uuid': sent.clientUuid,
      'server_seq': 9,
      'chat_room_id': 1,
      'user_id': me,
      'type': 'text',
      'message': 'echo',
      'created_at': 1700000000000,
    }, roomLocalId: localId);
    await db.messagesDao.upsertFromServer(companion!);

    final rows = await repo.conversation(localId, limit: 100);
    expect(rows.length, 1); // still one row — deduped, not duplicated
    expect(rows.first.serverMessageId, 555);
    expect(rows.first.serverSeq, 9);
  });

  test('openConversation creates the room and pulls the REST delta', () async {
    http.onGet = (path) async {
      expect(path, contains('since_seq=0'));
      return withMessages([
        {
          'id': 1,
          'client_uuid': 'srv-1',
          'server_seq': 1,
          'chat_room_id': 42,
          'user_id': 7,
          'type': 'text',
          'message': 'hi from peer',
          'created_at': 1700000000000,
        },
      ]);
    };

    final repo = makeRepo();
    final ref = await repo.openConversation(serverRoomId: 42, peerUserId: 7);

    expect(ref.serverRoomId, 42);
    final rows = await repo.conversation(ref.localId, limit: 100);
    expect(rows.length, 1);
    expect(rows.first.body, 'hi from peer');
    expect(http.getCalls.length, 1);
  });

  test('openConversation is idempotent — same local room on re-open', () async {
    final repo = makeRepo();
    final a = await repo.openConversation(serverRoomId: 9);
    final b = await repo.openConversation(serverRoomId: 9);
    expect(a.localId, b.localId);
  });

  test('olderPage is keyset (server_seq < cursor), bounded and newest-first',
      () async {
    final localId = await seedRoom(1);
    const mapper = RealtimeMessageMapper();
    for (var seq = 1; seq <= 5; seq++) {
      await db.messagesDao.upsertFromServer(mapper.toCompanion({
        'id': seq,
        'client_uuid': 'm-$seq',
        'server_seq': seq,
        'chat_room_id': 1,
        'user_id': 7,
        'type': 'text',
        'message': 'm$seq',
        'created_at': 1700000000000 + seq,
      }, roomLocalId: localId)!);
    }
    final repo = makeRepo();

    final page = await repo.olderPage(
      roomLocalId: localId,
      beforeServerSeq: 4,
      limit: 2,
    );
    expect(page.map((m) => m.serverSeq), [3, 2]); // newest-first, < 4, capped
  });

  test('retry flips a failed message back to pending and re-enqueues', () async {
    final localId = await seedRoom(1);
    final repo = makeRepo();

    final sent = await repo.send(
      roomLocalId: localId,
      peerUserId: 7,
      body: 'will-fail',
    );
    // Simulate a permanent failure that dropped the outbox op + marked failed.
    await db.outboxDao.removeByClientUuid(sent.clientUuid);
    await db.messagesDao.markFailed(sent.clientUuid);

    await repo.retry(sent.clientUuid);

    final row = await db.messagesDao.findByClientUuid(sent.clientUuid);
    expect(row!.state, MessageState.pending);
    final ops = await db.outboxDao.dueOps(nowMs: 1 << 50);
    expect(ops.length, 1);
    expect(ops.first.clientUuid, sent.clientUuid);
  });

  test('retry on an already-delivered message is a no-op', () async {
    final localId = await seedRoom(1);
    final repo = makeRepo();
    final sent =
        await repo.send(roomLocalId: localId, peerUserId: 7, body: 'done');
    await db.messagesDao.markSent(
      clientUuid: sent.clientUuid,
      serverMessageId: 1,
      serverSeq: 1,
    );
    await db.outboxDao.removeByClientUuid(sent.clientUuid);

    await repo.retry(sent.clientUuid);

    final row = await db.messagesDao.findByClientUuid(sent.clientUuid);
    expect(row!.state, MessageState.sent);
    final ops = await db.outboxDao.dueOps(nowMs: 1 << 50);
    expect(ops, isEmpty); // no re-enqueue for an already-sent message
  });

  test('markRead advances the room high-water-mark', () async {
    final localId = await seedRoom(1);
    const mapper = RealtimeMessageMapper();
    await db.messagesDao.upsertFromServer(mapper.toCompanion({
      'id': 1,
      'client_uuid': 'r-1',
      'server_seq': 5,
      'chat_room_id': 1,
      'user_id': 7,
      'type': 'text',
      'message': 'unread',
      'created_at': 1700000000000,
    }, roomLocalId: localId)!);
    await db.roomsDao.applyIncomingMessageMeta(
      roomLocalId: localId,
      lastMessageLocalId: 1,
      serverSeq: 5,
      serverCreatedAt: 1700000000000,
      incrementUnread: true,
    );
    final repo = makeRepo();

    await repo.markRead(roomLocalId: localId, upToSeq: 5);

    final room = await db.roomsDao.findByLocalId(localId);
    expect(room!.myLastReadSeq, 5);
    expect(room.unreadCount, 0);
  });

  test('setMessageState + setDeleteState transitions persist', () async {
    final localId = await seedRoom(1);
    final repo = makeRepo();
    final sent =
        await repo.send(roomLocalId: localId, peerUserId: 7, body: 's');

    await repo.setMessageState(sent.clientUuid, MessageState.delivered);
    var row = await db.messagesDao.findByClientUuid(sent.clientUuid);
    expect(row!.state, MessageState.delivered);

    await repo.setDeleteState(sent.clientUuid, MessageDeleteState.deletedForAll);
    row = await db.messagesDao.findByClientUuid(sent.clientUuid);
    expect(row!.deleteState, MessageDeleteState.deletedForAll);
  });
}
