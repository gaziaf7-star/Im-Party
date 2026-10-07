import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform, debugPrint;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Single source of truth for the per-client Firebase identity (Dart layer).
///
/// The app no longer hardcodes any client's Firebase project: the panel-driven
/// backend serves the active project's [FirebaseOptions] at runtime via
/// `GET /api/firebase-config`. This store fetches that payload at the very
/// top of cold start — BEFORE `Firebase.initializeApp` — and persists it to two
/// independent stores (a JSON file via path_provider AND SharedPreferences) so a
/// later offline / backend-slow cold start can still initialize Firebase from
/// the last known-good config.
///
/// Deliberately self-contained: it depends on NEITHER Firebase NOR the DI
/// container NOR the app's DioFactory. It runs before any of them exist, so it
/// uses a bounded plain `dart:io` HttpClient against the build-time
/// `API_BASE_URL`. It NEVER throws — every failure degrades to the next link in
/// the fallback chain owned by the caller (main.dart): fresh -> persisted ->
/// neutral bundled default.
class FirebaseConfigStore {
  FirebaseConfigStore._();

  static final FirebaseConfigStore instance = FirebaseConfigStore._();

  /// Build-time backend base (per-client, neutral-empty default — same source
  /// as [EndPoints.domainURL], duplicated here only to keep this store free of
  /// any app-layer import so it can run before DI/Firebase). Injected via:
  ///   flutter build ... --dart-define=API_BASE_URL=https://<host>
  static const String _apiBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  /// Public, pre-auth endpoint serving the active client's Firebase identity.
  static String get _configUrl => '$_apiBaseUrl/api/firebase-config';

  /// Cold-start fetch must never hold the splash hostage on a slow backend.
  static const Duration _fetchTimeout = Duration(seconds: 3);

  static const String _prefsKey = 'firebase_runtime_config_v1';
  static const String _fileName = 'firebase_runtime_config.json';

  Map<String, dynamic>? _config;

  /// `phoneAuthEnabled` flag from the active payload (defaults to false until a
  /// config is loaded, so phone-auth UI can't run against an unconfigured
  /// project). [FirebasePhoneAuthService] gates on this.
  bool get phoneAuthEnabled => _config?['phoneAuthEnabled'] == true;

  /// The in-memory config last loaded by [load] (fresh or persisted), or null
  /// when nothing has been loaded yet.
  Map<String, dynamic>? get config => _config;

  /// Cold-start entry point. Tries a fresh bounded fetch; on any failure falls
  /// back to the last persisted config (SharedPreferences, then disk). Returns
  /// the [FirebaseOptions] for the current platform, or null when no config is
  /// available from any source (caller then uses the neutral bundled default).
  ///
  /// Never throws.
  Future<FirebaseOptions?> load() async {
    final fresh = await _fetchRemote();
    if (fresh != null) {
      _config = fresh;
      // Persist asynchronously; do not block startup on disk/prefs writes.
      unawaited(_persist(fresh));
      return _optionsForCurrentPlatform(fresh);
    }

    final persisted = await _readPersisted();
    if (persisted != null) {
      _config = persisted;
      return _optionsForCurrentPlatform(persisted);
    }

    return null;
  }

  /// Persisted-only loader for the FCM background isolate.
  ///
  /// The OS spawns a fresh isolate (no main-isolate memory) for data messages
  /// while the app is backgrounded/terminated, on a strict time budget. This
  /// reads ONLY the cross-isolate persisted config (SharedPreferences, then the
  /// JSON file) — it NEVER touches the network so it can't blow the background
  /// callback's deadline — and returns the [FirebaseOptions] for the current
  /// platform, or null when nothing is persisted yet (e.g. the very first cold
  /// push after install). The caller then falls back to the native default.
  ///
  /// Never throws.
  Future<FirebaseOptions?> loadPersistedOnly() async {
    final persisted = await _readPersisted();
    if (persisted == null) return null;
    _config = persisted;
    return _optionsForCurrentPlatform(persisted);
  }

  /// Bounded network fetch of the runtime config. Returns the parsed payload
  /// map (already unwrapped from any `data` envelope) or null on any failure.
  Future<Map<String, dynamic>?> _fetchRemote() async {
    if (_apiBaseUrl.isEmpty) return null;
    HttpClient? client;
    try {
      client = HttpClient()..connectionTimeout = _fetchTimeout;
      final request = await client
          .getUrl(Uri.parse(_configUrl))
          .timeout(_fetchTimeout);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final response = await request.close().timeout(_fetchTimeout);
      if (response.statusCode != HttpStatus.ok) return null;
      final body =
          await response.transform(utf8.decoder).join().timeout(_fetchTimeout);
      return _unwrap(jsonDecode(body));
    } catch (e) {
      debugPrint('[FirebaseConfigStore] remote fetch failed: $e');
      return null;
    } finally {
      client?.close(force: true);
    }
  }

  /// Accepts either `{ data: {...} }` or a flat `{...}` payload.
  Map<String, dynamic>? _unwrap(dynamic decoded) {
    if (decoded is! Map) return null;
    final data = decoded['data'];
    final map = data is Map ? data : decoded;
    return Map<String, dynamic>.from(map);
  }

  /// Persist to BOTH SharedPreferences and a JSON file so a wipe/corruption of
  /// one store still leaves a usable copy for the next cold start.
  Future<void> _persist(Map<String, dynamic> config) async {
    final encoded = jsonEncode(config);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, encoded);
    } catch (e) {
      debugPrint('[FirebaseConfigStore] prefs persist failed: $e');
    }
    try {
      final file = await _configFile();
      await file.writeAsString(encoded, flush: true);
    } catch (e) {
      debugPrint('[FirebaseConfigStore] file persist failed: $e');
    }
  }

  /// Read the last persisted config. SharedPreferences first (fast, survives
  /// cache clears), then the JSON file as a second independent source.
  Future<Map<String, dynamic>?> _readPersisted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null && raw.isNotEmpty) {
        final parsed = _unwrap(jsonDecode(raw));
        if (parsed != null) return parsed;
      }
    } catch (e) {
      debugPrint('[FirebaseConfigStore] prefs read failed: $e');
    }
    try {
      final file = await _configFile();
      if (await file.exists()) {
        final raw = await file.readAsString();
        if (raw.isNotEmpty) {
          final parsed = _unwrap(jsonDecode(raw));
          if (parsed != null) return parsed;
        }
      }
    } catch (e) {
      debugPrint('[FirebaseConfigStore] file read failed: $e');
    }
    return null;
  }

  Future<File> _configFile() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$_fileName');
  }

  /// Builds [FirebaseOptions] for the running platform from a config payload.
  /// Returns null when the payload has no usable section for this platform.
  FirebaseOptions? _optionsForCurrentPlatform(Map<String, dynamic> config) {
    if (kIsWeb) return _optionsFromSection(config['web']);
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _optionsFromSection(config['android']);
      case TargetPlatform.iOS:
        return _optionsFromSection(config['ios']);
      case TargetPlatform.macOS:
        return _optionsFromSection(config['macos'] ?? config['ios']);
      default:
        return null;
    }
  }

  /// Maps a per-platform JSON section to [FirebaseOptions]. The four fields
  /// Firebase requires (apiKey, appId, messagingSenderId, projectId) must all
  /// be present and non-empty; otherwise the section is unusable -> null.
  FirebaseOptions? _optionsFromSection(dynamic section) {
    if (section is! Map) return null;
    final apiKey = _str(section['apiKey']);
    final appId = _str(section['appId']);
    final messagingSenderId = _str(section['messagingSenderId']);
    final projectId = _str(section['projectId']);
    if (apiKey.isEmpty ||
        appId.isEmpty ||
        messagingSenderId.isEmpty ||
        projectId.isEmpty) {
      return null;
    }
    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      storageBucket: _orNull(section['storageBucket']),
      databaseURL: _orNull(section['databaseURL']),
      authDomain: _orNull(section['authDomain']),
      measurementId: _orNull(section['measurementId']),
      iosBundleId: _orNull(section['iosBundleId']),
      iosClientId: _orNull(section['iosClientId']),
      androidClientId: _orNull(section['androidClientId']),
    );
  }

  String _str(dynamic v) => v?.toString().trim() ?? '';

  String? _orNull(dynamic v) {
    final s = _str(v);
    return s.isEmpty ? null : s;
  }
}
