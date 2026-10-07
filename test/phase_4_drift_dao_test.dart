// Phase 4 — drift (SQLite) data-layer unit tests for the realtime/chat rebuild.
//
// Exercises the load-bearing DAO behaviour against an in-memory SQLite db:
//   * MessagesDao: optimistic insert, upsert dedup (client_uuid + server_msg_id),
//     keyset pagination (server_seq < cursor), reactive stream ordering,
//     pending(null seq) sorts ahead of confirmed, maxServerSeq gap cursor.
//   * RoomsDao: upsert-by-server_room_id, last-message meta bump, read/unread
//     high-water-mark math.
//   * OutboxDao: FIFO due ordering, backoff scheduling via next_retry_at.
//   * SyncStateDao: cursor upsert + epoch-change detection.
//   * MediaUploadsDao: upsert by client_uuid + state transitions.

import 'package:drift/drift.dart' hide isNull;
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
      serverMessageId: Value(serverMessageId),
      serverSeq: Value(serverSeq),
      body: Value(body),
    );
  }

  group('MessagesDao', () {
    test('insertPending stores an optimistic message visible in stream',
        () async {
      final room = await seedRoom();
      await db.messagesDao.insertPending(
        msg(clientUuid: 'c1', roomId: room, createdAtClient: 100),
      );

      final list = await db.messagesDao.watchRoomMessages(room).first;
      expect(list, hasLength(1));
      expect(list.single.clientUuid, 'c1');
      expect(list.single.state, MessageState.pending);
      expect(list.single.serverSeq, isNull);
    });

    test('upsertFromServer dedups by client_uuid (own optimistic send)',
        () async {
      final room = await seedRoom();
      final localId = await db.messagesDao.insertPending(
        msg(clientUuid: 'c1', roomId: room, createdAtClient: 100),
      );

      // Server confirmation arrives carrying the same client_uuid.
      final resolved = await db.messagesDao.upsertFromServer(
        msg(
          clientUuid: 'c1',
          roomId: room,
          serverMessageId: 555,
          serverSeq: 10,
          state: MessageState.sent,
        ),
      );

      expect(resolved, localId, reason: 'must update, not duplicate');
      final all = await db.messagesDao.watchRoomMessages(room).first;
      expect(all, hasLength(1));
      expect(all.single.serverMessageId, 555);
      expect(all.single.serverSeq, 10);
      expect(all.single.state, MessageState.sent);
    });

    test('upsertFromServer dedups by server_message_id when uuid differs',
        () async {
      final room = await seedRoom();
      await db.messagesDao.upsertFromServer(
        msg(
          clientUuid: 'c1',
          roomId: room,
          serverMessageId: 900,
          serverSeq: 5,
          state: MessageState.sent,
        ),
      );

      // Same server message re-delivered via realtime with a different uuid.
      await db.messagesDao.upsertFromServer(
        msg(
          clientUuid: 'c2',
          roomId: room,
          serverMessageId: 900,
          serverSeq: 5,
          state: MessageState.delivered,
        ),
      );

      final all = await db.messagesDao.watchRoomMessages(room).first;
      expect(all, hasLength(1), reason: 'same server_message_id -> one row');
      expect(all.single.state, MessageState.delivered);
    });

    test('stream orders confirmed by server_seq DESC, pending on top',
        () async {
      final room = await seedRoom();
      await db.messagesDao.upsertFromServer(msg(
          clientUuid: 's1',
          roomId: room,
          serverMessageId: 1,
          serverSeq: 1,
          state: MessageState.sent));
      await db.messagesDao.upsertFromServer(msg(
          clientUuid: 's2',
          roomId: room,
          serverMessageId: 2,
          serverSeq: 2,
          state: MessageState.sent));
      // A still-pending local message (null seq, latest client clock).
      await db.messagesDao.insertPending(
          msg(clientUuid: 'p1', roomId: room, createdAtClient: 9999));

      final list = await db.messagesDao.watchRoomMessages(room).first;
      expect(list.map((m) => m.clientUuid).toList(), ['p1', 's2', 's1']);
    });

    test('getOlderPage is keyset (server_seq < cursor) DESC and bounded',
        () async {
      final room = await seedRoom();
      for (var i = 1; i <= 5; i++) {
        await db.messagesDao.upsertFromServer(msg(
            clientUuid: 'm$i',
            roomId: room,
            serverMessageId: i,
            serverSeq: i,
            state: MessageState.sent));
      }

      final page = await db.messagesDao
          .getOlderPage(roomId: room, beforeServerSeq: 4, limit: 2);
      expect(page.map((m) => m.serverSeq).toList(), [3, 2]);
    });

    test('maxServerSeq returns highest stored seq for gap detection',
        () async {
      final room = await seedRoom();
      await db.messagesDao.upsertFromServer(msg(
          clientUuid: 'a',
          roomId: room,
          serverMessageId: 1,
          serverSeq: 7,
          state: MessageState.sent));
      await db.messagesDao.upsertFromServer(msg(
          clientUuid: 'b',
          roomId: room,
          serverMessageId: 2,
          serverSeq: 3,
          state: MessageState.sent));
      // pending row (null seq) must not affect the max.
      await db.messagesDao.insertPending(msg(clientUuid: 'c', roomId: room));

      expect(await db.messagesDao.maxServerSeq(room), 7);
    });

    test('markSent promotes a pending message', () async {
      final room = await seedRoom();
      await db.messagesDao
          .insertPending(msg(clientUuid: 'c1', roomId: room));
      await db.messagesDao.markSent(
          clientUuid: 'c1', serverMessageId: 42, serverSeq: 9);

      final m = await db.messagesDao.findByClientUuid('c1');
      expect(m!.state, MessageState.sent);
      expect(m.serverMessageId, 42);
      expect(m.serverSeq, 9);
    });
  });

  group('RoomsDao', () {
    test('upsertByServerRoomId reuses the row on second call', () async {
      final first = await db.roomsDao.upsertByServerRoomId(
        RoomsCompanion.insert(
            type: RoomType.group, serverRoomId: const Value(77)),
      );
      final second = await db.roomsDao.upsertByServerRoomId(
        RoomsCompanion.insert(
          type: RoomType.group,
          serverRoomId: const Value(77),
          title: const Value('renamed'),
        ),
      );
      expect(second, first);
      final room = await db.roomsDao.findByLocalId(first);
      expect(room!.title, 'renamed');
    });

    test(
        'upsertByServerRoomId deletes orphan DM row for same peer (no duplicate)',
        () async {
      // Orphan: a DM opened from a profile before the server room id was known.
      final orphan = await db.roomsDao.upsertByServerRoomId(
        RoomsCompanion.insert(
          type: RoomType.dm,
          serverRoomId: const Value(0),
          peerUserId: const Value(7),
        ),
      );
      // Real room materialized later (from sync / first realtime message).
      final real = await db.roomsDao.upsertByServerRoomId(
        RoomsCompanion.insert(
          type: RoomType.dm,
          serverRoomId: const Value(42),
          peerUserId: const Value(7),
        ),
      );
      expect(real, isNot(orphan));
      // The orphan must be gone.
      expect(await db.roomsDao.findByLocalId(orphan), isNull);
      // The chats list emits exactly one row for the peer.
      final rooms = await db.roomsDao.watchRoomsWithLast().first;
      final forPeer =
          rooms.where((r) => r.room.peerUserId == 7).toList();
      expect(forPeer.length, 1);
      expect(forPeer.first.room.serverRoomId, 42);
    });

    test('applyIncomingMessageMeta bumps seq + unread', () async {
      final room = await seedRoom(serverRoomId: 1);
      await db.roomsDao.applyIncomingMessageMeta(
        roomLocalId: room,
        lastMessageLocalId: 123,
        serverSeq: 5,
        serverCreatedAt: 1000,
        incrementUnread: true,
      );
      final r = await db.roomsDao.findByLocalId(room);
      expect(r!.lastServerSeq, 5);
      expect(r.lastMessageLocalId, 123);
      expect(r.unreadCount, 1);
    });

    test('markRead advances high-water-mark and clears unread', () async {
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
  });

  group('OutboxDao', () {
    test('dueOps returns FIFO and respects next_retry_at backoff', () async {
      const now = 1000;
      await db.outboxDao.enqueue(OutboxCompanion.insert(
        opType: OutboxOpType.sendMsg,
        clientUuid: 'a',
        roomId: 1,
        payloadJson: '{}',
        createdAt: 1,
      ));
      // Scheduled into the future -> not yet due.
      await db.outboxDao.enqueue(OutboxCompanion.insert(
        opType: OutboxOpType.sendMsg,
        clientUuid: 'b',
        roomId: 1,
        payloadJson: '{}',
        createdAt: 2,
        nextRetryAt: const Value(5000),
      ));
      await db.outboxDao.enqueue(OutboxCompanion.insert(
        opType: OutboxOpType.sendMsg,
        clientUuid: 'c',
        roomId: 1,
        payloadJson: '{}',
        createdAt: 3,
      ));

      final due = await db.outboxDao.dueOps(nowMs: now);
      expect(due.map((o) => o.clientUuid).toList(), ['a', 'c']);
    });

    test('recordFailure increments attempts and schedules retry', () async {
      final id = await db.outboxDao.enqueue(OutboxCompanion.insert(
        opType: OutboxOpType.sendMsg,
        clientUuid: 'a',
        roomId: 1,
        payloadJson: '{}',
        createdAt: 1,
      ));
      await db.outboxDao
          .recordFailure(localId: id, nextRetryAt: 9999, error: 'net');
      final row = await db.outboxDao.findByClientUuid('a');
      expect(row!.attempts, 1);
      expect(row.nextRetryAt, 9999);
      expect(row.lastError, 'net');
    });
  });

  group('SyncStateDao', () {
    test('setCursor upserts and hasEpochChanged detects reset', () async {
      await db.syncStateDao
          .setCursor(roomId: 1, lastKnownSeq: 10, epoch: 'e1', nowMs: 1);
      expect(await db.syncStateDao.hasEpochChanged(1, 'e1'), isFalse);
      expect(await db.syncStateDao.hasEpochChanged(1, 'e2'), isTrue);

      await db.syncStateDao
          .setCursor(roomId: 1, lastKnownSeq: 20, epoch: 'e2', nowMs: 2);
      final s = await db.syncStateDao.forRoom(1);
      expect(s!.lastKnownSeq, 20);
      expect(s.epoch, 'e2');
    });
  });

  group('reactive streams', () {
    test('watchRoomMessages re-emits on a post-subscription insert', () async {
      final room = await seedRoom();
      final emissions = <int>[];
      final sub = db.messagesDao
          .watchRoomMessages(room)
          .listen((rows) => emissions.add(rows.length));

      // Let the initial (empty) snapshot land.
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await db.messagesDao
          .insertPending(msg(clientUuid: 'r1', roomId: room));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await db.messagesDao.upsertFromServer(msg(
          clientUuid: 'r2',
          roomId: room,
          serverMessageId: 1,
          serverSeq: 1,
          state: MessageState.sent));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      await sub.cancel();
      // Initial empty + after pending + after confirmed.
      expect(emissions, [0, 1, 2]);
    });
  });

  group('insertPending dedup', () {
    test('double-send with same client_uuid is ignored (no duplicate row)',
        () async {
      final room = await seedRoom();
      final first = await db.messagesDao
          .insertPending(msg(clientUuid: 'dup', roomId: room, body: 'a'));
      // A retry path re-inserts the same optimistic message.
      await db.messagesDao
          .insertPending(msg(clientUuid: 'dup', roomId: room, body: 'b'));

      final all = await db.messagesDao.watchRoomMessages(room).first;
      expect(all, hasLength(1), reason: 'UNIQUE(client_uuid) blocks the retry');
      expect(all.single.localId, first);
      expect(all.single.body, 'a', reason: 'insertOrIgnore keeps the original');
    });
  });

  group('MediaUploadsDao', () {
    test('upsert + state transitions by client_uuid', () async {
      await db.mediaUploadsDao.upsert(MediaUploadsCompanion.insert(
        clientUuid: 'm1',
        localPath: '/tmp/a.jpg',
        uploadState: MediaUploadState.queued,
      ));
      await db.mediaUploadsDao
          .updateProgress(clientUuid: 'm1', bytesSent: 50, state: MediaUploadState.uploading);
      await db.mediaUploadsDao
          .markDone(clientUuid: 'm1', remoteUrl: 'https://x/a.jpg');

      final m = await db.mediaUploadsDao.findByClientUuid('m1');
      expect(m!.uploadState, MediaUploadState.done);
      expect(m.remoteUrl, 'https://x/a.jpg');
      expect(m.bytesSent, 50);
    });
  });
}
