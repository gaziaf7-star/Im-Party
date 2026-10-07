// Phase 3 — realtime + offline-sync correctness (previously-silent bugs).
//
// Locks the cache-consistency contract for the load-bearing receive/sync paths,
// against an in-memory SQLite db (+ fake HTTP for the SyncEngine cases):
//
//   * #54 SyncStateDao.setCursor is MONOTONIC — a lower lastKnownSeq can never
//     regress a higher one (epoch still written), so a clean resubscribe /
//     out-of-order publication can't rewind the recovery cursor.
//   * #61 RoomsDao.markRead does NOT overcount: reaching the high-water-mark is
//     a full clear; it never re-derives unread from the raw seq span (which
//     counts the user's own messages).
//   * #21 MessagesDao.upsertFromServer reconciles a cross-row serverMessageId
//     duplicate (a `srv:<id>` phantom holding the id our optimistic echo is
//     about to claim) instead of throwing UNIQUE and dropping the message.
//   * #19 SyncEngine._fetchAndApply bumps the room's last message ONCE with the
//     NEWEST row in the batch, not whichever row is iterated last.
//   * #18 RoomsDao.applyIncomingMessageMeta never rewinds the last-message
//     pointer / updatedAt on a re-delivered (non-advancing) seq.

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:general/src/core/database/app_database.dart';
import 'package:general/src/core/database/tables/chat_tables.dart';
import 'package:general/src/core/realtime/sync_engine.dart';

import 'support/fake_realtime_http.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  Future<int> seedRoom({int? serverRoomId}) {
    return db.roomsDao.insertRoom(RoomsCompanion.insert(
      type: RoomType.dm,
      serverRoomId: Value(serverRoomId),
    ));
  }

  MessagesCompanion msg({
    required String clientUuid,
    required int roomId,
    int? serverMessageId,
    int? serverSeq,
    int createdAtClient = 0,
    int? senderId,
    MessageState state = MessageState.pending,
    String body = 'hi',
  }) {
    return MessagesCompanion.insert(
      clientUuid: clientUuid,
      roomId: roomId,
      kind: MessageKind.user,
      type: MessageContentType.text,
      createdAtClient: createdAtClient,
      state: state,
      senderId: Value(senderId),
      serverMessageId: Value(serverMessageId),
      serverSeq: Value(serverSeq),
      body: Value(body),
    );
  }

  // --- #54 cursor monotonic --------------------------------------------------

  group('#54 setCursor is monotonic', () {
    test('a lower lastKnownSeq never regresses a higher one', () async {
      await db.syncStateDao.setCursor(roomId: 1, lastKnownSeq: 50, nowMs: 1);
      // A clean resubscribe re-stamps from a lower local max.
      await db.syncStateDao.setCursor(roomId: 1, lastKnownSeq: 30, nowMs: 2);

      final s = await db.syncStateDao.forRoom(1);
      expect(s!.lastKnownSeq, 50, reason: 'cursor must not move backward');
    });

    test('forward advances are still applied', () async {
      await db.syncStateDao.setCursor(roomId: 1, lastKnownSeq: 10, nowMs: 1);
      await db.syncStateDao.setCursor(roomId: 1, lastKnownSeq: 25, nowMs: 2);

      final s = await db.syncStateDao.forRoom(1);
      expect(s!.lastKnownSeq, 25);
    });

    test('epoch is written even when the seq does not advance', () async {
      await db.syncStateDao
          .setCursor(roomId: 1, lastKnownSeq: 40, epoch: 'e1', nowMs: 1);
      // Lower seq but a NEW epoch — epoch must update, seq must hold at 40.
      await db.syncStateDao
          .setCursor(roomId: 1, lastKnownSeq: 5, epoch: 'e2', nowMs: 2);

      final s = await db.syncStateDao.forRoom(1);
      expect(s!.lastKnownSeq, 40);
      expect(s.epoch, 'e2');
      expect(await db.syncStateDao.hasEpochChanged(1, 'e2'), isFalse);
    });
  });

  // --- #61 markRead does not overcount ---------------------------------------

  group('#61 markRead unread math', () {
    test('reaching the high-water-mark fully clears unread', () async {
      final room = await seedRoom(serverRoomId: 1);
      await db.roomsDao.applyIncomingMessageMeta(
        roomLocalId: room,
        lastMessageLocalId: 1,
        serverSeq: 8,
        serverCreatedAt: 1,
        incrementUnread: true,
      );
      await db.roomsDao.markRead(room, 8);

      final r = await db.roomsDao.findByLocalId(room);
      expect(r!.myLastReadSeq, 8);
      expect(r.unreadCount, 0);
    });

    test('own messages in the span do NOT inflate the count at the HWM',
        () async {
      final room = await seedRoom(serverRoomId: 1);
      // Mixed traffic: room high-water-mark is 10, but only 1 message was
      // actually unread (the rest are my own sends interleaved). Reaching seq 10
      // is a FULL clear — the raw delta (lastServerSeq - upToSeq) is irrelevant.
      await db.roomsDao.updateRoom(
        room,
        const RoomsCompanion(
          lastServerSeq: Value(10),
          unreadCount: Value(1),
          myLastReadSeq: Value(9),
        ),
      );
      await db.roomsDao.markRead(room, 10);

      final r = await db.roomsDao.findByLocalId(room);
      expect(r!.unreadCount, 0,
          reason: 'caught up to HWM => 0, never a re-derived span');
    });

    test('a read short of the HWM does not re-derive an inflated remainder',
        () async {
      final room = await seedRoom(serverRoomId: 1);
      await db.roomsDao.updateRoom(
        room,
        const RoomsCompanion(
          lastServerSeq: Value(20),
          unreadCount: Value(3),
          myLastReadSeq: Value(5),
        ),
      );
      // Advance the read cursor but stay below the HWM.
      await db.roomsDao.markRead(room, 12);

      final r = await db.roomsDao.findByLocalId(room);
      expect(r!.myLastReadSeq, 12);
      // The pre-existing count is left intact (not re-derived to 20-12=8).
      expect(r.unreadCount, 3);
    });

    test('a stale (<= myLastReadSeq) receipt is a no-op', () async {
      final room = await seedRoom(serverRoomId: 1);
      await db.roomsDao.updateRoom(
        room,
        const RoomsCompanion(
          lastServerSeq: Value(10),
          unreadCount: Value(2),
          myLastReadSeq: Value(7),
        ),
      );
      await db.roomsDao.markRead(room, 5);

      final r = await db.roomsDao.findByLocalId(room);
      expect(r!.myLastReadSeq, 7);
      expect(r.unreadCount, 2);
    });
  });

  // --- #21 upsertFromServer reconciles a cross-row serverMessageId duplicate -

  group('#21 upsertFromServer dedup by serverMessageId', () {
    test('uuid-matched row claiming an id held by a phantom does not throw',
        () async {
      final room = await seedRoom(serverRoomId: 1);

      // 1) A `srv:<id>` phantom row already holds server message id 900 (arrived
      //    via the user-channel fan-out before our own echo).
      await db.messagesDao.upsertFromServer(msg(
        clientUuid: 'srv:900',
        roomId: room,
        serverMessageId: 900,
        serverSeq: 5,
        state: MessageState.delivered,
        body: 'phantom',
      ));

      // 2) Our optimistic send is pending under its own client_uuid.
      final mineLocalId = await db.messagesDao.insertPending(
        msg(clientUuid: 'mine', roomId: room, body: 'real'),
      );

      // 3) The server echo of OUR message carries our client_uuid AND server
      //    message id 900 — previously this threw UNIQUE(serverMessageId).
      final resolved = await db.messagesDao.upsertFromServer(msg(
        clientUuid: 'mine',
        roomId: room,
        serverMessageId: 900,
        serverSeq: 5,
        state: MessageState.sent,
        body: 'real',
      ));

      expect(resolved, mineLocalId,
          reason: 'id moves onto our canonical row, not a new insert');

      final all = await db.messagesDao.getOlderPage(
        roomId: room,
        beforeServerSeq: 1000,
        limit: 100,
      );
      // The phantom was removed; exactly one row holds server id 900.
      expect(all.where((m) => m.serverMessageId == 900), hasLength(1));
      expect(all, hasLength(1), reason: 'phantom reconciled, not duplicated');
      expect(all.single.clientUuid, 'mine');
      expect(all.single.state, MessageState.sent);
    });

    test('normal uuid dedup (no phantom) still works', () async {
      final room = await seedRoom(serverRoomId: 1);
      final localId = await db.messagesDao
          .insertPending(msg(clientUuid: 'c1', roomId: room));
      final resolved = await db.messagesDao.upsertFromServer(msg(
        clientUuid: 'c1',
        roomId: room,
        serverMessageId: 55,
        serverSeq: 3,
        state: MessageState.sent,
      ));
      expect(resolved, localId);
      final all = await db.messagesDao.watchRoomMessages(room).first;
      expect(all, hasLength(1));
      expect(all.single.serverMessageId, 55);
    });
  });

  // --- #19 / #18 room last-message meta ---------------------------------------

  group('#18 applyIncomingMessageMeta does not rewind', () {
    test('a non-advancing (re-delivered) seq keeps the newer last message',
        () async {
      final room = await seedRoom(serverRoomId: 1);
      // Newest message lands first (seq 10).
      await db.roomsDao.applyIncomingMessageMeta(
        roomLocalId: room,
        lastMessageLocalId: 100,
        serverSeq: 10,
        serverCreatedAt: 5000,
      );
      // An older duplicate is re-delivered (seq 7, earlier timestamp).
      await db.roomsDao.applyIncomingMessageMeta(
        roomLocalId: room,
        lastMessageLocalId: 70,
        serverSeq: 7,
        serverCreatedAt: 3000,
      );

      final r = await db.roomsDao.findByLocalId(room);
      expect(r!.lastMessageLocalId, 100, reason: 'pointer must not rewind');
      expect(r.lastServerSeq, 10);
      expect(r.updatedAt, 5000, reason: 'ordering timestamp must not rewind');
    });

    test('the first message of a fresh room still sets the pointer', () async {
      final room = await seedRoom(serverRoomId: 1);
      await db.roomsDao.applyIncomingMessageMeta(
        roomLocalId: room,
        lastMessageLocalId: 42,
        serverSeq: 1,
        serverCreatedAt: 1000,
      );
      final r = await db.roomsDao.findByLocalId(room);
      expect(r!.lastMessageLocalId, 42);
    });
  });

  group('#19 _fetchAndApply bumps the room with the newest row', () {
    late FakeRealtimeHttp http;

    setUp(() => http = FakeRealtimeHttp());

    SyncEngine makeEngine() => SyncEngine(
          http: http,
          messagesDao: db.messagesDao,
          roomsDao: db.roomsDao,
          syncStateDao: db.syncStateDao,
          sinceSeqUrl: (roomId, sinceSeq) =>
              '/rooms/$roomId/messages?since_seq=$sinceSeq',
        );

    Map<String, dynamic> serverMsg({
      required int id,
      required int seq,
      required int createdAt,
    }) =>
        {
          'id': id,
          'client_uuid': 'srv-$id',
          'server_seq': seq,
          'chat_room_id': 1,
          'user_id': 2,
          'type': 'text',
          'message': 'm$seq',
          'created_at': createdAt,
        };

    test('a newest-first page leaves the NEWEST message as room.lastMessage',
        () async {
      final localId = await seedRoom(serverRoomId: 1);
      // Page is newest-first (seq 3,2,1) — the OLD per-row code left seq 1 as
      // the room's last message. The fix applies meta once with seq 3.
      http.onGet = (_) async => Response<dynamic>(
            requestOptions: RequestOptions(path: '/sync'),
            statusCode: 200,
            data: {
              'data': [
                serverMsg(id: 3, seq: 3, createdAt: 3000),
                serverMsg(id: 2, seq: 2, createdAt: 2000),
                serverMsg(id: 1, seq: 1, createdAt: 1000),
              ],
            },
          );

      final applied =
          await makeEngine().syncRoom(roomLocalId: localId, serverRoomId: 1);
      expect(applied, 3);

      final room = await db.roomsDao.findByLocalId(localId);
      expect(room!.lastServerSeq, 3);
      expect(room.updatedAt, 3000,
          reason: 'room ordering ts is the newest message, not the last-iterated');

      final newest = await db.messagesDao.findByServerMessageId(3);
      expect(room.lastMessageLocalId, newest!.localId,
          reason: 'last message pointer is the newest row');
    });
  });
}
