import 'dart:math';

/// Exponential backoff with full jitter for outbox retries (Plan section 7.2).
///
/// Pure + deterministic given an injected [Random], so the schedule is unit
/// testable. The base/cap match a chat-grade retry policy: quick first retries,
/// capped so a permanently-failing op does not back off forever.
class OutboxBackoff {
  const OutboxBackoff({
    this.base = const Duration(seconds: 2),
    this.cap = const Duration(minutes: 5),
  });

  /// First-retry delay before jitter.
  final Duration base;

  /// Upper bound on any single delay.
  final Duration cap;

  /// Delay before the next attempt given how many attempts have already failed.
  ///
  /// [attempts] is the count of prior failures (0 -> first retry). Uses
  /// exponential growth `base * 2^attempts` clamped to [cap], then applies full
  /// jitter in `[0, window]` via [random] to avoid thundering-herd reconnects.
  Duration nextDelay(int attempts, Random random) {
    final safeAttempts = attempts < 0 ? 0 : attempts;
    // Guard the shift so very large attempt counts don't overflow.
    final shift = safeAttempts > 20 ? 20 : safeAttempts;
    final rawMs = base.inMilliseconds * (1 << shift);
    final cappedMs = rawMs > cap.inMilliseconds ? cap.inMilliseconds : rawMs;
    final jitteredMs =
        cappedMs <= 0 ? 0 : random.nextInt(cappedMs + 1); // full jitter
    return Duration(milliseconds: jitteredMs);
  }

  /// Absolute next_retry_at timestamp (ms epoch) from [nowMs].
  int nextRetryAt(int attempts, int nowMs, Random random) =>
      nowMs + nextDelay(attempts, random).inMilliseconds;
}
