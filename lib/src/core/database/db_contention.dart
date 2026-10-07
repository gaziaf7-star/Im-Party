// DriftRemoteException is the wrapper every background-isolate DB error
// arrives in — unwrapping it is the whole point of this helper.
// ignore: experimental_member_use
import 'package:drift/remote.dart';
import 'package:sqlite3/common.dart';

/// Reports a survivable DB error (e.g. SQLITE_BUSY) to observability without
/// crashing. Injected so pure-Dart units (SyncEngine / OutboxWorker) stay free
/// of Firebase imports and remain unit-testable with an in-memory database.
typedef RecoverableDbErrorReporter = void Function(
    Object error, StackTrace stack, String context);

/// True when [error] is sqlite write contention — SQLITE_BUSY (5) /
/// SQLITE_LOCKED (6), i.e. another writer held the lock past `busy_timeout`.
/// Transient by definition: the same operation succeeds on the next sync/drain
/// tick, so callers must record it as non-fatal and retry instead of crashing.
bool isDbLockedError(Object error) {
  Object e = error;
  // Drift runs the database on a background isolate; errors cross back wrapped.
  if (e is DriftRemoteException) e = e.remoteCause;
  if (e is SqliteException) {
    final code = e.resultCode & 0xff;
    return code == 5 || code == 6;
  }
  final text = e.toString();
  return text.contains('database is locked') ||
      text.contains('database table is locked');
}
