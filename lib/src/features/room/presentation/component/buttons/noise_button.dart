import 'package:shared_preferences/shared_preferences.dart';
import 'package:utd_audio_room_kit/utd_audio_room_kit.dart' show UTDMediaController;


/// The user's saved "Noise" choice (background-noise reduction on the mic).
/// It is a per-device setting -- nothing is stored on the server.
class NoiseReductionPrefs {
  static const String _key = 'room_noise_reduction';

  /// Loads the saved choice into the room kit before the mic is captured.
  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      UTDMediaController.defaultNoiseReduction = prefs.getBool(_key) ?? true;
    } catch (_) {}
  }

  static Future<void> save(bool on) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, on);
    } catch (_) {}
  }
}
