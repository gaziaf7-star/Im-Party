<!--
  Copilot / AI agent instructions for Tempo-Live repository.
  Keep this file short, concrete, and focused on repository-specific guidance.
-->

# Tempo-Live — AI Coding Assistant Guidance

Goal: Help AI coding agents become productive quickly by documenting the project's
architecture, conventions, common workflows, and concrete file examples.

- **Project type**: Flutter mobile app (Android + iOS) using Dart null-safety.
- **Package id**: `general` (see `pubspec.yaml`) — imports use `package:general/...`.
- **Key frameworks**: `flutter_bloc`, `get_it` for DI, `hive` for local storage,
  `dio` for networking, large native SDK surface (Zego, Firebase, ffmpeg).

Architecture & where to look
- App entry: `lib/main.dart` — initialization order (Firebase, Crashlytics, DI,
  Hive, Notifications, permissions, orientation). Use this to understand startup
  side-effects and global state (e.g., `navKey`, `NavObserver`).
- Core code: `lib/src/core/` — app bootstrap (`app.dart` / `index.dart`), DI
  (`dependency_injection_service.dart`), network (`network/dio_factory.dart`),
  cache managers (`cache/*_cache_manager.dart`), and routing (`routes/routes_manager.dart`).
- Features are modular under `lib/` (e.g., `lib/reels_viewer/`, `lib/zego/`,
  `lib/county_code/`). Inspect feature folders to find BLoC/state, widgets, and
  platform integrations.

Build, run & CI commands (Windows PowerShell / macOS examples)
- Install deps: `flutter pub get`
- Run app (device): `flutter run -d <device>`
- Analyze: `flutter analyze`
- Tests: `flutter test`
- Format: `dart format .`
- Generate code (Hive/build_runner):
  `flutter pub run build_runner build --delete-conflicting-outputs`
- Release (Android): `flutter build apk --release` (signing configured via
  `android/key.properties` and `android/app/build.gradle`). Fastlane lanes live
  in `fastlane/Fastfile` for automated releases.

Conventions & patterns specific to this repo
- DI: `DependencyInjectionService.init()` registers services; prefer using
  `get_it` bindings rather than ad-hoc constructors across the app.
- Network: `lib/src/core/network/dio_factory.dart` creates Dio clients. Look
  for wrapper methods and common interceptors when adding API calls.
- Caching: media caching lives under `lib/src/core/cache/` (images, videos,
  SVGA, VAP). Use existing cache managers for consistency and to avoid
  duplicating cache logic.
- Localization: uses `easy_localization`. Source files are under
  `lib/core/translations/`. The app wraps the root in `EasyLocalization`.
- Assets: static assets are grouped under `assets/` (images, videos, icons,
  lottie, beautyIcons). Add assets to `pubspec.yaml` when introducing new files.
- Naming: project uses `general` package name; be cautious when search-and-replace
  to avoid breaking imports.

Integration & secrets
- Firebase config: `lib/firebase_options.dart` is generated (FlutterFire).
  `google-services.json` (Android) may already be in `android/app/`. Do not
  commit alternate production credentials; follow team secret management.
- Native SDKs: Zego and other native integrations require platform keys and
  native manifest/plist updates — check `lib/zego/` and the native folders.

Quick examples to reference in PRs or edits
- To add an API client: mirror patterns in `lib/src/core/network/` and register
  the client in `dependency_injection_service.dart`.
- To add a new feature module: create `lib/<feature_name>/` with BLoC, pages,
  and widgets; register any services in DI and add routes via
  `routes/routes_manager.dart`.

Testing & codegen notes
- Many packages use code generation: run `build_runner` when modifying models
  or Hive adapters. CI should run `flutter pub get` + `flutter test` +
  `flutter analyze`.

What to avoid / gotchas
- Do not assume the package name is the repo name — imports use `package:general/...`.
- Watch dependency overrides in `pubspec.yaml`; some packages are pinned to
  specific versions to avoid conflicts (search `dependency_overrides`).
- App initialization has many side-effects (Crashlytics, FirebasePerformance,
  NotificationService); when changing startup flow, preserve error handling
  and Crashlytics reporting patterns (see `main.dart`).

If you need more detail
- Ask which feature or area you want to modify (networking, caching, reels,
  Zego integration) and I will expand with file-level examples and code snippets.

---
Files referenced: `lib/main.dart`, `lib/src/core/`, `lib/firebase_options.dart`,
`pubspec.yaml`, `fastlane/Fastfile`, `android/key.properties`, `android/app/`, `assets/`.
