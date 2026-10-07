import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// Stable per-install device identifier for the backend's single-active-session
/// enforcement ("one token per user & device", newest-wins). The engine keys the
/// kick/takeover decision on this id, so it MUST be stable across app restarts:
/// we generate a random UUIDv4 once and persist it in SharedPreferences (no extra
/// native deps). The host app may override it by passing `deviceId` explicitly to
/// [UTDRoomController.generateToken].
///
/// Resolution never throws — if persistence is unavailable it falls back to an
/// ephemeral id stable for the current process, so token issuance is never broken
/// by this (the backend just degrades to per-process single-session).
class UTDDeviceId {
  UTDDeviceId._();

  static const String _key = 'utd_device_id';
  static String? _cached;

  static Future<String> resolve() async {
    if (_cached != null) return _cached!;
    try {
      final prefs = await SharedPreferences.getInstance();
      var id = prefs.getString(_key);
      if (id == null || id.isEmpty) {
        id = _uuidV4();
        await prefs.setString(_key, id);
      }
      _cached = id;
    } catch (_) {
      _cached ??= _uuidV4();
    }
    return _cached!;
  }

  static String _uuidV4() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // RFC 4122 variant
    String hex(int b) => b.toRadixString(16).padLeft(2, '0');
    final h = bytes.map(hex).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
        '${h.substring(16, 20)}-${h.substring(20)}';
  }
}
