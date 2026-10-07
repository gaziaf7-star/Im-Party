import 'dart:developer';

import 'package:general/src/core/index.dart';

/// Bridges the Dart room lifecycle to the native "room_service_channel".
///
/// Restores the app-kill cleanup + background-audio behavior that the
/// Zego->UTD migration dropped:
///  * iOS  — stores room_id/token/lang/type in UserDefaults; AppDelegate's
///           applicationWillTerminate POSTs /rooms/quit_room on app kill.
///  * Android — stores the same in SharedPreferences and starts a
///           mediaPlayback foreground service so audio survives backgrounding;
///           the service's onTaskRemoved POSTs /rooms/quit_room on swipe-kill.
///
/// All calls are best-effort: a missing handler / platform exception must never
/// break room entry, so every invocation is guarded.
///
/// NOTE: the native foreground service + onTaskRemoved paths require an
/// on-device smoke test (room entry does not crash on Android 14+, audio
/// continues when backgrounded, swipe-kill frees the seat) before release.
class RoomBackgroundService {
  RoomBackgroundService._();

  static const MethodChannel _channel = MethodChannel('room_service_channel');

  /// Start native room keep-alive + persist credentials for app-kill cleanup.
  static Future<void> start({
    required String roomId,
    required bool isLive,
  }) async {
    try {
      final token = Methods.getUserToken();
      final lang = HiveManager()
              .getData<String>(KeysManager.USER_BOX, KeysManager.LANG_CODE_KEY) ??
          'en';
      await _channel.invokeMethod<void>('startRoomService', {
        'room_id': roomId,
        'token': token,
        'language_code': lang,
        'room_type': isLive ? 'live' : 'audio',
        // Pass the runtime API base so the native onTaskRemoved cleanup can build
        // the quit_room URL without a hardcoded host (white-label).
        'api_base_url': EndPoints.baseURL,
      });
    } catch (e) {
      log('[RoomBackgroundService] start failed: $e', name: 'room_bg');
    }
  }

  /// Stop the native service and clear the persisted credentials.
  static Future<void> stop() async {
    try {
      await _channel.invokeMethod<void>('stopRoomService');
    } catch (e) {
      log('[RoomBackgroundService] stop failed: $e', name: 'room_bg');
    }
  }
}
