import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Low-latency sound effects for the Carom board. One dedicated player per
/// effect, loaded lazily on first use so the room opens instantly.
class CaromAudio {
  CaromAudio._();
  static final CaromAudio instance = CaromAudio._();

  bool soundEnabled = true;
  double masterVolume = 1.0;

  final Map<String, AudioPlayer> _players = {};
  final Set<String> _loading = {};
  final Random _random = Random();

  Future<AudioPlayer?> _player(String name) async {
    final existing = _players[name];
    if (existing != null) return existing;
    if (!_loading.add(name)) return null;
    try {
      final p = AudioPlayer();
      await p.setReleaseMode(ReleaseMode.stop);
      await p.setPlayerMode(PlayerMode.lowLatency);
      await p.setSource(AssetSource('sounds/carom/$name.wav'));
      _players[name] = p;
      return p;
    } catch (e) {
      if (kDebugMode) debugPrint('CaromAudio load $name: $e');
      return null;
    } finally {
      _loading.remove(name);
    }
  }

  /// Warms every effect once so the first shot has no load delay.
  Future<void> preload() async {
    for (final n in const [
      'strike',
      'hit',
      'cushion',
      'pocket',
      'foul',
      'cheer',
      'win',
    ]) {
      await _player(n);
    }
  }

  void _play(String name, double volume, {double? rate}) {
    if (!soundEnabled) return;
    final p = _players[name];
    if (p == null) {
      _player(name); // load for next time
      return;
    }
    try {
      if (rate != null) p.setPlaybackRate(rate);
      p.setVolume(volume.clamp(0.0, 1.0));
      p.stop();
      p.resume();
    } catch (_) {}
  }

  void playStrike({double power = 1.0}) =>
      _play('strike', (power * masterVolume).clamp(0.2, 1.0));

  void playHit({double intensity = 1.0}) => _play(
    'hit',
    (intensity * masterVolume).clamp(0.15, 1.0),
    rate: 0.95 + _random.nextDouble() * 0.1,
  );

  void playCushion({double intensity = 1.0}) =>
      _play('cushion', (intensity * masterVolume).clamp(0.2, 1.0));

  void playPocket() => _play('pocket', masterVolume);
  void playFoul() => _play('foul', masterVolume * 0.9);
  void playCheer() => _play('cheer', masterVolume);
  void playWin() => _play('win', masterVolume);

  void dispose() {
    for (final p in _players.values) {
      p.dispose();
    }
    _players.clear();
  }
}
