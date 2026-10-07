// Phase 5 — SyncEngine behaviour against an in-memory drift db + fake HTTP.
//
// Verifies the gap-fill / recovery fallback contract:
//   * syncRoom pulls ?since_seq=<localMax> and upserts every message + advances
//     the sync cursor and room last-seq
//   * fillGap only fetches when there is an actual hole (expected > localMax+1)
//   * onSubscribed(recovered:true, same epoch) is a no-op (realtime replayed it)
//   * onSubscribed(recovered:false) triggers a catch-up fetch
//   * epoch change forces a resync starting from my_last_read_seq
//   * dedup: re-applying the same payload does not duplicate rows

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
  late FakeRealtimeHttp http;

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

  Future<int> seedRoom({
    required int serverRoomId,
    int myLastReadSeq = 0,
  }) async {
    return db.roomsDao.insertRoom(RoomsCompanion.insert(
      type: RoomType.dm,
      serverRoomId: Value(serverRoomId),
      myLastReadSeq: Value(myLastReadSeq),
    ));
  }

  Response<dynamic> withMessages(List<Map<String, dynamic>> msgs) =>
      Response<dynamic>(
        requestOptions: RequestOptions(path: '/sync'),
        statusCode: 200,
        data: {'data': msgs},
      );

  Map<String, dynamic> serverMsg({
    required int id,
    required int seq,
    int roomId = 1,
    String body = 'm',
  }) =>
      {
        'id': id,
        'client_uuid': 'srv-$id',
        'server_seq': seq,
        'chat_room_id': roomId,
        'user_id': 2,
        'type': 'text',
        'message': body,
        'created_at': 1700000000000,
      };

  test('syncRoom fetches since the local max and applies all messages',
      () async {
    final localId = await seedRoom(serverRoomId: 1);
    http.onGet = (path) async {
      expect(path, contains('since_seq=0'));
      return withMessages([
        serverMsg(id: 1, seq: 1),
        serverMsg(id: 2, seq: 2),
        serverMsg(id: 3, seq: 3),
      ]);
    };

    final applied =
        await makeEngine().syncRoom(roomLocalId: localId, serverRoomId: 1);

    expect(applied, 3);
    expect(await db.messagesDao.maxServerSeq(localId), 3);
    final state = await db.syncStateDao.forRoom(localId);
    expect(state!.lastKnownSeq, 3);
    final room = await db.roomsDao.findByLocalId(localId);
    expect(room!.lastServerSeq, 3);
  });

  test('syncRoom resumes from the highest local seq', () async {
    final localId = await seedRoom(serverRoomId: 1);
    await db.messagesDao.upsertFromServer(MessagesCompanion.insert(
      clientUuid: 'existing',
      roomId: localId,
      kind: MessageKind.user,
      type: MessageContentType.text,
      createdAtClient: 0,
      state: MessageState.delivered,
      serverMessageId: const Value(10),
      serverSeq: const Value(7),
    ));
    http.onGet = (path) async {
      expect(path, contains('since_seq=7'));
      return withMessages([serverMsg(id: 11, seq: 8)]);
    };

    final applied =
        await makeEngine().syncRoom(roomLocalId: localId, serverRoomId: 1);
    expect(applied, 1);
    expect(await db.messagesDao.maxServerSeq(localId), 8);
  });

  test('fillGap fetches only when a real hole exists', () async {
    final localId = await seedRoom(serverRoomId: 1);
    // local max is 0; expectedAfterSeq 1 means no hole (next contiguous seq).
    final noHole = await makeEngine().fillGap(
      roomLocalId: localId,
      serverRoomId: 1,
      expectedAfterSeq: 1,
      beforeMax: 0,
    );
    expect(noHole, 0);
    expect(http.getCalls, isEmpty);

    // expectedAfterSeq 5 with pre-apply max 0 -> hole, must fetch from since_seq=0.
    http.onGet = (_) async => withMessages([
          serverMsg(id: 1, seq: 1),
          serverMsg(id: 2, seq: 2),
        ]);
    final filled = await makeEngine().fillGap(
      roomLocalId: localId,
      serverRoomId: 1,
      expectedAfterSeq: 5,
      beforeMax: 0,
    );
    expect(filled, 2);
    expect(http.getCalls.length, 1);
  });

  test('onSubscribed with recovered:true and unchanged epoch is a no-op',
      () async {
    final localId = await seedRoom(serverRoomId: 1);
    final applied = await makeEngine().onSubscribed(
      roomLocalId: localId,
      serverRoomId: 1,
      recovered: true,
      epoch: 'e1',
    );
    expect(applied, 0);
    expect(http.getCalls, isEmpty);
    // epoch is persisted for future change-detection.
    final state = await db.syncStateDao.forRoom(localId);
    expect(state!.epoch, 'e1');
  });

  test('onSubscribed with recovered:false triggers a catch-up fetch', () async {
    final localId = await seedRoom(serverRoomId: 1);
    http.onGet = (_) async => withMessages([serverMsg(id: 1, seq: 1)]);

    final applied = await makeEngine().onSubscribed(
      roomLocalId: localId,
      serverRoomId: 1,
      recovered: false,
      epoch: 'e1',
    );
    expect(applied, 1);
    expect(http.getCalls.length, 1);
  });

  test('epoch change forces resync from my_last_read_seq', () async {
    final localId = await seedRoom(serverRoomId: 1, myLastReadSeq: 4);
    // Establish a prior epoch.
    await db.syncStateDao.setCursor(
      roomId: localId,
      lastKnownSeq: 9,
      epoch: 'old',
      nowMs: 1,
    );

    http.onGet = (path) async {
      // Must restart from the read high-water-mark, not the local max.
      expect(path, contains('since_seq=4'));
      return withMessages([serverMsg(id: 5, seq: 5)]);
    };

    final applied = await makeEngine().onSubscribed(
      roomLocalId: localId,
      serverRoomId: 1,
      recovered: true, // recovered true but epoch rotated -> still resync
      epoch: 'new',
    );
    expect(applied, 1);
    expect(http.getCalls.length, 1);
  });

  test('re-applying the same messages does not duplicate rows', () async {
    final localId = await seedRoom(serverRoomId: 1);
    http.onGet = (_) async => withMessages([
          serverMsg(id: 1, seq: 1),
          serverMsg(id: 2, seq: 2),
        ]);

    await makeEngine().syncRoom(roomLocalId: localId, serverRoomId: 1);
    // Second pass returns the same payload (overlapping recovery window).
    await makeEngine().syncRoom(roomLocalId: localId, serverRoomId: 1);

    final rows = await db.messagesDao.getOlderPage(
      roomId: localId,
      beforeServerSeq: 1000,
      limit: 100,
    );
    expect(rows.length, 2);
  });
}
