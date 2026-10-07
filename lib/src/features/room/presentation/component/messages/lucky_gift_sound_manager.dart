import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

/// Singleton manager for handling Lucky Gift Winner sound effects
/// If sound is playing, ignore. If not, play.
class LuckyGiftSoundManager {
  LuckyGiftSoundManager._internal();
  static final LuckyGiftSoundManager _instance =
      LuckyGiftSoundManager._internal();
  static LuckyGiftSoundManager get instance => _instance;

  static const String _soundAsset = 'sounds/lucky_gift_win.mp3';

  AudioPlayer? _audioPlayer;
  StreamSubscription<PlayerState>? _playerSubscription;
  bool _isInitialized = false;
  bool _isPlaying = false;

  void initialize() {
    if (_isInitialized) return;
    _audioPlayer = AudioPlayer();
    _playerSubscription = _audioPlayer?.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
    });
    _isInitialized = true;
  }

  void tryPlaySound() {
    if (!_isInitialized) initialize();

    if (_isPlaying) return;

    try {
      _audioPlayer?.setVolume(0.7);
      _audioPlayer?.play(AssetSource(_soundAsset)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          // Timeout - audio took too long to load, ignore
        },
      );
    } catch (e) {
      // Ignore audio playback errors
    }
  }

  void dispose() {
    _playerSubscription?.cancel();
    _playerSubscription = null;
    _audioPlayer?.dispose();
    _audioPlayer = null;
    _isPlaying = false;
    _isInitialized = false;
  }
}
