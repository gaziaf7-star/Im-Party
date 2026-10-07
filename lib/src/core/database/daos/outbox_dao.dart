import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/chat_tables.dart';

part 'outbox_dao.g.dart';

@DriftAccessor(tables: [Outbox])
class OutboxDao extends DatabaseAccessor<AppDatabase> with _$OutboxDaoMixin {
  OutboxDao(super.db);

  Future<int> enqueue(OutboxCompanion entry) => into(outbox).insert(entry);

  /// FIFO batch of operations due now (next_retry_at is null or in the past),
  /// ordered by creation. The worker drains this per-room respecting order.
  Future<List<OutboxData>> dueOps({
    required int nowMs,
    int limit = 50,
  }) {
    return (select(outbox)
          ..where((o) =>
              o.nextRetryAt.isNull() |
              o.nextRetryAt.isSmallerOrEqualValue(nowMs))
          ..orderBy([
            (o) => OrderingTerm(expression: o.createdAt),
            (o) => OrderingTerm(expression: o.localId),
          ])
          ..limit(limit))
        .get();
  }

  /// Due operations for a single room, in FIFO order — used by the per-room
  /// serial worker so a stuck message never reorders later ones.
  Future<List<OutboxData>> dueOpsForRoom({
    required int roomId,
    required int nowMs,
    int limit = 50,
  }) {
    return (select(outbox)
          ..where((o) =>
              o.roomId.equals(roomId) &
              (o.nextRetryAt.isNull() |
                  o.nextRetryAt.isSmallerOrEqualValue(nowMs)))
          ..orderBy([
            (o) => OrderingTerm(expression: o.createdAt),
            (o) => OrderingTerm(expression: o.localId),
          ])
          ..limit(limit))
        .get();
  }

  Stream<List<OutboxData>> watchPending() {
    return (select(outbox)
          ..orderBy([(o) => OrderingTerm(expression: o.createdAt)]))
        .watch();
  }

  Future<OutboxData?> findByClientUuid(String clientUuid) {
    return (select(outbox)..where((o) => o.clientUuid.equals(clientUuid)))
        .getSingleOrNull();
  }

  /// Record a failed attempt: bump attempts, schedule next retry, store error.
  Future<void> recordFailure({
    required int localId,
    required int nextRetryAt,
    required String error,
  }) async {
    await transaction(() async {
      final row = await (select(outbox)
            ..where((o) => o.localId.equals(localId)))
          .getSingleOrNull();
      if (row == null) return;
      await (update(outbox)..where((o) => o.localId.equals(localId))).write(
        OutboxCompanion(
          attempts: Value(row.attempts + 1),
          nextRetryAt: Value(nextRetryAt),
          lastError: Value(error),
        ),
      );
    });
  }

  /// Remove an operation after it succeeds (server confirmed, idempotent).
  Future<int> remove(int localId) {
    return (delete(outbox)..where((o) => o.localId.equals(localId))).go();
  }

  Future<int> removeByClientUuid(String clientUuid) {
    return (delete(outbox)..where((o) => o.clientUuid.equals(clientUuid))).go();
  }
}
