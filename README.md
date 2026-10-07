# Eagle

A Flutter mobile application focused on live audio/video rooms, short-form "reels" viewing and social interactions. The project integrates with third-party SDKs (Zego), Firebase, and includes several feature modules (reels, rooms, chats, payments, profiles, etc.).

This repository branch: `eagle_live_room`.

## Table of contents
- Project idea
- Key features
- Quick start (run locally)
- Project structure and important files
- Native & third-party setup notes
- Development workflow & useful commands
- Testing, linting, CI suggestions

## Project idea

Tempo Live is a Flutter-based social/media app that provides live rooms (audio/video), short-form video reels, and interactive features such as reactions, sharing, chat, and user profiles. The project is modular: core/shared utilities live under `lib/src/core` while features live in feature folders.

## Key features
- Live audio/video rooms using Zego SDK
- Reels viewer with like/share actions and optimized caching
- Firebase services (analytics, auth, crashlytics, messaging)
- Modular architecture with base repositories, use-cases, DI, and network layer
- Asset caching for images, videos, SVGA, VAP and other media formats

## Quick start (run locally)

Prerequisites
- Flutter SDK (stable). Project appears to use modern Flutter (null-safety). Use the Stable channel. Example: Flutter 3.x or later recommended.
- Android SDK + Xcode for iOS builds
- Java / Gradle (for Android builds)
- Firebase CLI / flutterfire CLI (if you want to regenerate `firebase_options.dart`)

Basic steps

1. Clone the repo and switch to the working branch.
   git clone <repo> && cd Tempo-Live
   git checkout eagle_live_room

2. Acquire native credentials
- For Android: put `google-services.json` in `android/app/` (already present in the repo for some flavors).
- For iOS: add `GoogleService-Info.plist` to `ios/Runner` if needed.
- Add Android signing keystore and update `android/key.properties` as required.

3. Install packages:
   flutter pub get

4. Configure Firebase (if you need to regenerate options):
   Use the flutterfire CLI (optional) to generate `lib/firebase_options.dart` if you need to target different projects.

5. Run the app (debug):
   flutter run -d <device>

6. Build release APK (Android):
   flutter build apk --release

7. Build iOS (on macOS):
   flutter build ipa

Notes
- The project includes native SDKs (Zego). Follow platform-specific onboarding steps in `android/` and `ios/` to set API keys and required permissions before production builds.

## Project structure (high-level)

Root (important files)
- `pubspec.yaml` - dependencies and assets
- `android/`, `ios/` - native projects and build config
- `lib/main.dart` - app entrypoint
- `lib/firebase_options.dart` - generated Firebase configuration

Key lib folders
- `lib/src/core/` - core application code and shared utilities
  - `app.dart` - main App widget and initialization
  - `index.dart` - app bootstrap/entry wiring
  - `base/` - base repository, use cases, responses and parameter objects
  - `cache/` - image/video/svga/vap cache managers
  - `network/` - `dio_factory.dart`, network exceptions and failure messages
  - `routes/` - `routes_manager.dart` handles navigation routing
  - `services/` - DI, connectivity, background services

- `lib/reels_viewer/` - reels UI and BLoC implementation (viewer, widgets, share features)
- `lib/county_code/` - country picker and localization for country codes
- `lib/zego/` - Zego integration and wrappers

Other notable parts
- `fastlane/` - release automation for Android/iOS
- `analysis_options.yaml` - analyzer and lint rules

## Important files (quick reference)
- `lib/main.dart` - app startup
- `lib/src/core/app.dart` - app-level initialization and theme
- `lib/src/core/network/dio_factory.dart` - HTTP client factory
- `lib/src/core/services/dependency_injection_service.dart` - DI container registration
- `lib/src/core/cache/*_cache_manager.dart` - media caching implementations
- `lib/reels_viewer/` - reels UI and business logic
- `android/key.properties` and `android/app/build.gradle` - Android signing and build config
- `fastlane/Fastfile` - release lanes and automation

## Native SDKs and third-party setup notes

- Zego: check `lib/zego/` + native platform instructions. Make sure to add Zego app ID / keys to native config before building.
- Firebase: `lib/firebase_options.dart` is present; if you need to target another Firebase project, run `flutterfire configure` or regenerate the file with the FlutterFire CLI.
- Ensure `google-services.json` and `GoogleService-Info.plist` are present for the chosen Firebase project.

## Development workflow & useful commands

- Install dependencies: `flutter pub get`
- Run app on device: `flutter run -d <device>`
- Run analyzer: `flutter analyze`
- Run tests: `flutter test`
- Format code: `dart format .` or `flutter format .`
- Build APK: `flutter build apk --release`
- Analyze size of release AAB/APK: `flutter build appbundle --analyze-size`
- Run in profile mode (for performance testing): `flutter run --profile`

## Testing & CI recommendations

- Use `flutter analyze` and `flutter test` in CI pipeline (GitHub Actions / GitLab CI).
- Run `flutter build --release` in a dedicated CI runner for smoke verification before distributing builds.

## Contributing

- Follow the project's lint rules in `analysis_options.yaml`.
- Add unit and widget tests for new features. Keep features modular.
- Use feature branches and PR reviews.

## Where to look first when debugging
- `lib/main.dart` and `lib/src/core/app.dart` for bootstrapping and initialization.
- `lib/src/core/network/dio_factory.dart` for API/network related issues.
- `lib/src/core/services/dependency_injection_service.dart` for incorrect DI bindings.
- `android/app/src/main/AndroidManifest.xml` and iOS `Info.plist` for permission or SDK configuration issues.

## Final notes

This README provides a starting point and run instructions. For platform-specific SDK keys, secure credentials and production configuration, consult the native `android/` and `ios/` folders and any team vault or environment manager used by your organization.

If you want, I can also:
- add a short GitHub Actions workflow for lint/test/build
- create a short CONTRIBUTING.md with PR checklist
- produce a file that lists exact places to check for performance issues (I will add a dedicated file with that information if you want).


