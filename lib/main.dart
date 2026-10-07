// =============================================================================
//  ZAVIRO LIVE
//  Built by Fuvio Media & Entertainment Ltd.
//
//  Copyright (c) 2026 Fuvio Media & Entertainment Ltd. All rights reserved.
//
//  PROPRIETARY AND CONFIDENTIAL
//  This software, including its source code, architecture, assets and
//  documentation, is the exclusive property of Fuvio Media & Entertainment Ltd.
//  and is protected by copyright and international treaty provisions.
//
//  It is licensed, not sold. No part of this software may be copied,
//  reproduced, modified, decompiled, reverse-engineered, redistributed or used
//  to derive another work, in whole or in part, without the prior written
//  permission of Fuvio Media & Entertainment Ltd. Unauthorised use or
//  reproduction is a violation of applicable law and will be pursued.
//
//  Licensing, permissions and commercial enquiries:
//     Fuvio Live
//      Email     : admin@fuvio.live
//      WhatsAp p  : +1 347 670 0318
// =============================================================================

import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
// ignore: depend_on_referenced_packages
import 'package:package_info_plus/package_info_plus.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/services/firebase_config_store.dart';
import 'package:general/src/core/cache/alpha_cache_manager.dart';
import 'package:general/src/core/cache/image_cache_manager.dart';
import 'package:general/src/core/cache/svg_cache_manager.dart';
import 'package:general/src/core/cache/svga_cache_manager.dart';
import 'package:general/src/core/cache/vap_cache_manager.dart';
import 'package:general/src/core/cache/video_cache_manager.dart';
import 'package:general/src/core/services/notification/notification_service.dart';
import 'package:utd_live_room_kit/utd_live_room_kit.dart' as live;

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
final NavObserver navigatorObserver = NavObserver();

ValueNotifier<bool> isInPip = ValueNotifier(false);

Future<void> main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

    // Cap the in-memory decoded-image cache (default is 100MB/1000 imgs).
    // Pairs with display-size decoding in CacheImageWidget to bound RAM.
    PaintingBinding.instance.imageCache.maximumSizeBytes = 100 << 20; // 100 MB

    try {
      Methods.printLog("⏳ Starting initialization...");

      // Runtime Firebase identity (white-label, ONE source of truth): fetch the
      // active client's FirebaseOptions from the panel BEFORE Firebase.initializeApp.
      // Bounded (~3s) so a slow backend can't hang the splash; persisted by the
      // store so the next cold start works offline. The Dart layer is fully
      // panel-driven; no client identity is hardcoded (firebase_options.dart is
      // neutral). FCM HYBRID: when no runtime config resolves, we initialize
      // WITHOUT options so the native google-services.json / GoogleService-Info.plist
      // still drives the FCM background isolate + native token registration.
      final FirebaseOptions? runtimeFirebaseOptions =
      await FirebaseConfigStore.instance.load().timeout(
        const Duration(seconds: 4),
        onTimeout: () => null,
      );

      await Future.wait([
        _initFirebase(runtimeFirebaseOptions),
        EasyLocalization.ensureInitialized(),
        Hive.initFlutter(),
        SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp],
        ),
      ]);
      Methods.printLog(
          "✅ Phase 1 complete (Firebase, Localization, Hive, Orientation)");

      // عطّل تجميع Crashlytics في وضع الـ debug، وفعّله في الإنتاج.
      // مجرّد علم (flag) لا يحجب أول إطار — شغّله بلا await خارج المسار الحرج.
      unawaited(FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode));

      // وحّد رقم الإصدار: اقرأ الـ versionCode الفعلي للبناء (يمنع لخبطة التحديث الإجباري).
      // مجرّد بيانات وصفية (نسخة/اسم) لا تحجب أول إطار — اقرأها بلا await.
      unawaited(PackageInfo.fromPlatform().then((pkg) {
        final code = int.tryParse(pkg.buildNumber);
        if (code != null && code > 0) ConstantsManager.appVersionCode = code;
        // الـ versionName (مثل "1.0.17") — للعرض في الأدمن؛ المقارنة الداخلية تظل بالـ code.
        if (pkg.version.isNotEmpty) ConstantsManager.appVersionName = pkg.version;
        // اسم التطبيق المعروض (native label) — لعنوان شاشة المحادثات بلا hard-code.
        if (pkg.appName.trim().isNotEmpty) {
          ConstantsManager.appDisplayName = pkg.appName.trim();
        }
      }).catchError((_) {}));

      // Setup Crashlytics error tracking (depends on Firebase)
      FlutterError.onError = (FlutterErrorDetails details) {
        if (_isPackageError(details.stack)) {
          Methods.printLog('⚠️ Snoozing package error: ${details.summary}');
          return; // Skip Crashlytics
        }
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        if (_isPackageError(stack)) {
          Methods.printLog('⚠️ Snoozing package error: $error');
          return true;
        }
        if (_isCameraFocusNoise(error.toString())) {
          Methods.printLog('⚠️ Snoozing camera tap-to-focus error: $error');
          return true;
        }
        // Realtime/media-engine errors are server-side (UTD Stream) and were
        // survived (handled by the framework, returning true) — record them
        // non-fatal so they don't read as app crashes.
        final realtime = _isRealtimeStack(stack) ||
            _isRealtimeMessage(error.toString());
        FirebaseCrashlytics.instance
            .recordError(error, stack, fatal: !realtime);
        return true;
      };
      Methods.printLog("✅ Crashlytics ready");

      // Room music + SFX (gift/lucky-win/SVGA sounds) all use audioplayers,
      // whose Android default makes EVERY player request exclusive audio focus
      // (AUDIOFOCUS_GAIN) — so any gift/win sound kicked the playing room
      // music out. Set the global default to no focus request so all players
      // (including flutter_svga's internal one) mix instead of fighting.
      // Android-only: iOS shares one session and never had the problem, and
      // touching it would override the room's playAndRecord/voiceChat config.
      if (!kIsWeb && Platform.isAndroid) {
        await AudioPlayer.global.setAudioContext(
          AudioContext(
            android: const AudioContextAndroid(
              audioFocus: AndroidAudioFocus.none,
            ),
          ),
        );
        Methods.printLog("✅ Global audio context set (mix, no focus steal)");
      }

      // Phase 2: DI, Hive boxes, and local path in parallel
      await Future.wait([
        DependencyInjectionService.init(),
        _openHiveBoxes(),
        Methods.getLocalPath().then((localPath) {
          if (Platform.isIOS) {
            EndPoints.iosPath = localPath;
          } else {
            EndPoints.androidPath = localPath;
          }
          Methods.printLog("📂 Local path initialized: $localPath");
        }),
      ]);
      Methods.printLog("✅ Phase 2 complete (DI, Hive boxes, local path)");

      // Notifications setup. onBackgroundMessage is registered inside
      // NotificationService.initialize() — do NOT register it again here (#83).
      // Push isn't needed to render splash/home, so keep FCM init OFF the
      // pre-runApp critical path: fire it unawaited (still capped at 8s so a
      // fresh Firebase project can't hang it). Removes it from time-to-first-frame.
      unawaited(NotificationService()
          .initialize()
          .timeout(const Duration(seconds: 8), onTimeout: () {}));
    } catch (error, stack) {
      Methods.printLog("❌ Initialization failed: $error");
      Methods.printLog("StackTrace: $stack");
      await FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }

    FlutterNativeSplash.remove();

    FlutterError.onError = (FlutterErrorDetails details) {
      if (_isPackageError(details.stack)) {
        Methods.printLog('⚠️ Snoozing package error: ${details.summary}');
        return; // Skip Crashlytics (plugin reply bounce, e.g. DartMessenger/flutter_vap)
      }
      if (details.toString().contains('Invalid state transition')) {
        // Log but don't crash
        Methods.printLog('Suppressed lifecycle error: ${details.summary}');
        return;
      }
      // Realtime/media-engine errors (LiveKit / UTD Stream) are server-side and
      // recoverable — record them non-fatal so a flaky media server doesn't show
      // up as an app crash. Everything else is recorded as a real Flutter error.
      if (_isRealtimeStack(details.stack) ||
          _isRealtimeMessage(details.toString())) {
        FirebaseCrashlytics.instance.recordFlutterError(details, fatal: false);
        return;
      }
      FirebaseCrashlytics.instance.recordFlutterError(details);
      FlutterError.presentError(details);
    };

    // Run the app safely after initialization
    runApp(
      DevicePreview(
        enabled: false,
        builder: (context) => EasyLocalization(
          path: 'lib/core/translations/',
          fallbackLocale: Locale(LanguageType.en.name),
          saveLocale: true,
          assetLoader: const LocaleKeys(),
          startLocale: Locale(LanguageType.en.name),
          // Six app languages are fully enabled. The translation loader already
          // contains maps for all of these locale codes. English remains the
          // safe fallback when a key is missing from another language.
          supportedLocales: [
            Locale(LanguageType.en.name),
            Locale(LanguageType.ar.name),
            Locale(LanguageType.tr.name),
            Locale(LanguageType.ur.name),
            Locale(LanguageType.hi.name),
            Locale(LanguageType.id.name),
          ],
          child: Builder(
            builder: (context) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: MediaQuery.textScalerOf(context).clamp(
                    minScaleFactor: 1.0,
                    maxScaleFactor: 1.0,
                  ),
                ),
                child: TempApp(),
              );
            },
          ),
        ),
      ),
    );

    // Deferred to after first frame: these are already non-blocking, but keeping
    // them out of the pre-runApp block trims the time-to-first-frame window.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Non-blocking: cache eviction
      unawaited(AssetCacheManager().evictExpiredCache());
      unawaited(VideoAssetCacheManager().evictExpiredCache());
      unawaited(SVGAAssetCacheManager().evictExpiredCache());
      unawaited(VapAssetCacheManager().evictExpiredCache());
      unawaited(AlphaAssetCacheManager().evictExpiredCache());
      unawaited(SvgCacheManager().evictExpiredCache());

      // PiP state listener (non-blocking, synchronous setup)
      _setupPipListener();
      Methods.printLog("✅ PiP state listener started");
    });
  }, (error, stack) {
    Methods.printLog("❌ Uncaught Zone Error: $error");
    final zoneErrorText = error.toString();
    if (_isCameraFocusNoise(zoneErrorText)) {
      // livekit_client's VideoTrackRenderer fires unawaited
      // Helper.setFocusPoint/setExposurePoint on every preview tap; some
      // devices NPE natively (DeviceOrientation.ordinal()). Focus is cosmetic
      // — nothing to recover, so don't pollute Crashlytics (181 events/72h).
      // Root fix (null-guard in the flutter_webrtc fork) needs a Play build.
      return;
    }
    // Errors that reach the zone guard were survived (the app did not crash).
    // Device-level video/codec playback errors (e.g. ExoPlaybackException) are
    // not app crashes, so log them as non-fatal to keep crash stats accurate.
    final errorText = error.toString();
    final isVideoError = errorText.contains('VideoError') ||
        errorText.contains('ExoPlaybackException') ||
        errorText.contains('MediaCodecVideoRenderer');
    // ارتداد flutter_vap2 (NativeVapView) في 2.0.1: ليس كراش تطبيق فعلي.
    final isVapError = errorText.contains('Reply already submitted') ||
        errorText.contains('DartMessenger');
    // أخطاء الشبكة (Dio) ليست كراش تطبيق — اتصال/مهلة/استجابة سيئة من السيرفر.
    // سجّلها non-fatal حتى لا تلوّث نسبة الـ crash-free (وصلت للـ zone = نجا التطبيق).
    final isNetworkError = errorText.contains('DioException') ||
        errorText.contains('package:dio/');
    // أخطاء المحرك اللحظي (LiveKit / UTD Stream / UTD Audio Room Kit): فشل
    // الاتصال/النشر/التفاوض بسبب بطء أو تعذّر سيرفر البث (UTD Stream)، وليست
    // كراش في كودنا. وصلت للـ zone = نجا التطبيق، فسجّلها non-fatal حتى لا تظهر
    // كأنها كراشات. (المصدر الجذري سيرفري: UTD Stream timeouts — خارج النطاق).
    final isRealtimeError = errorText.contains('package:livekit_client/') ||
        errorText.contains('package:utd_audio_room_kit/') ||
        errorText.contains('LiveKit') ||
        errorText.contains('NegotiationError') ||
        errorText.contains('TrackPublishException') ||
        (errorText.contains('addTransceiver') &&
            errorText.contains('track is null')) ||
        _isRealtimeStack(stack);
    FirebaseCrashlytics.instance.recordError(error, stack,
        fatal: !(isVideoError ||
            isVapError ||
            isNetworkError ||
            isRealtimeError));
  });
}

/// Initializes Firebase from the runtime (panel-driven) options when available,
/// otherwise without options so the native config (FCM hybrid) drives it.
///
/// Fallback chain (the fresh -> last-persisted links are resolved inside
/// [FirebaseConfigStore.load]; this is the final neutral link): a non-null
/// [options] is the runtime identity; a null [options] means no runtime config
/// resolved, so we initialize WITHOUT options and let the bundled native
/// google-services.json / GoogleService-Info.plist serve the FCM isolate.
Future<void> _initFirebase(FirebaseOptions? options) {
  if (options != null) {
    return Firebase.initializeApp(options: options);
  }
  Methods.printLog(
      "⚠️ No runtime Firebase config — initializing from native config (FCM hybrid)");
  return Firebase.initializeApp();
}

Future<void> _openHiveBoxes() async {
  await Future.wait([
    HiveManager().openBox(KeysManager.USER_BOX),
    HiveManager().openBox(KeysManager.FRAMES_BOX),
    HiveManager().openBox(KeysManager.AGENCY_BADDES_BOX),
    HiveManager().openBox(KeysManager.WABBLES_BOX),
    HiveManager().openBox(KeysManager.BUBBLE_PADDING_BOX),
    HiveManager().openBox(KeysManager.GAMES_BOX),
    HiveManager().openBox(KeysManager.MUSIC_BOX),
    HiveManager().openBox(KeysManager.ROOMS_BOX),
    HiveManager().openBox(KeysManager.ROOM_USERS_BOX),
  ]);
  Methods.printLog("✅ Hive boxes opened");
}

void _setupPipListener() {
  const MethodChannel('pip_state_channel').setMethodCallHandler((call) async {
    try {
      if (call.method == 'enteredPiP') {
        isInPip.value = true;
        // Forward the OS PiP transition to the live kit. Only the active room's
        // static controller is non-null, so this is a no-op in audio rooms.
        live.UTDRoomController.activeController?.pip.setInPip(true);
        if (di.isRegistered<RoomStateManager>()) {
          di<RoomStateManager>().onPiPEntered();
        }
      } else if (call.method == 'exitedPiP') {
        isInPip.value = false;
        live.UTDRoomController.activeController?.pip.setInPip(false);
        if (di.isRegistered<RoomStateManager>()) {
          di<RoomStateManager>().onPiPExited();
        }
      }
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack);
    }
  });
}

// Allowlist محدّد: نكتم فقط التواقيع المزعجة المعروفة (مثل ارتداد flutter_vap)
// وأي خطأ آخر يرجّع false ليُسجَّل — حتى لا نبتلع كرّاشات zego/dio/hive الحقيقية.
const List<String> _noisyPackageSignatures = <String>[
  'package:flutter_vap2/',
  'Reply already submitted',
  'DartMessenger',
];

// ارتداد tap-to-focus بتاع livekit_client (unawaited Helper.setFocusPoint/
// setExposurePoint من VideoTrackRenderer): أجهزة معينة بترمي PlatformException
// بـ NPE على DeviceOrientation.ordinal() جوه native flutter_webrtc. الفوكس
// ميزة تجميلية والفشل بلا أي أثر — نكتمها بالكامل. الجذر يتصلح في فورك
// flutter_webrtc (null-guard على getDeviceOrientation) مع نسخة Play القادمة.
const List<String> _cameraFocusNoiseSignatures = <String>[
  'DeviceOrientation.ordinal',
  'setFocusPoint',
  'setExposurePoint',
];

bool _isCameraFocusNoise(String errorText) {
  if (!errorText.contains('PlatformException')) return false;
  for (final signature in _cameraFocusNoiseSignatures) {
    if (errorText.contains(signature)) return true;
  }
  return false;
}

bool _isPackageError(StackTrace? stack) {
  if (stack == null) return false;
  final frames = stack.toString();
  for (final signature in _noisyPackageSignatures) {
    if (frames.contains(signature)) return true;
  }
  return false;
}

// تواقيع المحرك اللحظي (LiveKit / UTD Stream / UTD Audio Room Kit). أي استثناء
// منها = مشكلة سيرفر البث (مهلة/تفاوض/نشر تراك)، نسجّله non-fatal لأنه ليس كراش
// في كودنا ولا نقدر نعدّل الباكدج. الجذر السيرفري (UTD Stream) خارج النطاق.
const List<String> _realtimeStackSignatures = <String>[
  'package:livekit_client/',
  'package:utd_audio_room_kit/',
];

const List<String> _realtimeMessageSignatures = <String>[
  'LiveKit',
  'NegotiationError',
  'TrackPublishException',
  'RTCPeerConnection::addTransceiver',
  // مهلات الإشارة/التفاوض داخل livekit_client: في بناء release المعتّم
  // الـ stack بيكون عناوين خام فمطابقة 'package:livekit_client/' بتفشل —
  // المطابقة بالرسالة هي المسار الموثوق. SDK بيعيد الاتصال بنفسه (signal
  // reconnect + UTDReconnectionHandler) فدي أعطال شبكة ناجية مش كراشات.
  'Signal timeout',
  'waitFor',
  'MediaConnectException',
  'ConnectException',
  // وصول لمشارك بعد ما الـ SDK عمله dispose أثناء الخروج/التفكيك.
  'Participant disposed',
  'Room disposed',
];

bool _isRealtimeStack(StackTrace? stack) {
  if (stack == null) return false;
  final frames = stack.toString();
  for (final signature in _realtimeStackSignatures) {
    if (frames.contains(signature)) return true;
  }
  return false;
}

bool _isRealtimeMessage(String message) {
  for (final signature in _realtimeMessageSignatures) {
    if (message.contains(signature)) return true;
  }
  return false;
}
