import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Service managing all Ludo sound effects and audio feedback.
class SoundService {
  static final SoundService instance = SoundService._internal();
  factory SoundService() => instance;

  SoundService._internal() {
    _initPlayers();
  }

  final List<AudioPlayer> _stepPlayers = [];
  int _currentStepPlayerIndex = 0;
  AudioPlayer? _effectPlayer;
  AudioPlayer? _dicePlayer;

  bool isSoundEnabled = true;
  bool isMusicEnabled = true;
  bool isVibrationEnabled = true;

  bool get _isTestEnv {
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  void _initPlayers() {
    if (_isTestEnv) return;
    try {
      for (int i = 0; i < 4; i++) {
        final p = AudioPlayer();
        p.setPlayerMode(PlayerMode.lowLatency);
        _stepPlayers.add(p);
      }
      _effectPlayer = AudioPlayer()..setPlayerMode(PlayerMode.lowLatency);
      _dicePlayer = AudioPlayer()..setPlayerMode(PlayerMode.lowLatency);
    } catch (_) {}
  }

  void toggleSound() => isSoundEnabled = !isSoundEnabled;
  void toggleMusic() => isMusicEnabled = !isMusicEnabled;
  void toggleVibration() => isVibrationEnabled = !isVibrationEnabled;

  void triggerVibration({bool isHeavy = false}) {
    if (!isVibrationEnabled) return;
    try {
      if (isHeavy) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    } catch (_) {}
  }

  Future<void> playButtonClick() async {
    if (!isSoundEnabled || _isTestEnv) return;
    triggerVibration();
    try {
      if (_effectPlayer != null) {
        await _effectPlayer!.stop();
        await _effectPlayer!.play(AssetSource('sounds/ludo/button_click.wav'));
      }
    } catch (_) {}
  }

  Future<void> playDiceRoll() async {
    if (!isSoundEnabled || _isTestEnv) return;
    triggerVibration();
    try {
      if (_dicePlayer != null) {
        await _dicePlayer!.stop();
        await _dicePlayer!.play(AssetSource('sounds/ludo/dice_roll.wav'));
      }
    } catch (_) {}
  }

  Future<void> playDiceResult() async {
    if (!isSoundEnabled || _isTestEnv) return;
    try {
      if (_effectPlayer != null) {
        await _effectPlayer!.stop();
        await _effectPlayer!.play(AssetSource('sounds/ludo/dice_result.wav'));
      }
    } catch (_) {}
  }

  Future<void> playTokenStep() async {
    if (!isSoundEnabled || _isTestEnv) return;
    try {
      if (isVibrationEnabled) HapticFeedback.selectionClick();
      if (_stepPlayers.isNotEmpty) {
        final p = _stepPlayers[_currentStepPlayerIndex];
        _currentStepPlayerIndex =
            (_currentStepPlayerIndex + 1) % _stepPlayers.length;
        await p.stop();
        await p.play(AssetSource('sounds/ludo/token_step.wav'));
      }
    } catch (_) {}
  }

  Future<void> playTokenSpawn() async {
    if (!isSoundEnabled || _isTestEnv) return;
    triggerVibration(isHeavy: true);
    try {
      if (_effectPlayer != null) {
        await _effectPlayer!.stop();
        await _effectPlayer!.play(AssetSource('sounds/ludo/token_spawn.wav'));
      }
    } catch (_) {}
  }

  Future<void> playSixRoll() async {
    if (!isSoundEnabled || _isTestEnv) return;
    triggerVibration(isHeavy: true);
    try {
      if (_effectPlayer != null) {
        await _effectPlayer!.stop();
        await _effectPlayer!.play(AssetSource('sounds/ludo/six_roll.wav'));
      }
    } catch (_) {}
  }

  Future<void> playExtraTurn() async {
    if (!isSoundEnabled || _isTestEnv) return;
    try {
      if (_effectPlayer != null) {
        await _effectPlayer!.stop();
        await _effectPlayer!.play(AssetSource('sounds/ludo/extra_turn.wav'));
      }
    } catch (_) {}
  }

  Future<void> playCapture() async {
    if (!isSoundEnabled || _isTestEnv) return;
    triggerVibration(isHeavy: true);
    try {
      if (_effectPlayer != null) {
        await _effectPlayer!.stop();
        await _effectPlayer!.play(AssetSource('sounds/ludo/capture.wav'));
      }
    } catch (_) {}
  }

  Future<void> playSafeZone() async {
    if (!isSoundEnabled || _isTestEnv) return;
    try {
      if (_effectPlayer != null) {
        await _effectPlayer!.stop();
        await _effectPlayer!.play(AssetSource('sounds/ludo/safe_zone.wav'));
      }
    } catch (_) {}
  }

  Future<void> playTokenHome() async {
    if (!isSoundEnabled || _isTestEnv) return;
    triggerVibration(isHeavy: true);
    try {
      if (_effectPlayer != null) {
        await _effectPlayer!.stop();
        await _effectPlayer!.play(AssetSource('sounds/ludo/token_home.wav'));
      }
    } catch (_) {}
  }

  Future<void> playWin() async {
    if (!isSoundEnabled || _isTestEnv) return;
    triggerVibration(isHeavy: true);
    try {
      if (_effectPlayer != null) {
        await _effectPlayer!.stop();
        await _effectPlayer!.play(AssetSource('sounds/ludo/win.wav'));
      }
    } catch (_) {}
  }

  Future<void> playLose() async {
    if (!isSoundEnabled || _isTestEnv) return;
    try {
      if (_effectPlayer != null) {
        await _effectPlayer!.stop();
        await _effectPlayer!.play(AssetSource('sounds/ludo/lose.wav'));
      }
    } catch (_) {}
  }

  void dispose() {
    for (final p in _stepPlayers) {
      p.dispose();
    }
    _effectPlayer?.dispose();
    _dicePlayer?.dispose();
  }
}
