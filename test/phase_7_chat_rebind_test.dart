// Phase 7 — 1:1 chat rebind onto the drift/realtime stack.
//
// Covers the NEW feature-parity code added when wiring the legacy 1:1 chat
// screens to the offline-first engine:
//   * DriftMessageMapper: drift row -> legacy MessagesEntity (state/type/status
//     mapping + reacts/attachment/reply JSON decode + delete flags)
//   * RealtimeMessageMapper: server JSON -> drift companion populates the new
//     parity columns (snake_case tolerant), round-tripping back to the UI entity
//   * ChatRepository.react: optimistic reaction toggle + react outbox op
//   * ChatRepository.deleteMessages: optimistic delete marker + delete outbox op
//   * OutboxWorker side-effect ops (react/delete/markRead): idempotent POST to
//     the payload __path; success removes, permanent 4xx drops, transient backs off

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:general/src/core/database/app_database.dart';
import 'package:general/src/core/database/tables/chat_tables.dart';
import 'package:general/src/core/realtime/chat_repository.dart';
import 'package:general/src/core/realtime/outbox_worker.dart';
import 'package:general/src/core/realtime/realtime_message_mapper.dart';
import 'package:general/src/core/realtime/sync_engine.dart';
import 'package:general/src/features/messages/data/mappers/drift_message_mapper.dart';

import 'support/fake_realtime_http.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late FakeRealtimeHttp http;
  late int now;
  const me = 5;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    http = FakeRealtimeHttp();
    now = 1000000;
  });

  tearDown(() async => db.close());

  Future<int> seedRoom() => db.roomsDao.insertRoom(
        RoomsCompanion.insert(type: RoomType.dm, serverRoomId: const Value(900)),
      );

  Future<void> insertMsg({
    required String cuid,
    required int room,
    int? sid,
    int senderId = 9,
    MessageContentType type = MessageContentType.text,
    MessageState state = MessageState.delivered,
    String? body = 'hi',
    String? serverStatus,
    String? reactsJson,
    String? attachmentJson,
    String? replyPreviewJson,
  }) async {
    await db.messagesDao.insertPending(MessagesCompanion.insert(
      clientUuid: cuid,
      roomId: room,
      kind: MessageKind.user,
      type: type,
      createdAtClient: now,
      state: state,
      serverMessageId: Value(sid),
      senderId: Value(senderId),
      body: Value(body),
      serverStatus: Value(serverStatus),
      reactsJson: Value(reactsJson),
      attachmentJson: Value(attachmentJson),
      replyPreviewJson: Value(replyPreviewJson),
    ));
  }

  SyncEngine makeSync() => SyncEngine(
        http: http,
        messagesDao: db.messagesDao,
        roomsDao: db.roomsDao,
        syncStateDao: db.syncStateDao,
        sinceSeqUrl: (r, s) => '/v1/rooms/$r/messages?since_seq=$s',
      );

  ChatRepository makeRepo() => ChatRepository(
        roomsDao: db.roomsDao,
        messagesDao: db.messagesDao,
        outboxDao: db.outboxDao,
        mediaUploadsDao: db.mediaUploadsDao,
        syncEngine: makeSync(),
        currentUserId: () => me,
        clock: () => now,
      );

  OutboxWorker makeWorker() => OutboxWorker(
        http: http,
        outboxDao: db.outboxDao,
        messagesDao: db.messagesDao,
        mediaUploadsDao: db.mediaUploadsDao,
        sendMessagePath: '/Chat-Message',
        clock: () => now,
      );

  // === DriftMessageMapper ====================================================

  group('DriftMessageMapper', () {
    test('maps lifecycle state, audio->voice, and read status', () async {
      final room = await seedRoom();
      await insertMsg(
        cuid: 'a',
        room: room,
        sid: 1,
        type: MessageContentType.audio,
        state: MessageState.read,
      );
      final row = await db.messagesDao.findByServerMessageId(1);
      final e = DriftMessageMapper.toEntity(row!, currentUserId: me);

      expect(e.type, 'voice'); // audio renders as the legacy "voice" type
      expect(e.messageState.name, 'sent'); // read collapses to sent for the UI
      expect(e.status, 'seen'); // read receipt rides on status
    });

    test('pending -> sending, failed -> error', () async {
      final room = await seedRoom();
      await insertMsg(cuid: 'p', room: room, sid: null, state: MessageState.pending);
      await insertMsg(cuid: 'f', room: room, sid: 2, state: MessageState.failed);

      final pending = await db.messagesDao.findByClientUuid('p');
      final failed = await db.messagesDao.findByClientUuid('f');

      expect(DriftMessageMapper.toEntity(pending!, currentUserId: me).messageState.name,
          'sending');
      expect(DriftMessageMapper.toEntity(failed!, currentUserId: me).messageState.name,
          'error');
    });

    test('decodes reacts / attachment / reply JSON into entity sub-objects',
        () async {
      final room = await seedRoom();
      await insertMsg(
        cuid: 'rich',
        room: room,
        sid: 3,
        type: MessageContentType.image,
        reactsJson: jsonEncode([
          {
            'react': '❤️',
            'userReact': {'userId': 9, 'userName': 'A', 'userImage': 'u'}
          }
        ]),
        attachmentJson: jsonEncode({'file': 'f.jpg', 'type': 'image/jpeg', 'firstFrame': 't.jpg'}),
        replyPreviewJson: jsonEncode({'messageId': 7, 'message': 'orig', 'messageType': 'text'}),
      );
      final row = await db.messagesDao.findByServerMessageId(3);
      final e = DriftMessageMapper.toEntity(row!, currentUserId: me);

      expect(e.reacts?.length, 1);
      expect(e.reacts!.first.react, '❤️');
      expect(e.albums?.file, 'f.jpg');
      expect(e.replay?.message, 'orig');
    });

    test('delete-for-all hides for both sides', () async {
      final room = await seedRoom();
      await insertMsg(cuid: 'd', room: room, sid: 4);
      await db.messagesDao
          .setDeleteStateByServerIds([4], MessageDeleteState.deletedForAll);
      final row = await db.messagesDao.findByServerMessageId(4);
      final e = DriftMessageMapper.toEntity(row!, currentUserId: me);

      expect(e.senderDeleted, true);
      expect(e.receiverDeleted, true);
    });
  });

  // === RealtimeMessageMapper (server JSON -> drift, snake_case tolerant) =====

  group('RealtimeMessageMapper parity columns', () {
    test('round-trips server reacts/album/reply/status to the UI entity',
        () async {
      final room = await seedRoom();
      const mapper = RealtimeMessageMapper();
      final comp = mapper.toCompanion({
        'client_uuid': 'srv',
        'id': 50,
        'server_seq': 10,
        'user_id': 9,
        'type': 'image',
        'message': 'hi',
        'created_at': 1700000000000,
        'status': 'seen',
        'reacts': [
          {
            'react': '👍',
            'user': {'user_id': 9, 'name': 'A', 'image': 'u'}
          }
        ],
        'albums': {'file': 'f.jpg', 'type': 'image/jpeg', 'first_frame': 't.jpg'},
        'replay': {'message_id': 7, 'body': 'orig', 'type': 'text'},
      }, roomLocalId: room);

      expect(comp, isNotNull);
      await db.messagesDao.upsertFromServer(comp!);
      final row = await db.messagesDao.findByServerMessageId(50);
      final e = DriftMessageMapper.toEntity(row!, currentUserId: me);

      expect(e.status, 'seen');
      expect(e.type, 'image');
      expect(e.reacts?.length, 1);
      expect(e.reacts!.first.react, '👍');
      expect(e.albums?.file, 'f.jpg');
      expect(e.replay?.message, 'orig');
    });
  });

  // === ChatRepository.react / deleteMessages =================================

  group('ChatRepository.react', () {
    test('adds my reaction optimistically and enqueues a react op', () async {
      final room = await seedRoom();
      await insertMsg(cuid: 'm1', room: room, sid: 100);
      final repo = makeRepo();

      await repo.react(
        roomLocalId: room,
        serverMessageId: 100,
        reactType: '❤️',
        reactPath: '/Chat-Message-React',
      );

      final row = await db.messagesDao.findByServerMessageId(100);
      final reacts = jsonDecode(row!.reactsJson!) as List;
      expect(reacts.length, 1);
      expect(reacts.first['react'], '❤️');
      expect(reacts.first['userReact']['userId'], me);

      final op = await db.outboxDao.dueOps(nowMs: now);
      expect(op.any((o) => o.opType == OutboxOpType.react), true);
      final payload = jsonDecode(op.first.payloadJson) as Map;
      expect(payload['__path'], '/Chat-Message-React');
      expect(payload['message_id'], 100);
    });

    test('reacting with the same emoji toggles it off', () async {
      final room = await seedRoom();
      await insertMsg(cuid: 'm2', room: room, sid: 101);
      final repo = makeRepo();

      await repo.react(
          roomLocalId: room, serverMessageId: 101, reactType: '❤️', reactPath: '/x');
      await repo.react(
          roomLocalId: room, serverMessageId: 101, reactType: '❤️', reactPath: '/x');

      final row = await db.messagesDao.findByServerMessageId(101);
      expect(row!.reactsJson, isNull); // toggled back to empty -> cleared
    });
  });

  group('ChatRepository.deleteMessages', () {
    test('marks delete-for-all and enqueues a delete op', () async {
      final room = await seedRoom();
      await insertMsg(cuid: 'm3', room: room, sid: 200);
      final repo = makeRepo();

      await repo.deleteMessages(
        roomLocalId: room,
        serverMessageIds: [200],
        forEveryone: true,
        deletePath: '/delete-Chat-Message',
      );

      final row = await db.messagesDao.findByServerMessageId(200);
      expect(row!.deleteState, MessageDeleteState.deletedForAll);

      final ops = await db.outboxDao.dueOps(nowMs: now);
      final del = ops.firstWhere((o) => o.opType == OutboxOpType.delete);
      final payload = jsonDecode(del.payloadJson) as Map;
      expect(payload['__path'], '/delete-Chat-Message');
      expect((payload['message_id'] as List).first, '200');
    });
  });

  // === OutboxWorker side-effect ops =========================================

  group('OutboxWorker side-effect ops', () {
    Future<void> enqueueOp(OutboxOpType type, String path) async {
      await db.outboxDao.enqueue(OutboxCompanion.insert(
        opType: type,
        clientUuid: 'op-${type.name}',
        roomId: 1,
        payloadJson: jsonEncode({'__path': path, 'message_id': 1}),
        createdAt: now,
      ));
    }

    test('react op POSTs to __path with Idempotency-Key and is removed on 200',
        () async {
      await enqueueOp(OutboxOpType.react, '/Chat-Message-React');
      final report = await makeWorker().drainOnce();

      expect(report.succeeded, 1);
      expect(http.postCalls.single.path, '/Chat-Message-React');
      expect(http.postCalls.single.headers?['Idempotency-Key'], 'op-react');
      expect(await db.outboxDao.findByClientUuid('op-react'), isNull);
    });

    test('permanent 4xx drops the side-effect op (no infinite retry)', () async {
      http.onPost = (p, d, h) async => throw DioException(
            requestOptions: RequestOptions(path: p),
            response: Response(
                requestOptions: RequestOptions(path: p), statusCode: 403),
          );
      await enqueueOp(OutboxOpType.delete, '/delete-Chat-Message');
      final report = await makeWorker().drainOnce();

      expect(report.total, 1);
      expect(await db.outboxDao.findByClientUuid('op-delete'), isNull);
    });

    test('transient 5xx keeps the op and backs off', () async {
      http.onPost = (p, d, h) async => throw DioException(
            requestOptions: RequestOptions(path: p),
            response: Response(
                requestOptions: RequestOptions(path: p), statusCode: 500),
          );
      await enqueueOp(OutboxOpType.markRead, '/groups/1/read');
      await makeWorker().drainOnce();

      final op = await db.outboxDao.findByClientUuid('op-markRead');
      expect(op, isNotNull); // still queued for retry
      expect(op!.attempts, greaterThan(0));
    });
  });
}
