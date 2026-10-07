// NEUTRAL last-resort Firebase options.
//
// White-label: this app carries NO hardcoded client Firebase identity in Dart.
// The active project's [FirebaseOptions] are served at runtime by the panel
// (GET /api/v1/firebase-config) and applied via FirebaseConfigStore BEFORE
// Firebase.initializeApp. See lib/main.dart and
// lib/src/core/services/firebase_config_store.dart.
//
// Previously this file embedded a MIXED, stale per-client identity
// No baked Firebase config — configured at runtime from the admin panel.
// It now intentionally contains no apiKey/appId/projectId for any client.
//
// The runtime path is the single source of truth. If the runtime config is
// unavailable (offline first launch with nothing persisted), main.dart falls
// back to Firebase.initializeApp() WITHOUT options, which on Android lets the
// native google-services.json drive initialization (the FCM hybrid). On iOS the
// native GoogleService-Info.plist serves the same role.
//
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Neutral [FirebaseOptions] holder. Intentionally exposes NO client identity.
///
/// [currentPlatform] always throws: there is no bundled per-client config to
/// return. Callers must obtain options at runtime from [FirebaseConfigStore],
/// and on a hard miss fall back to options-less native initialization.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnsupportedError(
      'No bundled Firebase identity. The active project is served at runtime '
      'by the panel (GET /api/v1/firebase-config) via FirebaseConfigStore. '
      'On a hard miss, initialize Firebase without options so the native '
      'google-services.json / GoogleService-Info.plist drives it.',
    );
  }
}
