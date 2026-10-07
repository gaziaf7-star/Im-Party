import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/chat_tables.dart';

part 'sync_state_dao.g.dart';

@DriftAccessor(tables: [SyncState])
class SyncStateDao extends DatabaseAccessor<AppDatabase>
    with _$SyncStateDaoMixin {
  SyncStateDao(super.db);

  Future<SyncStateData?> forRoom(int roomId) {
    return (select(syncState)..where((s) => s.roomId.equals(roomId)))
        .getSingleOrNull();
  }

  Future<void> upsert(SyncStateCompanion entry) {
    return into(syncState).insertOnConflictUpdate(entry);
  }

  /// Advance the recovery cursor for a room. If the channel [epoch] changed,
  /// the caller (sync engine, Phase 5) must trigger a full room resync.
  ///
  /// Monotonic: [lastKnownSeq] is only ever moved FORWARD. A caller that re-
  /// stamps the cursor from the current local max on a clean resubscribe (or a
  /// re-applied/out-of-order publication) must not be able to REGRESS a higher
  /// cursor already recorded — that would force redundant gap-fetches and is a
  /// silent footgun. The epoch, when supplied, is always written (it is the
  /// resync trigger and is unrelated to the cursor's direction).
  Future<void> setCursor({
    required int roomId,
    required int lastKnownSeq,
    String? epoch,
    required int nowMs,
  }) async {
    await transaction(() async {
      final current = await forRoom(roomId);
      final newSeq = (current != null && current.lastKnownSeq > lastKnownSeq)
          ? current.lastKnownSeq
          : lastKnownSeq;
      await into(syncState).insertOnConflictUpdate(SyncStateCompanion(
        roomId: Value(roomId),
        lastKnownSeq: Value(newSeq),
        epoch: epoch == null ? const Value.absent() : Value(epoch),
        lastSyncedAt: Value(nowMs),
      ));
    });
  }

  /// Returns true when the stored epoch differs from [incomingEpoch]
  /// (signals a Centrifugo history reset -> gap, needs full resync).
  Future<bool> hasEpochChanged(int roomId, String incomingEpoch) async {
    final current = await forRoom(roomId);
    if (current == null || current.epoch == null) return false;
    return current.epoch != incomingEpoch;
  }

  Future<int> remove(int roomId) {
    return (delete(syncState)..where((s) => s.roomId.equals(roomId))).go();
  }
}
