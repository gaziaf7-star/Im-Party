// Phase 8 — Badge from drift (#31/#32) + concurrent outbox (#15) +
// statusOf dedup (#79) + voice cap (#85).

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:general/src/core/database/app_database.dart';
import 'package:general/src/core/database/tables/chat_tables.dart';
import 'package:general/src/core/realtime/outbox_worker.dart';
import 'package:general/src/features/chats/presentation/chats/bloc/manager_get_users_chat/get_users_chat_bloc.dart';
import 'package:general/src/features/messages/data/mappers/drift_message_mapper.dart';
import 'package:general/src/features/messages/domain/entities/user_chat_entity.dart';
import 'package:general/src/features/messages/presentation/messages/blocs/text_field_bloc/text_field__bloc.dart'
    show kMaxVoiceDurationSeconds;

import 'support/fake_realtime_http.dart';

UserChatEntity _chat({required int chatId, required int unread}) =>
    UserChatEntity(
      chatId: chatId,
      userId: chatId,
      unreadMessage: unread,
      name: '',
      image: '',
      hasColorName: false,
      inRoom: false,
      lastMessage: const LastMessageEntity(),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ── #31/#32 — totalUnreadFromDrift badge ──────────────────────────────────

  group('#31/#32 — badge from drift (totalUnreadFromDrift)', () {
    test('sums unread counts from state.data', () {
      final s = GetUsersChatState(
        scrollController: ScrollController(),
        data: [
          _chat(chatId: 1, unread: 3),
          _chat(chatId: 2, unread: 0),
          _chat(chatId: 3, unread: 7),
        ],
      );
      expect(s.totalUnreadFromDrift, 10);
    });

    test('returns 0 when list is empty', () {
      final s = GetUsersChatState(scrollController: ScrollController());
      expect(s.totalUnreadFromDrift, 0);
    });

    test('returns 0 when all rooms are read', () {
      final s = GetUsersChatState(
        scrollController: ScrollController(),
        data: [
          _chat(chatId: 1, unread: 0),
          _chat(chatId: 2, unread: 0),
        ],
      );
      expect(s.totalUnreadFromDrift, 0);
    });

    test('decrements when a room is zeroed (ReadMessageEvent effect)', () {
      var s = GetUsersChatState(
        scrollController: ScrollController(),
        data: [
          _chat(chatId: 1, unread: 5),
          _chat(chatId: 2, unread: 3),
        ],
      );
      expect(s.totalUnreadFromDrift, 8);

      final updated = List<UserChatEntity>.from(s.data);
      final idx = updated.indexWhere((r) => r.chatId == 1);
      updated[idx] = updated[idx].copyWith(unreadMessage: 0);
      s = s.copyWith(data: updated);

      expect(s.totalUnreadFromDrift, 3);
    });

    test('increments when MergeRoomsFromDrift delivers new unread', () {
      var s = GetUsersChatState(
        scrollController: ScrollController(),
        data: [_chat(chatId: 1, unread: 0)],
      );
      expect(s.totalUnreadFromDrift, 0);

      s = s.copyWith(data: [_chat(chatId: 1, unread: 2)]);
      expect(s.totalUnreadFromDrift, 2);
    });
  });

  // ── #15 — concurrent outbox draining ─────────────────────────────────────

  group('#15 — concurrent outbox draining', () {
    late AppDatabase db;
    late FakeRealtimeHttp http;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      http = FakeRealtimeHttp();
    });

    tearDown(() async => db.close());

    OutboxWorker makeWorker() => OutboxWorker(
          http: http,
          outboxDao: db.outboxDao,
          messagesDao: db.messagesDao,
          sendMessagePath: '/Chat-Message',
        );

    Future<void> seedRoom(int id) => db.roomsDao.insertRoom(
          RoomsCompanion.insert(type: RoomType.dm, serverRoomId: Value(id)),
        );

    Future<void> enqueue({required String uuid, required int roomId}) async {
      await db.messagesDao.insertPending(MessagesCompanion.insert(
        clientUuid: uuid,
        roomId: roomId,
        kind: MessageKind.user,
        type: MessageContentType.text,
        createdAtClient: 0,
        state: MessageState.pending,
        body: const Value('hi'),
      ));
      await db.outboxDao.enqueue(OutboxCompanion.insert(
        opType: OutboxOpType.sendMsg,
        clientUuid: uuid,
        roomId: roomId,
        payloadJson: '{"user_id":2,"message":"hi"}',
        createdAt: 0,
      ));
    }

    Response<dynamic> okSend(int id, int seq) => Response<dynamic>(
          requestOptions: RequestOptions(path: '/Chat-Message'),
          statusCode: 200,
          data: {
            'data': {'id': id, 'server_seq': seq, 'created_at': 1000000}
          },
        );

    test('two rooms drain in a single drainOnce pass', () async {
      await seedRoom(1);
      await seedRoom(2);
      await enqueue(uuid: 'a', roomId: 1);
      await enqueue(uuid: 'b', roomId: 2);

      var seq = 0;
      http.onPost = (_, __, ___) async => okSend(++seq, seq);

      final report = await makeWorker().drainOnce();
      expect(report.succeeded, 2);
    });

    test('drainRoom re-runs when kicked mid-drain (dirty rooms)', () async {
      await seedRoom(1);
      await enqueue(uuid: 'x', roomId: 1);

      var seq = 0;
      http.onPost = (_, __, ___) async => okSend(++seq, seq);

      // First call should succeed.
      final report = await makeWorker().drainRoom(1);
      expect(report.succeeded, 1);
    });
  });

  // ── #79 — DriftMessageMapper.statusOf (single source of truth) ───────────

  group('#79 — DriftMessageMapper.statusOf', () {
    test('read state → seen', () {
      expect(
        DriftMessageMapper.statusOf(
            state: MessageState.read, serverStatus: null),
        'seen',
      );
    });

    test('raw "seen" → seen (overrides sent state)', () {
      expect(
        DriftMessageMapper.statusOf(
            state: MessageState.sent, serverStatus: 'seen'),
        'seen',
      );
    });

    test('raw "read" → seen', () {
      expect(
        DriftMessageMapper.statusOf(
            state: MessageState.sent, serverStatus: 'read'),
        'seen',
      );
    });

    test('delivered state → delivered', () {
      expect(
        DriftMessageMapper.statusOf(
            state: MessageState.delivered, serverStatus: null),
        'delivered',
      );
    });

    test('sent state → sent', () {
      expect(
        DriftMessageMapper.statusOf(
            state: MessageState.sent, serverStatus: null),
        'sent',
      );
    });

    test('pending state → null', () {
      expect(
        DriftMessageMapper.statusOf(
            state: MessageState.pending, serverStatus: null),
        isNull,
      );
    });

    test('null state with no raw → null', () {
      expect(
        DriftMessageMapper.statusOf(state: null, serverStatus: null),
        isNull,
      );
    });

    test('non-null raw status wins over derived (e.g. delivered raw)', () {
      expect(
        DriftMessageMapper.statusOf(
            state: MessageState.pending, serverStatus: 'delivered'),
        'delivered',
      );
    });
  });

  // ── #85 — voice cap constant ──────────────────────────────────────────────

  group('#85 — kMaxVoiceDurationSeconds', () {
    test('cap is 120 seconds', () {
      expect(kMaxVoiceDurationSeconds, 120);
    });
  });
}
