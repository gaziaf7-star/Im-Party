// Phase 5 — drift DB + list performance (additive schema v6).
//
// Covers ONLY the Phase-5 data-layer changes against an in-memory SQLite db:
//   * Denormalized last-message preview on `rooms` is written by
//     applyIncomingMessageMeta / applyOutgoingMessageMeta and refreshed by
//     refreshLastMessagePreview — and read back by watchRoomsWithLast WITHOUT a
//     join (the list stream no longer re-runs on every message write).
//   * The v6 indexes exist (sqlite_master) and EXPLAIN QUERY PLAN uses an index
//     for the conversation-list ordering + the peer lookup.
//   * onCreate (AppDatabase.forTesting at the current schemaVersion) creates
//     everything onUpgrade does — verified by upgrading a v5-shaped raw db to v6
//     and asserting the two databases converge (same columns, same indexes,
//     correct backfill).

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:general/src/core/database/app_database.dart';
import 'package:general/src/core/database/daos/rooms_dao.dart';
import 'package:general/src/core/database/tables/chat_tables.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> seedRoom({int? serverRoomId, int? peerUserId}) {
    return db.roomsDao.insertRoom(RoomsCompanion.insert(
      type: RoomType.dm,
      serverRoomId: Value(serverRoomId),
      peerUserId: Value(peerUserId),
    ));
  }

  Future<int> insertMsg({
    required String clientUuid,
    required int roomId,
    int? serverMessageId,
    int? serverSeq,
    int senderId = 7,
    MessageContentType type = MessageContentType.text,
    String? body = 'hello',
    MessageState state = MessageState.sent,
    String? serverStatus,
    MessageDeleteState deleteState = MessageDeleteState.none,
  }) {
    return db.messagesDao.upsertFromServer(MessagesCompanion.insert(
      clientUuid: clientUuid,
      roomId: roomId,
      kind: MessageKind.user,
      type: type,
      createdAtClient: 0,
      state: state,
      serverMessageId: Value(serverMessageId),
      serverSeq: Value(serverSeq),
      senderId: Value(senderId),
      body: Value(body),
      serverStatus: Value(serverStatus),
      deleteState: Value(deleteState),
    ));
  }

  group('denormalized last-message preview (#20)', () {
    test('applyIncomingMessageMeta writes the preview; list reads it w/o a join',
        () async {
      final room = await seedRoom(serverRoomId: 1);
      final localId = await insertMsg(
        clientUuid: 'm1',
        roomId: room,
        serverMessageId: 100,
        serverSeq: 5,
        body: 'ping',
        serverStatus: 'sent',
        senderId: 42,
      );

      await db.roomsDao.applyIncomingMessageMeta(
        roomLocalId: room,
        lastMessageLocalId: localId,
        serverSeq: 5,
        serverCreatedAt: 1000,
        incrementUnread: true,
      );

      final rows = await db.roomsDao.watchRoomsWithLast().first;
      expect(rows, hasLength(1));
      final preview = rows.single.preview;
      expect(rows.single.last, isNull, reason: 'live path carries no join row');
      expect(preview.text, 'ping');
      expect(preview.type, MessageContentType.text);
      expect(preview.senderId, 42);
      expect(preview.serverMessageId, 100);
      expect(preview.status, 'sent');
      expect(preview.state, MessageState.sent);
      expect(preview.deleteState, MessageDeleteState.none);
    });

    test('media body denormalizes type so the list shows the right glyph',
        () async {
      final room = await seedRoom(serverRoomId: 2);
      final localId = await insertMsg(
        clientUuid: 'v1',
        roomId: room,
        serverMessageId: 200,
        serverSeq: 3,
        type: MessageContentType.image,
        body: null,
      );
      await db.roomsDao.applyIncomingMessageMeta(
        roomLocalId: room,
        lastMessageLocalId: localId,
        serverSeq: 3,
        serverCreatedAt: 10,
      );

      final r = await db.roomsDao.findByLocalId(room);
      expect(r!.lastPreviewType, MessageContentType.image.index);
      expect(r.lastPreviewText, isNull);
    });

    test('applyOutgoingMessageMeta denormalizes a pending own message',
        () async {
      final room = await seedRoom(serverRoomId: 3);
      final localId = await db.messagesDao.insertPending(
        MessagesCompanion.insert(
          clientUuid: 'p1',
          roomId: room,
          kind: MessageKind.user,
          type: MessageContentType.text,
          createdAtClient: 50,
          state: MessageState.pending,
          senderId: const Value(7),
          body: const Value('draft sent'),
        ),
      );
      await db.roomsDao.applyOutgoingMessageMeta(
        roomLocalId: room,
        lastMessageLocalId: localId,
        createdAtClient: 50,
      );

      final preview = (await db.roomsDao.watchRoomsWithLast().first).single.preview;
      expect(preview.text, 'draft sent');
      expect(preview.state, MessageState.pending);
      expect(preview.senderId, 7);
    });

    test('non-advancing re-delivery does NOT rewind the denormalized preview',
        () async {
      final room = await seedRoom(serverRoomId: 4);
      final older = await insertMsg(
          clientUuid: 'o1', roomId: room, serverMessageId: 1, serverSeq: 1, body: 'old');
      final newer = await insertMsg(
          clientUuid: 'n1', roomId: room, serverMessageId: 2, serverSeq: 2, body: 'new');

      await db.roomsDao.applyIncomingMessageMeta(
        roomLocalId: room,
        lastMessageLocalId: newer,
        serverSeq: 2,
        serverCreatedAt: 20,
      );
      // Re-deliver the OLDER message (seq does not advance): preview must stay.
      await db.roomsDao.applyIncomingMessageMeta(
        roomLocalId: room,
        lastMessageLocalId: older,
        serverSeq: 1,
        serverCreatedAt: 10,
      );

      final preview = (await db.roomsDao.watchRoomsWithLast().first).single.preview;
      expect(preview.text, 'new', reason: 'older re-delivery must not rewind preview');
    });

    test('refreshLastMessagePreview re-stamps the tick without reordering',
        () async {
      final room = await seedRoom(serverRoomId: 5);
      final localId = await insertMsg(
        clientUuid: 's1',
        roomId: room,
        serverMessageId: 300,
        serverSeq: 9,
        body: 'mine',
        serverStatus: 'sent',
        state: MessageState.sent,
      );
      await db.roomsDao.applyIncomingMessageMeta(
        roomLocalId: room,
        lastMessageLocalId: localId,
        serverSeq: 9,
        serverCreatedAt: 90,
      );
      final before = await db.roomsDao.findByLocalId(room);
      expect(before!.lastPreviewStatus, 'sent');

      // Peer reads it: message flips to seen. The list tick must follow.
      await db.messagesDao
          .setServerStatus('s1', 'seen');
      await db.messagesDao.updateState('s1', MessageState.read);
      await db.roomsDao.refreshLastMessagePreview(room);

      final after = await db.roomsDao.findByLocalId(room);
      expect(after!.lastPreviewStatus, 'seen');
      expect(after.lastPreviewState, MessageState.read.index);
      expect(after.updatedAt, before.updatedAt,
          reason: 'refresh must not touch ordering');
    });

    test('list stream does NOT re-emit on a non-last-message write', () async {
      final room = await seedRoom(serverRoomId: 6);
      final last = await insertMsg(
          clientUuid: 'L', roomId: room, serverMessageId: 10, serverSeq: 10, body: 'last');
      await db.roomsDao.applyIncomingMessageMeta(
        roomLocalId: room,
        lastMessageLocalId: last,
        serverSeq: 10,
        serverCreatedAt: 100,
      );

      final emissions = <int>[];
      final sub =
          db.roomsDao.watchRoomsWithLast().listen((rows) => emissions.add(rows.length));
      await Future<void>.delayed(const Duration(milliseconds: 30));

      // Mutate a DIFFERENT (non-last) message's reactions. With the old join the
      // list stream re-fired on every message write; watching `rooms` alone it
      // must NOT re-emit.
      await insertMsg(
          clientUuid: 'X', roomId: room, serverMessageId: 9, serverSeq: 9, body: 'older');
      await db.messagesDao.setReactsByServerId(9, '[]');
      await Future<void>.delayed(const Duration(milliseconds: 30));

      await sub.cancel();
      expect(emissions, [1], reason: 'only the initial snapshot — no per-message re-run');
    });
  });

  group('v6 indexes (#58/#59/#60/#22)', () {
    Future<Set<String>> indexNames() async {
      final rows = await db
          .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
          .get();
      return rows.map((r) => r.read<String>('name')).toSet();
    }

    test('onCreate created every v6 index', () async {
      final names = await indexNames();
      expect(names, containsAll(<String>[
        'idx_messages_room_seq',
        'idx_messages_room_created',
        'idx_rooms_archived_updated',
        'idx_rooms_peer',
        'idx_outbox_room_created',
        'idx_outbox_client_uuid',
        'idx_messages_body',
      ]));
    });

    test('conversation-list ordering uses idx_rooms_archived_updated', () async {
      final plan = await db
          .customSelect(
              'EXPLAIN QUERY PLAN SELECT * FROM rooms '
              'WHERE is_archived = 0 ORDER BY updated_at DESC')
          .get();
      final detail = plan.map((r) => r.read<String>('detail')).join(' | ');
      expect(detail, contains('idx_rooms_archived_updated'));
    });

    test('peer lookup uses idx_rooms_peer', () async {
      final plan = await db
          .customSelect(
              'EXPLAIN QUERY PLAN SELECT * FROM rooms WHERE peer_user_id = 5')
          .get();
      final detail = plan.map((r) => r.read<String>('detail')).join(' | ');
      expect(detail, contains('idx_rooms_peer'));
    });

    test('outbox due-ops scan uses idx_outbox_room_created', () async {
      final plan = await db
          .customSelect(
              'EXPLAIN QUERY PLAN SELECT * FROM outbox '
              'WHERE room_id = 1 ORDER BY created_at, local_id')
          .get();
      final detail = plan.map((r) => r.read<String>('detail')).join(' | ');
      expect(detail, contains('idx_outbox_room_created'));
    });
  });

  group('schema v5 -> v6 upgrade (onCreate == onUpgrade)', () {
    test('upgrade adds the preview columns + every index and backfills',
        () async {
      // Build a v5-shaped database by hand (the columns/indexes that existed at
      // v5), set user_version = 5, then open it through AppDatabase so the real
      // onUpgrade(5 -> 6) migration runs. Then assert it converged with a fresh
      // onCreate database.
      final raw = sqlite3.openInMemory();
      raw.execute('PRAGMA user_version = 5');
      // Minimal v5 `rooms` (no preview columns) + `messages` + `outbox`.
      raw.execute('''
        CREATE TABLE rooms (
          local_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          server_room_id INTEGER UNIQUE,
          type INTEGER NOT NULL,
          title TEXT,
          avatar_url TEXT,
          peer_user_id INTEGER,
          group_id INTEGER,
          member_count INTEGER NOT NULL DEFAULT 0,
          last_message_local_id INTEGER,
          last_server_seq INTEGER NOT NULL DEFAULT 0,
          my_last_read_seq INTEGER NOT NULL DEFAULT 0,
          unread_count INTEGER NOT NULL DEFAULT 0,
          muted_until INTEGER,
          draft_text TEXT,
          is_archived INTEGER NOT NULL DEFAULT 0,
          my_role TEXT,
          updated_at INTEGER
        )
      ''');
      raw.execute('''
        CREATE TABLE messages (
          local_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          client_uuid TEXT NOT NULL UNIQUE,
          server_message_id INTEGER UNIQUE,
          room_id INTEGER NOT NULL,
          server_seq INTEGER,
          sender_id INTEGER,
          kind INTEGER NOT NULL,
          system_event TEXT,
          type INTEGER NOT NULL,
          body TEXT,
          reply_to_client_uuid TEXT,
          created_at_client INTEGER NOT NULL,
          server_created_at INTEGER,
          state INTEGER NOT NULL,
          delete_state INTEGER NOT NULL DEFAULT 0,
          server_status TEXT,
          reacts_json TEXT,
          attachment_json TEXT,
          reply_preview_json TEXT
        )
      ''');
      raw.execute('''
        CREATE TABLE outbox (
          local_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          op_type INTEGER NOT NULL,
          client_uuid TEXT NOT NULL,
          room_id INTEGER NOT NULL,
          payload_json TEXT NOT NULL,
          media_local_ref TEXT,
          attempts INTEGER NOT NULL DEFAULT 0,
          next_retry_at INTEGER,
          last_error TEXT,
          created_at INTEGER NOT NULL
        )
      ''');
      // Seed a room with an existing last message so the v6 backfill has work.
      raw.execute(
          "INSERT INTO messages (local_id, client_uuid, server_message_id, "
          "room_id, server_seq, sender_id, kind, type, body, created_at_client, "
          "state, delete_state, server_status) VALUES "
          "(1, 'u1', 500, 1, 4, 9, 0, 0, 'restored', 0, 1, 0, 'sent')");
      raw.execute(
          "INSERT INTO rooms (local_id, server_room_id, type, "
          "last_message_local_id, last_server_seq, updated_at) VALUES "
          "(1, 1, 0, 1, 4, 1234)");

      final upgraded = AppDatabase.forTesting(NativeDatabase.opened(raw));
      addTearDown(() async => upgraded.close());

      // Opening triggers the migration; force it via a query.
      final names = (await upgraded
              .customSelect(
                  "SELECT name FROM sqlite_master WHERE type = 'index'")
              .get())
          .map((r) => r.read<String>('name'))
          .toSet();
      expect(names, containsAll(<String>[
        'idx_messages_room_seq',
        'idx_messages_room_created',
        'idx_rooms_archived_updated',
        'idx_rooms_peer',
        'idx_outbox_room_created',
        'idx_outbox_client_uuid',
        'idx_messages_body',
      ]), reason: 'onUpgrade must add every index onCreate adds');

      // Preview columns exist and were backfilled from the existing last message.
      final room = await upgraded.roomsDao.findByLocalId(1);
      expect(room, isNotNull);
      expect(room!.lastPreviewText, 'restored');
      expect(room.lastPreviewServerMessageId, 500);
      expect(room.lastPreviewStatus, 'sent');
      expect(room.lastPreviewState, MessageState.sent.index);
      expect(room.lastPreviewType, MessageContentType.text.index);
      expect(room.lastPreviewDeleteState, MessageDeleteState.none.index);
      expect(room.updatedAt, 1234, reason: 'backfill must not reorder');

      // The fresh onCreate db and the upgraded db expose the SAME index set.
      final freshNames = (await db
              .customSelect(
                  "SELECT name FROM sqlite_master WHERE type = 'index'")
              .get())
          .map((r) => r.read<String>('name'))
          .toSet();
      // Drift's autoindexes for UNIQUE constraints are named sqlite_autoindex_*;
      // compare only the explicitly-created idx_* set so the assertion is stable.
      Set<String> idxOnly(Set<String> s) =>
          s.where((n) => n.startsWith('idx_')).toSet();
      expect(idxOnly(names), idxOnly(freshNames),
          reason: 'onCreate and onUpgrade converge on the same explicit indexes');
    });
  });
}
