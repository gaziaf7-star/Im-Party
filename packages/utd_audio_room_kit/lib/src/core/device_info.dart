import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Device facts auto-collected for the backend's per-participant view (dashboard
/// device/OS/app columns). Every field is optional — on an unsupported platform
/// or a plugin failure it degrades to null rather than blocking token issuance.
class UTDDeviceInfo {
  final String? deviceModel;
  final String? os;
  final String? osVersion;
  final String? appVersion;

  const UTDDeviceInfo({
    this.deviceModel,
    this.os,
    this.osVersion,
    this.appVersion,
  });
}

/// Resolves [UTDDeviceInfo] once per process (cached) and NEVER throws — the
/// engine's participants columns are bounded (device_model 100, os 50,
/// os_version 20, app_version 20), so values are capped to those limits to avoid
/// an oversized-write failure on the webhook insert.
class UTDDeviceInfoCollector {
  UTDDeviceInfoCollector._();

  static UTDDeviceInfo? _cached;
  static Future<UTDDeviceInfo>? _inFlight;

  static String? _cap(String? v, int max) {
    if (v == null) return null;
    final s = v.trim();
    if (s.isEmpty) return null;
    return s.length > max ? s.substring(0, max) : s;
  }

  static Future<UTDDeviceInfo> collect() {
    final cached = _cached;
    if (cached != null) return Future.value(cached);
    // Memoize the in-flight collection so a warm-up call and the join's own
    // call racing each other don't both walk the platform channels.
    return _inFlight ??= _collect();
  }

  static Future<UTDDeviceInfo> _collect() async {
    String? model;
    String? os;
    String? osVersion;
    String? appVersion;

    // Package info and device info are independent platform channels — resolve
    // them concurrently (one hop on the join path instead of two); each side
    // still degrades to nulls on its own failure.
    await Future.wait<void>([
      () async {
        try {
          final pkg = await PackageInfo.fromPlatform();
          appVersion = pkg.version;
        } catch (_) {}
      }(),
      () async {
        try {
          final plugin = DeviceInfoPlugin();
          if (kIsWeb) {
            os = 'web';
            final web = await plugin.webBrowserInfo;
            model = web.browserName.name;
            osVersion = web.platform;
          } else if (Platform.isAndroid) {
            os = 'android';
            final a = await plugin.androidInfo;
            model = a.model;
            osVersion = a.version.release;
          } else if (Platform.isIOS) {
            os = 'ios';
            final i = await plugin.iosInfo;
            model = i.utsname.machine;
            osVersion = i.systemVersion;
          } else if (Platform.isMacOS) {
            os = 'macos';
            final m = await plugin.macOsInfo;
            model = m.model;
            osVersion = m.osRelease;
          } else if (Platform.isWindows) {
            os = 'windows';
            final w = await plugin.windowsInfo;
            model = w.productName;
            osVersion = w.displayVersion;
          } else if (Platform.isLinux) {
            os = 'linux';
            final l = await plugin.linuxInfo;
            model = l.prettyName;
            osVersion = l.versionId;
          }
        } catch (_) {}
      }(),
    ]);

    _cached = UTDDeviceInfo(
      deviceModel: _cap(model, 100),
      os: _cap(os, 50),
      osVersion: _cap(osVersion, 20),
      appVersion: _cap(appVersion, 20),
    );
    return _cached!;
  }
}
