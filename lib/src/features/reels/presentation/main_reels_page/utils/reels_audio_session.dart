import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';

/// Owns the platform audio session for the reels feed.
///
/// Reels must NOT mix with other audio. When reels actually starts playing we
/// activate the session ([activate]); when reels stops or leaves the screen
/// (pause-all / RouteAware push / app pause / dispose) we deactivate it
/// ([deactivate]). Deactivating releases the audio route so the room regains
/// bluetooth output and reels audio stops bleeding into the room.
///
/// All calls are idempotent and never throw to the caller.
class ReelsAudioSession {
  ReelsAudioSession._();

  static final ReelsAudioSession instance = ReelsAudioSession._();

  AudioSession? _session;
  bool _active = false;
  bool _busy = false;

  Future<void> activate() async {
    if (_active || _busy) return;
    _busy = true;
    try {
      final session = _session ??= await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      await session.setActive(true);
      _active = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ReelsAudioSession] activate failed: $e');
      }
    } finally {
      _busy = false;
    }
  }

  Future<void> deactivate() async {
    if (!_active || _busy) return;
    _busy = true;
    try {
      await _session?.setActive(false);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ReelsAudioSession] deactivate failed: $e');
      }
    } finally {
      _active = false;
      _busy = false;
    }
  }
}
