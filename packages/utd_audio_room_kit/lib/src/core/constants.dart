/// UTD Audio Room Kit constants.
class UTDConstants {
  UTDConstants._();

  /// Message batch interval in milliseconds (60fps).
  static const int messageBatchIntervalMs = 16;

  /// Default room options.
  static const bool defaultAdaptiveStream = true;
  static const bool defaultDynacast = true;

  /// Connection retry settings. The retry delay is short: a failed attempt
  /// already consumed seconds, and the previous session is fully torn down
  /// (awaited) before the delay starts, so a longer pause adds pure wait.
  static const int maxConnectRetries = 2;
  static const Duration retryDelay = Duration(milliseconds: 200);

  /// Per-phase RTC signal timeout passed to the SDK. Shorter than the SDK's
  /// 10s default so a dead network fails fast INSIDE the SDK — with a precise
  /// reason and a clean internal teardown — instead of the outer
  /// [connectTimeout] aborting a still-live handshake mid-flight and leaving
  /// its teardown to the retry loop.
  static const Duration rtcSignalTimeout = Duration(seconds: 7);

  /// Timeouts that bound blocking WebRTC/SDK operations so a flaky network can
  /// never hang the engine indefinitely (the root cause of the
  /// createTransceiverRTCRtpSender / sendSyncState / waitFor / publishData
  /// timeout crashes). A fired timeout surfaces as a normal exception that the
  /// caller's catch/retry handles, instead of an internal SDK deadlock.
  ///
  /// [connectTimeout] is a DEADLOCK BACKSTOP, not the failure pacer — the
  /// per-phase SDK timeouts ([rtcSignalTimeout] for signal, 10s media ops)
  /// fail fast in practice. It must exceed the worst-case sum of the SDK's
  /// internal phases (signal + join + peer-connection ≈ up to ~21s), or a
  /// slow-but-progressing join gets aborted mid-ICE at 15s and restarted from
  /// zero — turning one slow join into a guaranteed multi-attempt stall.
  static const Duration connectTimeout = Duration(seconds: 25);
  static const Duration mediaOpTimeout = Duration(seconds: 10);
  static const Duration publishDataTimeout = Duration(seconds: 8);

  /// Data channel reliability.
  static const bool reliableDataChannel = true;
}
