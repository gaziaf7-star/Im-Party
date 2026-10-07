import 'package:flutter/foundation.dart';

/// Debug-only room-join timeline. Emits `[JOIN_TT]` stage stamps to logcat
/// (tap → navigate → enterRoomReq/Resp; the UTD kits stamp tokenReq/Resp,
/// connected and firstAudio with the same tag) so tap-to-audio latency is
/// measurable end to end. Compiled out of release builds.
class JoinTimeline {
  JoinTimeline._();

  static const bool enabled = kDebugMode;

  static Stopwatch? _watch;
  static String _room = '';

  /// Stamp the tap (call at the very start of room navigation).
  static void start(String room) {
    if (!enabled) return;
    _room = room;
    _watch = Stopwatch()..start();
    debugPrint('[JOIN_TT] tap room=$room');
  }

  /// Stamp a stage relative to the last [start].
  static void mark(String stage) {
    if (!enabled) return;
    final watch = _watch;
    if (watch == null) return;
    debugPrint(
        '[JOIN_TT] $stage room=$_room +${watch.elapsedMilliseconds}ms');
  }
}
