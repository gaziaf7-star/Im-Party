import 'dart:io';

import 'package:meta/meta.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'tables/chat_tables.dart';
import 'daos/rooms_dao.dart';
import 'daos/messages_dao.dart';
import 'daos/outbox_dao.dart';
import 'daos/media_uploads_dao.dart';
import 'daos/sync_state_dao.dart';

part 'app_database.g.dart';

/// Local SQLite source of truth for the chat/realtime layer (Phase 4).
///
/// Indexes (section 7.1):
/// - messages(room_id, server_seq DESC)  -> keyset pagination + ordering
/// - messages(room_id, created_at_client DESC) -> pending ordering fallback
/// - messages(client_uuid) UNIQUE -> dedup (declared on the table)
@DriftDatabase(
  tables: [
    Rooms,
    Messages,
    ConversationMembers,
    Outbox,
    MediaUploads,
    SyncState,
  ],
  daos: [
    RoomsDao,
    MessagesDao,
    OutboxDao,
    MediaUploadsDao,
    SyncStateDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Test/override constructor (in-memory or custom executor).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _createIndexes();
        },
        onUpgrade: (m, from, to) async {
          // Some additive columns (e.g. `delete_state`) were declared on the
          // table BEFORE they got a dedicated upgrade step, so fresh installs of
          // those builds created the column via onCreate while their stored
          // schemaVersion stayed behind. On a later upgrade the matching
          // `addColumn` then ran `ALTER TABLE ... ADD COLUMN <existing>` and the
          // app crashed at startup with "duplicate column name". Guarding every
          // addColumn with an existence check makes each step idempotent and
          // immune to that ordering mismatch (now and for any future column).
          // v2: feature-parity columns on `messages` (reactions, attachments,
          // reply preview, raw server status). Pre-release DB, additive only.
          if (from < 2) {
            await _addColumnIfMissing(m, messages, messages.serverStatus);
            await _addColumnIfMissing(m, messages, messages.reactsJson);
            await _addColumnIfMissing(m, messages, messages.attachmentJson);
            await _addColumnIfMissing(m, messages, messages.replyPreviewJson);
          }
          // v3: 1:1 peer identity + group id on `rooms` so the conversation list
          // (now sourced from drift) can open a DM or a group without a lookup.
          if (from < 3) {
            await _addColumnIfMissing(m, rooms, rooms.peerUserId);
            await _addColumnIfMissing(m, rooms, rooms.groupId);
          }
          // v4: denormalized group member count for the list row.
          if (from < 4) {
            await _addColumnIfMissing(m, rooms, rooms.memberCount);
          }
          // v5: per-message soft-delete marker. The column was declared on the
          // table (NOT NULL, default `none`) but never had an upgrade step, so
          // installs created at v2/v3/v4 lacked `delete_state` and every message
          // read/write threw "no such column: delete_state" — silently breaking
          // local delete (incl. delete-for-everyone). Additive, safe default.
          if (from < 5) {
            await _addColumnIfMissing(m, messages, messages.deleteState);
          }
          // v6: list/DB performance. Additive, safe for production DBs with
          // millions of rows.
          //  (a) Denormalize the last-message preview onto `rooms` so the
          //      conversation-list stream no longer LEFT JOINs `messages` (which
          //      forced a full re-run on every message write app-wide).
          //  (b) Add supporting indexes for list ordering, peer lookup and the
          //      outbox due-ops scan. All CREATE INDEX use IF NOT EXISTS.
          // Mirrored in onCreate via _createIndexes() so fresh installs match.
          if (from < 6) {
            await _addColumnIfMissing(m, rooms, rooms.lastPreviewText);
            await _addColumnIfMissing(m, rooms, rooms.lastPreviewType);
            await _addColumnIfMissing(m, rooms, rooms.lastPreviewSenderId);
            await _addColumnIfMissing(m, rooms, rooms.lastPreviewServerMessageId);
            await _addColumnIfMissing(m, rooms, rooms.lastPreviewStatus);
            await _addColumnIfMissing(m, rooms, rooms.lastPreviewState);
            await _addColumnIfMissing(m, rooms, rooms.lastPreviewDeleteState);
            // Backfill the denormalized preview from each room's existing
            // last-message row in a single set-based UPDATE (no per-row Dart
            // loop), so the list shows correct previews immediately after the
            // upgrade instead of only after the next message in each room.
            await _backfillLastPreview();
          }
          // v7: B1 data-recovery. Earlier builds deleted orphan DM rooms
          // (serverRoomId null/0) when the real room materialized; the FK
          // cascade on messages.room_id then PERMANENTLY destroyed every message
          // those orphans still held. This step recovers any orphan data still
          // present on existing installs: for each orphan DM room whose peer has a
          // real room (serverRoomId > 0), re-parent its messages onto the real
          // room, then delete the now-empty orphan. Set-based, no Dart loop.
          if (from < 7) {
            await _recoverOrphanDmMessages();
          }
          // Add every index (v2..v6) on upgrade too. The CREATE statements are
          // idempotent (IF NOT EXISTS), so this converges existing installs that
          // were created before _createIndexes was added to onUpgrade — without
          // it, new indexes shipped dead to the majority (already-installed)
          // user base.
          await _createIndexes();
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// Idempotent [Migrator.addColumn]: adds [column] to [table] only when it is
  /// not already present. A column declared on the table before it received its
  /// own upgrade step exists on some installs whose stored schemaVersion is
  /// still behind; a plain addColumn would then crash with "duplicate column
  /// name". The table name comes from drift metadata (not user input).
  Future<void> _addColumnIfMissing(
      Migrator m, TableInfo table, GeneratedColumn column) async {
    final info =
        await customSelect('PRAGMA table_info(${table.actualTableName})').get();
    final exists = info.any((row) => row.data['name'] == column.name);
    if (!exists) {
      await m.addColumn(table, column);
    }
  }

  /// Clears ALL locally cached chat data in one transaction. Invoked on every
  /// identity change (login / logout / switch / delete account) via
  /// [DependencyInjectionService.reset]. The drift file is a single shared
  /// on-disk database with no per-user namespacing, so without this wipe a newly
  /// signed-in account reads the previous account's cached rooms/messages
  /// (cross-account data leak). Child rows are deleted before `rooms` so the
  /// delete is correct regardless of the FK cascade.
  Future<void> wipeChatData() async {
    await transaction(() async {
      await delete(messages).go();
      await delete(conversationMembers).go();
      await delete(outbox).go();
      await delete(mediaUploads).go();
      await delete(syncState).go();
      await delete(rooms).go();
    });
  }

  Future<void> _createIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_messages_room_seq '
      'ON messages (room_id, server_seq DESC)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_messages_room_created '
      'ON messages (room_id, created_at_client DESC)',
    );
    // (v6) Conversation-list ordering: every list query is
    // `WHERE is_archived = 0 ORDER BY updated_at DESC`. The composite index
    // serves both the filter and the ordering without a sort/scan.
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_rooms_archived_updated '
      'ON rooms (is_archived, updated_at DESC)',
    );
    // (v6) 1:1 peer lookup (deleteRoomByPeer + peer-keyed reconciliation).
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_rooms_peer '
      'ON rooms (peer_user_id)',
    );
    // (v6) Outbox due-ops FIFO scan (dueOps / dueOpsForRoom order by created_at).
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_outbox_room_created '
      'ON outbox (room_id, created_at, local_id)',
    );
    // (v6) Outbox idempotency lookups by client_uuid (findByClientUuid /
    // removeByClientUuid). Non-unique: a uuid is reused across react/delete ops.
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_outbox_client_uuid '
      'ON outbox (client_uuid)',
    );
    // (v6) Offline message search: a non-leading-wildcard prefix LIKE on body
    // can use this index; the leading-wildcard contains-search still scans but
    // is now bounded by the room/seq index for ordering.
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_messages_body '
      'ON messages (body)',
    );
  }

  /// Set-based backfill of the denormalized last-message preview columns on
  /// `rooms` from each room's existing `last_message_local_id` row. Run once in
  /// the v6 upgrade. Safe on large DBs: a single correlated UPDATE, no Dart loop.
  Future<void> _backfillLastPreview() async {
    await customStatement('''
      UPDATE rooms SET
        last_preview_text = (
          SELECT m.body FROM messages m
          WHERE m.local_id = rooms.last_message_local_id),
        last_preview_type = (
          SELECT m.type FROM messages m
          WHERE m.local_id = rooms.last_message_local_id),
        last_preview_sender_id = (
          SELECT m.sender_id FROM messages m
          WHERE m.local_id = rooms.last_message_local_id),
        last_preview_server_message_id = (
          SELECT m.server_message_id FROM messages m
          WHERE m.local_id = rooms.last_message_local_id),
        last_preview_status = (
          SELECT m.server_status FROM messages m
          WHERE m.local_id = rooms.last_message_local_id),
        last_preview_state = (
          SELECT m.state FROM messages m
          WHERE m.local_id = rooms.last_message_local_id),
        last_preview_delete_state = (
          SELECT m.delete_state FROM messages m
          WHERE m.local_id = rooms.last_message_local_id)
      WHERE rooms.last_message_local_id IS NOT NULL
    ''');
  }

  /// One-time B1 recovery (v7 upgrade). Re-parents messages stranded on orphan
  /// DM rooms (server_room_id null/0) onto the peer's real room (the highest
  /// server_room_id for that peer), then deletes the emptied orphans.
  ///
  /// Runs in a transaction so the migrate-then-delete is atomic. The UPDATE uses
  /// `OR IGNORE` because messages.client_uuid is UNIQUE — a message already
  /// present in the real room (same uuid via another path) is skipped instead of
  /// aborting; its stale orphan copy is then removed with the orphan room (the
  /// FK cascade is now safe because the orphan holds no unique survivors).
  Future<void> _recoverOrphanDmMessages() async {
    await transaction(() async {
      // Move messages: orphan DM room -> peer's surviving real room.
      // `real` = the highest server_room_id room for the same peer; `orphan` =
      // a DM row with the same peer but no real server_room_id.
      await customStatement('''
        UPDATE OR IGNORE messages
        SET room_id = (
          SELECT real.local_id
          FROM rooms orphan
          JOIN rooms real
            ON real.peer_user_id = orphan.peer_user_id
           AND real.type = orphan.type
           AND COALESCE(real.server_room_id, 0) > 0
          WHERE orphan.local_id = messages.room_id
          ORDER BY real.server_room_id DESC
          LIMIT 1
        )
        WHERE messages.room_id IN (
          SELECT orphan.local_id
          FROM rooms orphan
          WHERE orphan.type = ${RoomType.dm.index}
            AND orphan.peer_user_id IS NOT NULL
            AND COALESCE(orphan.server_room_id, 0) <= 0
            AND EXISTS (
              SELECT 1 FROM rooms real
              WHERE real.peer_user_id = orphan.peer_user_id
                AND real.type = orphan.type
                AND COALESCE(real.server_room_id, 0) > 0
            )
        )
      ''');
      // Delete the now-recoverable orphan DM rooms (messages already migrated;
      // any remaining cascade-deleted rows were duplicates skipped by OR IGNORE).
      await customStatement('''
        DELETE FROM rooms
        WHERE type = ${RoomType.dm.index}
          AND peer_user_id IS NOT NULL
          AND COALESCE(server_room_id, 0) <= 0
          AND EXISTS (
            SELECT 1 FROM rooms real
            WHERE real.peer_user_id = rooms.peer_user_id
              AND real.type = rooms.type
              AND COALESCE(real.server_room_id, 0) > 0
          )
      ''');
    });
  }

  /// Test-only hook to drive the v7 B1 orphan-recovery step directly (the
  /// migration machinery is otherwise only reachable via a real version bump).
  @visibleForTesting
  Future<void> runOrphanRecoveryForTest() => _recoverOrphanDmMessages();

  static QueryExecutor _openConnection() {
    // Runs the database on a background isolate so queries never block the UI.
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'jo_live_chat.sqlite'));

      // Work around an old Android SQLite bug (locking on temp dir) + ensure
      // the bundled, up-to-date sqlite3 from sqlite3_flutter_libs is used.
      if (Platform.isAndroid) {
        await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
        final cachebase = (await getTemporaryDirectory()).path;
        sqlite3.tempDirectory = cachebase;
      }

      return NativeDatabase.createInBackground(
        file,
        setup: (db) {
          // Wait (instead of failing instantly with SQLITE_BUSY / "database is
          // locked") when another writer holds the lock. The chat layer has
          // several concurrent writers (outbox, sync engine, media uploads,
          // realtime push handlers) on this single connection. 5s proved too
          // short on slow devices during a full rooms-list sync (Crashlytics
          // SqliteException(5) bursts), hence 30s — waiting beats crashing,
          // and the DB isolate never blocks the UI thread.
          db.execute('PRAGMA busy_timeout = 30000');
          // WAL lets readers proceed while a writer commits, sharply reducing
          // lock contention on COMMIT.
          db.execute('PRAGMA journal_mode = WAL');
          db.execute('PRAGMA foreign_keys = ON');
        },
      );
    });
  }
}
