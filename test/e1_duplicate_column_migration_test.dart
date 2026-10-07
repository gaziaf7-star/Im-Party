// E1 — drift migration crash: "duplicate column name: delete_state".
//
// Root cause: `delete_state` was declared on the `messages` table before it had
// its own upgrade step, so fresh installs of those builds created the column via
// onCreate while their stored schemaVersion stayed at 4. On a later upgrade the
// `if (from < 5) addColumn(deleteState)` step then ran
// `ALTER TABLE messages ADD COLUMN delete_state` against an EXISTING column and
// the app crashed at startup — ~3.6k events on 1.0.24/1.0.25 (top crash).
//
// The fix makes every addColumn idempotent (_addColumnIfMissing). This test
// reproduces the broken state (schemaVersion=4 on a DB that already has the
// column) and asserts the upgrade to the current schema completes without
// throwing. It fails on the pre-fix code and passes after it.

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:general/src/core/database/app_database.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late File dbFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('e1_mig_test');
    dbFile = File(p.join(tempDir.path, 'e1_chat.sqlite'));
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test('upgrade from v4 with delete_state already present does not crash',
      () async {
    // 1) Create the DB at the current schema (onCreate builds every table,
    //    including the `delete_state` column on `messages`).
    var db = AppDatabase.forTesting(NativeDatabase(dbFile));
    await db.customStatement('SELECT 1'); // force open -> onCreate runs
    // Sanity: the column exists after a fresh create.
    var cols = await db.customSelect('PRAGMA table_info(messages)').get();
    expect(cols.any((r) => r.data['name'] == 'delete_state'), isTrue);

    // 2) Rewind the stored schema version to 4 — the exact broken state of
    //    installs that created the column via onCreate but never advanced past 4.
    await db.customStatement('PRAGMA user_version = 4');
    await db.close();

    // 3) Reopen at the current schema. drift sees from=4 and runs onUpgrade,
    //    which hits the `if (from < 5) addColumn(deleteState)` step against the
    //    already-present column. Pre-fix this throws "duplicate column name".
    db = AppDatabase.forTesting(NativeDatabase(dbFile));
    // Any query forces beforeOpen + the migration to run.
    cols = await db.customSelect('PRAGMA table_info(messages)').get();

    // No crash, and the column is still there exactly once.
    final deleteStateCols =
        cols.where((r) => r.data['name'] == 'delete_state').length;
    expect(deleteStateCols, 1);

    // The v6 columns that were genuinely missing-by-version are also reconciled.
    final roomCols = await db.customSelect('PRAGMA table_info(rooms)').get();
    expect(
      roomCols.any((r) => r.data['name'] == 'last_preview_text'),
      isTrue,
    );

    await db.close();
  });
}
