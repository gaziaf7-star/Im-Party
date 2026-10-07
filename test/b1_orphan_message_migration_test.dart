// B1 — orphan DM room message migration (data-loss root fix).
//
// Regression coverage for the bug where opening a DM without a serverRoomId
// created an ORPHAN room (serverRoomId null/0) that held messages, and when the
// real serverRoomId arrived the orphan was DELETED — cascading
// (messages.roomId onDelete:cascade) and permanently destroying every message.
//
// The professional fix MIGRATES the orphan's messages onto the surviving real
// room BEFORE deleting the orphan. These tests assert that no message is ever
// lost across every reconciliation path:
//   * upsertByServerRoomId (real room materializes -> orphan folded in)
//   * deleteOrphanDmRooms   (rooms-list sync cleanup)
//   * getOrCreateDmRoom     (unified atomic get-or-create)
//   * the v7 schema recovery migration (existing installs with stranded data)

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:general/src/core/database/app_database.dart';
import 'package:general/src/core/database/tables/chat_tables.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> insertRoom({int? serverRoomId, int? peerUserId}) {
    return db.roomsDao.insertRoom(RoomsCompanion.insert(
      type: RoomType.dm,
      serverRoomId: Value(serverRoomId),
      peerUserId: Value(peerUserId),
    ));
  }

  Future<void> insertMsg({
    required String clientUuid,
    required int roomId,
    int? serverSeq,
    int createdAtClient = 0,
  }) async {
    await db.messagesDao.insertPending(MessagesCompanion.insert(
      clientUuid: clientUuid,
      roomId: roomId,
      kind: MessageKind.user,
      type: MessageContentType.text,
      createdAtClient: createdAtClient,
      state: MessageState.sent,
      serverSeq: Value(serverSeq),
      body: const Value('hi'),
    ));
  }

  Future<int> messageCountForRoom(int roomLocalId) async {
    final rows = await db.messagesDao.watchRoomMessages(roomLocalId).first;
    return rows.length;
  }

  Future<int> totalMessageCount() async {
    final rows = await db.select(db.messages).get();
    return rows.length;
  }

  group('B1 upsertByServerRoomId migrates orphan messages', () {
    test('orphan messages survive when the real room materializes', () async {
      // Orphan room (no server id) holds two messages.
      final orphan = await insertRoom(serverRoomId: null, peerUserId: 42);
      await insertMsg(clientUuid: 'm1', roomId: orphan, createdAtClient: 1);
      await insertMsg(clientUuid: 'm2', roomId: orphan, createdAtClient: 2);

      // Real server room for the same peer arrives.
      final realLocalId = await db.roomsDao.upsertByServerRoomId(
        RoomsCompanion(
          serverRoomId: const Value(9001),
          type: const Value(RoomType.dm),
          peerUserId: const Value(42),
        ),
      );

      // The orphan must be gone, but BOTH messages must now live on the real
      // room — none destroyed by the cascade.
      final orphanGone = await db.roomsDao.findByLocalId(orphan);
      expect(orphanGone, isNull);
      expect(await messageCountForRoom(realLocalId), 2);
      expect(await totalMessageCount(), 2);
    });

    test('duplicate client_uuid across rooms is skipped, not lost-and-aborted',
        () async {
      final orphan = await insertRoom(serverRoomId: null, peerUserId: 7);
      final real = await insertRoom(serverRoomId: 5000, peerUserId: 7);
      // Same uuid already present in BOTH rooms (received via another path).
      await insertMsg(clientUuid: 'dup', roomId: orphan);
      await insertMsg(clientUuid: 'dup', roomId: real);
      await insertMsg(clientUuid: 'only-orphan', roomId: orphan);

      final realLocalId = await db.roomsDao.upsertByServerRoomId(
        RoomsCompanion(
          serverRoomId: const Value(5000),
          type: const Value(RoomType.dm),
          peerUserId: const Value(7),
        ),
      );
      expect(realLocalId, real);

      // The unique 'only-orphan' message migrated; the 'dup' collision was
      // skipped (the real room keeps its own copy). No transaction abort.
      final bodies = await db.messagesDao.watchRoomMessages(real).first;
      final uuids = bodies.map((m) => m.clientUuid).toSet();
      expect(uuids, containsAll(<String>{'dup', 'only-orphan'}));
      expect(await db.roomsDao.findByLocalId(orphan), isNull);
    });
  });

  group('B1 deleteOrphanDmRooms migrates before deleting', () {
    test('messages move to the real room; orphan removed', () async {
      final orphan = await insertRoom(serverRoomId: 0, peerUserId: 99);
      final real = await insertRoom(serverRoomId: 12345, peerUserId: 99);
      await insertMsg(clientUuid: 'a', roomId: orphan);
      await insertMsg(clientUuid: 'b', roomId: orphan);

      final removed = await db.roomsDao.deleteOrphanDmRooms();
      expect(removed, 1);
      expect(await db.roomsDao.findByLocalId(orphan), isNull);
      expect(await messageCountForRoom(real), 2);
      expect(await totalMessageCount(), 2);
    });

    test('orphan with no matching real room is left untouched', () async {
      final orphan = await insertRoom(serverRoomId: null, peerUserId: 1);
      await insertMsg(clientUuid: 'x', roomId: orphan);

      final removed = await db.roomsDao.deleteOrphanDmRooms();
      expect(removed, 0);
      expect(await db.roomsDao.findByLocalId(orphan), isNotNull);
      expect(await messageCountForRoom(orphan), 1);
    });
  });

  group('B1 getOrCreateDmRoom is atomic and never duplicates a peer', () {
    test('serverRoomId>0 folds an existing orphan in with its messages',
        () async {
      final orphan = await insertRoom(serverRoomId: null, peerUserId: 55);
      await insertMsg(clientUuid: 'g1', roomId: orphan);

      final localId = await db.roomsDao.getOrCreateDmRoom(
        serverRoomId: 7777,
        peerUserId: 55,
        title: 'Peer 55',
      );

      expect(await db.roomsDao.findByLocalId(orphan), isNull);
      expect(await messageCountForRoom(localId), 1);
      final room = await db.roomsDao.findByLocalId(localId);
      expect(room?.serverRoomId, 7777);
    });

    test('serverRoomId==0 reuses the peer existing room (no duplicate)',
        () async {
      final existing = await insertRoom(serverRoomId: 8888, peerUserId: 33);

      final localId = await db.roomsDao.getOrCreateDmRoom(
        serverRoomId: 0,
        peerUserId: 33,
        title: 'updated',
      );

      expect(localId, existing);
      final all = await db.select(db.rooms).get();
      expect(all.where((r) => r.peerUserId == 33), hasLength(1));
    });
  });

  group('B1 v7 schema recovery migrates stranded data on existing installs', () {
    test('orphan messages are recovered into the peer real room on upgrade',
        () async {
      // Build a DB that already contains a stranded orphan (the pre-fix state),
      // then run the v7 recovery step the migration invokes.
      final orphan = await insertRoom(serverRoomId: null, peerUserId: 21);
      final real = await insertRoom(serverRoomId: 4242, peerUserId: 21);
      await insertMsg(clientUuid: 'r1', roomId: orphan);
      await insertMsg(clientUuid: 'r2', roomId: orphan);
      await insertMsg(clientUuid: 'r3', roomId: real);

      await db.runOrphanRecoveryForTest();

      expect(await db.roomsDao.findByLocalId(orphan), isNull);
      expect(await messageCountForRoom(real), 3);
      expect(await totalMessageCount(), 3);
    });
  });
}
