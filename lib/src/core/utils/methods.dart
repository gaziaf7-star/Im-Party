import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:general/src/core/utils/country_codes.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/data/model/wabbles_model.dart';
import 'package:general/src/features/auth/domain/entities/multi_images_entity.dart';
import 'package:general/src/features/auth/domain/entities/user_entity.dart';
import 'package:general/src/features/family/presentation/family_member/bloc/change_user_type/change_user_type_bloc.dart';
import 'package:general/src/features/family/presentation/family_member/bloc/remove_family_user/family_remove_user_bloc.dart';
import 'package:general/src/features/family/presentation/family_screen/bloc/show_family/show_family_bloc.dart';
import 'package:general/src/features/home/data/model/my_rooms_model.dart';
import 'package:general/src/features/room/presentation/gifts/gift.dart';
import 'package:general/src/features/room/room.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:platform_device_id_plus/platform_device_id.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

T parseValue<T>(
    dynamic value,
    T fallback, {
      T Function(dynamic)? customParser,
    }) {
  if (value == null) return fallback;

  try {
    if (value is T) return value;

    if (customParser != null) {
      final parsed = customParser(value);
      return parsed;
    }

    // Primitive types
    if (T == int) {
      return (int.tryParse(value.toString()) ?? fallback) as T;
    } else if (T == double) {
      return (double.tryParse(value.toString()) ?? fallback) as T;
    } else if (T == bool) {
      final str = value.toString().toLowerCase();
      if (str == 'true' || str == '1') return true as T;
      if (str == 'false' || str == '0') return false as T;
      return fallback;
    } else if (T == String) {
      // Return fallback if value is an empty list or empty map
      if ((value is List && value.isEmpty) || (value is Map && value.isEmpty)) {
        return fallback;
      }
      // User-generated strings (names/bios/captions) can arrive with lone
      // UTF-16 surrogates (clients truncating emoji mid-pair), which abort
      // Flutter's native text layout ("string is not well-formed UTF-16") at
      // EVERY render site. parseValue<String> is the single choke point all
      // API-sourced strings pass through, so strip them here once; clean
      // strings are returned as-is with zero allocation.
      return value.toString().sanitizedForDisplay as T;
    }

    final jsonString = value is String ? value : jsonEncode(value);
    final decoded = jsonDecode(jsonString);

    if (T.toString() == 'List<String>') {
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList() as T;
      }
    } else if (T.toString() == 'List<int>') {
      if (decoded is List) {
        return decoded.map((e) => int.tryParse(e.toString()) ?? 0).toList()
        as T;
      }
    } else if (T.toString() == 'List<double>') {
      if (decoded is List) {
        return decoded.map((e) => double.tryParse(e.toString()) ?? 0.0).toList()
        as T;
      }
    } else if (T.toString() == 'List<bool>') {
      if (decoded is List) {
        return decoded.map((e) => e.toString().toLowerCase() == 'true').toList()
        as T;
      }
    } else if (T.toString() == 'Map<String, dynamic>') {
      if (decoded is Map<String, dynamic>) return decoded as T;
      if (decoded is Map) {
        return decoded.map((key, val) => MapEntry(key.toString(), val)) as T;
      }
    } else if (T.toString() == 'List<Map<String, dynamic>>') {
      if (decoded is Map) {
        return [decoded.map((k, v) => MapEntry(k.toString(), v))] as T;
      }
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
            .toList() as T;
      }
    }

    // Custom List<TModel> handling
    if (T.toString().startsWith('List<') &&
        T.toString() != 'List<String>' &&
        T.toString() != 'List<int>' &&
        T.toString() != 'List<double>' &&
        T.toString() != 'List<bool>' &&
        T.toString() != 'List<Map<String, dynamic>>') {
      // ✅ Log for List<UserChatModel>
      if (T.toString() == 'List<UserChatModel>') {
        log('parseValue<$T>: Detected List<UserChatModel>');
      }

      if (customParser != null && decoded is List) {
        final list = decoded.map((e) => customParser(e)).toList();
        return list as T;
      }
    }
  } catch (e, s) {
    log('parseValue<$T> error: $e\n$s');
  }

  log('parseValue<$T> fallback: got ${value.runtimeType}, expected $T');
  return fallback;
}

class Methods {
  static final Methods _instance = Methods._internal();

  Methods._internal();

  factory Methods() => _instance;

  static void printLog(String message, {String name = ''}) {
    if (kDebugMode) log(message, name: name);
  }

  /// Records a caught, survivable error to Crashlytics as NON-fatal.
  /// Use for realtime/media-engine exceptions (LiveKit / UTD Stream / mic
  /// publish) and other recoverable failures that we handle gracefully — they
  /// must be observable without polluting the crash-free rate. Never throws.
  static void recordNonFatal(Object error, StackTrace stack, {String? reason}) {
    printLog('⚠️ Non-fatal: ${reason ?? ''} $error');
    try {
      FirebaseCrashlytics.instance
          .recordError(error, stack, reason: reason, fatal: false);
    } catch (_) {
      // Crashlytics not ready / disabled — swallow; logging above is enough.
    }
  }

  /// Single chain that serializes every permission prompt in the app.
  static Future<void> _permissionChain = Future<void>.value();

  /// Central permission requester — the ONLY way the app may call
  /// `.request()`.
  ///
  /// permission_handler's platform side handles a single in-flight request; a
  /// second concurrent `.request()` (e.g. the tools dialog asking for audio
  /// while the live flow asks for camera/mic) throws
  /// `PlatformException(PermissionHandler.PermissionManager, A request for
  /// permissions is already running...)`. Serializing all requests through one
  /// Future chain removes the race, and any residual platform failure is
  /// recorded non-fatal and degraded to the permission's current status
  /// instead of crashing. Never throws.
  static Future<PermissionStatus> requestPermission(Permission permission) {
    final completer = Completer<PermissionStatus>();
    _permissionChain = _permissionChain.then((_) async {
      PermissionStatus result;
      try {
        result = await permission.request();
      } catch (e, s) {
        recordNonFatal(e, s,
            reason: 'Permission.request($permission) failed — '
                'falling back to current status');
        try {
          result = await permission.status;
        } catch (_) {
          result = PermissionStatus.denied;
        }
      }
      completer.complete(result);
    });
    return completer.future;
  }

  /// Formats a number to a compact string like TikTok style.
  /// e.g. 999 → "999", 1500 → "1.5K", 1000000 → "1M", 2500000000 → "2.5B"
  static String formatCount(int? value) {
    if (value == null) return '0';
    if (value < 1000) return value.toString();
    if (value < 1000000) {
      final result = value / 1000.0;
      return '${result % 1 == 0 ? result.toInt() : result.toStringAsFixed(1)}K';
    }
    if (value < 1000000000) {
      final result = value / 1000000.0;
      return '${result % 1 == 0 ? result.toInt() : result.toStringAsFixed(1)}M';
    }
    final result = value / 1000000000.0;
    return '${result % 1 == 0 ? result.toInt() : result.toStringAsFixed(1)}B';
  }

  String durationToString(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

  Duration stringToDuration(String durationString) {
    final parts = durationString.split(':').map(int.parse).toList();
    if (parts.length == 3) {
      return Duration(hours: parts[0], minutes: parts[1], seconds: parts[2]);
    } else if (parts.length == 2) {
      return Duration(minutes: parts[0], seconds: parts[1]);
    } else {
      return Duration.zero;
    }
  }

  static bool isValidHexColor(String? color) {
    final hexColorRegex = RegExp(r'^#?([0-9a-fA-F]{6}|[0-9a-fA-F]{8})$');
    return color != null &&
        color.isNotEmpty &&
        !color.toLowerCase().contains("default") &&
        hexColorRegex.hasMatch(color);
  }

  static Future<void> applyColorIfValid({
    required String? colorValue,
    required void Function(Color) applyColor,
    required String hiveKey,
  }) async {
    final color = safeHexColor(colorValue);
    if (color != null) {
      applyColor(color);
      await HiveManager().saveData(KeysManager.USER_BOX, hiveKey, colorValue);
    }
  }

  static String convertSecondsToMinutesAndSeconds(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '$minutes:$seconds';
  }

  static bool isMe(String id) {
    return MyDataModel.getInstance().id.toString() == id;
  }

  static bool isVideoFile(String path) {
    final videoExtensions = [
      '.mp4',
      '.mov',
      '.avi',
      '.wmv',
      '.flv',
      '.mkv',
      '.webm',
      '.3gp',
      '.mpeg'
    ];

    final extension = path.toLowerCase().split('.').last;
    return videoExtensions.any((ext) => ext.replaceFirst('.', '') == extension);
  }

  Future<int?> getsLastTimeCache(TypesCache typesCache) async {
    if (!Hive.isBoxOpen(KeysManager.Last_Time_Cache_Box)) {
      try {
        await Hive.openBox(KeysManager.Last_Time_Cache_Box);
      } catch (e) {
        // Handle error opening box
        return null;
      }
    }

    final box = Hive.box(KeysManager.Last_Time_Cache_Box);

    switch (typesCache) {
      case TypesCache.wabbles:
        return box.get(StringManager.lastTimeWabbles) as int?;
      case TypesCache.bubble:
        return box.get(StringManager.lastTimeBubbles) as int?;
      case TypesCache.badges:
        return box.get(StringManager.lastTimeAgencyBadges) as int?;
      case TypesCache.gift:
        return box.get(StringManager.lastTimeCacheGift) as int?;
      case TypesCache.frame:
        return box.get(StringManager.lastTimeCacheFrame) as int?;
      case TypesCache.intro:
        return box.get(StringManager.lastTimeCacheEntro) as int?;
      case TypesCache.extra:
        return box.get(StringManager.lastTimeCacheExtra) as int?;
      case TypesCache.emojie:
        return box.get(StringManager.lastTimeCacheEmojie) as int?;
      case TypesCache.banner:
        return box.get(StringManager.lastTimeCacheBanner) as int?;
      case TypesCache.games:
        return box.get(StringManager.lastTimeCacheGames) as int?;
      case TypesCache.color:
        return box.get(StringManager.lastTimeCacheColors) as int?;
      case TypesCache.boom:
        return box.get(StringManager.lastTimeCacheSuperBoomVideos) as int?;
      case TypesCache.boomTheme:
        return box.get(StringManager.lastTimeCacheBoomTheme) as int?;
    }
  }

  Future<void> saveCurrentUtcTimeToCache(TypesCache typesCache) async {
    final box = Hive.box(KeysManager.Last_Time_Cache_Box);
    final currentUtcTimestamp =
        DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

    switch (typesCache) {
      case TypesCache.wabbles:
        await box.put(StringManager.lastTimeWabbles, currentUtcTimestamp);
        break;
      case TypesCache.bubble:
        await box.put(StringManager.lastTimeBubbles, currentUtcTimestamp);
        break;
      case TypesCache.badges:
        await box.put(StringManager.lastTimeAgencyBadges, currentUtcTimestamp);
        break;
      case TypesCache.gift:
        await box.put(StringManager.lastTimeCacheGift, currentUtcTimestamp);
        break;
      case TypesCache.frame:
        await box.put(StringManager.lastTimeCacheFrame, currentUtcTimestamp);
        break;
      case TypesCache.intro:
        await box.put(StringManager.lastTimeCacheEntro, currentUtcTimestamp);
        break;
      case TypesCache.extra:
        await box.put(StringManager.lastTimeCacheExtra, currentUtcTimestamp);
        break;
      case TypesCache.emojie:
        await box.put(StringManager.lastTimeCacheEmojie, currentUtcTimestamp);
        break;
      case TypesCache.banner:
        await box.put(StringManager.lastTimeCacheBanner, currentUtcTimestamp);
        break;
      case TypesCache.games:
        await box.put(StringManager.lastTimeCacheGames, currentUtcTimestamp);
        break;
      case TypesCache.boom:
        await box.put(
            StringManager.lastTimeCacheSuperBoomVideos, currentUtcTimestamp);
        break;
      case TypesCache.color:
        await box.put(StringManager.lastTimeCacheColors, currentUtcTimestamp);
        break;
      case TypesCache.boomTheme:
        await box.put(
            StringManager.lastTimeCacheBoomTheme, currentUtcTimestamp);
        break;
    }
  }

  static String formatCompactNumber(num number) {
    String format(double n, String suffix) {
      final value = n.toStringAsFixed(1);
      return value.endsWith('.0')
          ? '${value.substring(0, value.length - 2)}$suffix'
          : '$value$suffix';
    }

    if (number >= 1000000000000) {
      return format(number / 1000000000000, 'T');
    } else if (number >= 1000000000) {
      return format(number / 1000000000, 'B');
    } else if (number >= 1000000) {
      return format(number / 1000000, 'M');
    } else if (number >= 1000) {
      return format(number / 1000, 'K');
    } else {
      return number.toString();
    }
  }

  static Future<void> setDataRooms({
    required Map<String, dynamic> data,
    required String id,
  }) async {
    final hive = HiveManager();

    await hive.saveData<Map<String, dynamic>>(
      KeysManager.ROOMS_BOX,
      id,
      data,
    );
  }

  static String formatDate(String dateString, {String locale = 'en'}) {
    final DateTime dateTime = DateTime.parse(dateString);
    final DateFormat formatter = DateFormat('MMMM d, y', locale);
    return formatter.format(dateTime);
  }

  static String timeAgo(DateTime dateTime) {
    final Duration difference = DateTime.now().difference(dateTime);
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else {
      return '${(difference.inDays / 365).floor()} years ago';
    }
  }

  static String formatTime(String dateStr) {
    if (dateStr.trim().isEmpty) return '';

    String languageCode = HiveManager()
        .getData<String>(KeysManager.USER_BOX, KeysManager.LANG_CODE_KEY) ??
        'en';

    try {
      DateTime date;
      String trimmed = dateStr.trim();

      if (trimmed.contains('AM') || trimmed.contains('PM')) {
        date = DateTime.tryParse(trimmed) ??
            DateFormat('yyyy-MM-dd hh:mm:ss a', 'en_US').parse(trimmed);
      } else {
        date = DateFormat('yyyy-MM-dd HH:mm:ss').parse(trimmed);
      }

      // Convert UTC to local time
      if (!date.isUtc) {
        date = DateTime.utc(date.year, date.month, date.day, date.hour,
            date.minute, date.second);
      }
      date = date.toLocal();

      if (languageCode == 'ar') {
        return DateFormat('yyyy-MM-dd hh:mm a', 'ar').format(date);
      } else {
        return DateFormat('yyyy-MM-dd hh:mm a', 'en').format(date);
      }
    } catch (_) {
      return dateStr;
    }
  }

  /// Converts a UTC date string to local time and formats it.
  /// Used for displaying `created_at` from API/legacy realtime events.
  static String utcToLocal(String dateStr, {String format = 'hh:mm:ss a'}) {
    if (dateStr.trim().isEmpty) return '';

    String languageCode = HiveManager()
        .getData<String>(KeysManager.USER_BOX, KeysManager.LANG_CODE_KEY) ??
        'en';

    try {
      String trimmed = dateStr.trim();

      // Idempotency guard: an already-formatted local time-of-day (no date part,
      // e.g. "02:30:45 PM") has been converted before. Re-running toLocal would
      // shift it by the device offset again, so return it untouched.
      final bool hasDatePart =
          RegExp(r'\d{4}').hasMatch(trimmed) || trimmed.contains('-');
      if (!hasDatePart) return trimmed;

      DateTime date;

      if (trimmed.contains('AM') || trimmed.contains('PM')) {
        date = DateTime.tryParse(trimmed) ??
            DateFormat('yyyy-MM-dd hh:mm:ss a', 'en_US').parse(trimmed);
      } else {
        date = DateTime.tryParse(trimmed) ??
            DateFormat('yyyy-MM-dd HH:mm:ss').parse(trimmed);
      }

      // Treat as UTC and convert to local
      if (!date.isUtc) {
        date = DateTime.utc(date.year, date.month, date.day, date.hour,
            date.minute, date.second);
      }
      date = date.toLocal();

      return DateFormat(format, languageCode).format(date);
    } catch (_) {
      return dateStr;
    }
  }

  static isCheckInternet() async {
    try {
      var result = await InternetAddress.lookup("google.com");
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
  }

  static Map<String, dynamic> fetchRoom({required String id}) {
    final hive = HiveManager();

    final rawData = hive.getData<Map>(KeysManager.ROOMS_BOX, id);

    if (rawData == null) return {};

    return rawData.map((key, value) => MapEntry(key.toString(), value));
  }

  static bool _isPickerActive = false;

  /// Guarded image picker. The native image_picker plugin throws
  /// PlatformException(already_active) when [pickImage] is invoked while a
  /// previous pick is still in flight (rapid double taps). This serializes
  /// access so a second concurrent call returns null instead of crashing.
  static Future<XFile?> pickImageSafely(
      ImagePicker picker, {
        required ImageSource source,
        int? imageQuality,
      }) async {
    if (_isPickerActive) return null;
    _isPickerActive = true;
    try {
      return await picker.pickImage(source: source, imageQuality: imageQuality);
    } on PlatformException catch (e) {
      // A platform-side picker is already open (e.g. double tap raced the
      // flag, or a non-guarded native sheet): ignore instead of crashing.
      if (e.code == 'already_active') return null;
      rethrow;
    } finally {
      _isPickerActive = false;
    }
  }

  Future<XFile> compressFile({
    required XFile? xFile,
    int quality = 70,
  }) async {
    if (xFile == null) throw Exception("File is null");

    final originalPath = xFile.path;
    final file = File(originalPath);

    log("image before compressed -----> ${(file.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB");

    final dir = await getTemporaryDirectory();

    final targetPath = path.join(
      dir.path,
      "compressed_${path.basenameWithoutExtension(originalPath)}.jpg",
    );

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      originalPath,
      targetPath,
      quality: quality,
      format: CompressFormat.jpeg,
    );

    if (compressedFile == null) throw Exception("Compression failed");

    log("image after compressed ------> ${(File(compressedFile.path).lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB");

    return XFile(compressedFile.path);
  }

  String formatDateTime({
    required String dateTime,
    String format = 'E, d MMM yyyy HH:mm',
    String locale = 'ar',
  }) {
    if (dateTime.isEmpty) {
      return '';
    }

    try {
      String normalizedDateTime = dateTime.replaceAll('-', '/');

      DateTime parsedDateTime = DateFormat('dd/MM/yyyy HH:mm:ss')
          .parse(normalizedDateTime, true)
          .toLocal();

      DateFormat formatter = DateFormat(format, locale);
      return formatter.format(parsedDateTime);
    } catch (e) {
      return '';
    }
  }

  Future<String> getCurrentTimeZone() async {
    DateTime dateTimeNow = DateTime.now();
    return dateTimeNow.timeZoneName;
  }

  static void showToast(
      BuildContext? context, {
        String message = '',
        bool isError = false,
        bool isLoading = false,
      }) {
    if (context == null) return;
    // A deactivated/unmounted context (toast fired from an async gap after
    // the page closed) made the ancestor lookup below throw — top Crashlytics
    // issue a0bf7f78 (39 events / 15 users in 24h).
    if (!context.mounted) return;
    final navigator = Navigator.maybeOf(context);
    if (navigator == null) return;

    final overlayState = navigator.overlay;
    if (overlayState == null) return;

    final animationController = AnimationController(
      vsync: overlayState,
      duration: const Duration(milliseconds: 300),
    );

    final fadeAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    );

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 100.0.h,
        left: 50.w,
        right: 50.w,
        child: Align(
          alignment: AlignmentDirectional.topCenter,
          child: Material(
            color: ColorManager.transparent,
            borderRadius: MediaQuery.sizeOf(context).width.radius,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: IntrinsicWidth(
                // Loading state: request was JUST the spinner, no "please
                // wait" pill/text/background around it (was the same black
                // rounded pill + "please wait" label used for every other
                // toast). Non-loading toasts (success/error message) are
                // completely unchanged below.
                child: isLoading
                // No black pill/background behind it any more (that was
                // sized around the "please wait" text) — plain white
                // would be invisible with nothing behind it, so this
                // keeps the app's own brand purple instead of relying on
                // a backdrop for contrast.
                    ? const Padding(
                  padding: EdgeInsets.zero,
                  child: LoadingWidget(color: Color(0xFF8D4AF4)),
                )
                    : Container(
                  padding: context.paddingSymmetric(
                      vertical: 7.5, horizontal: 15),
                  decoration: BoxDecoration(
                    color: isError
                        ? ColorManager.redAccount
                        : const Color(0xFF43A047),
                    borderRadius: MediaQuery.sizeOf(context).width.radius,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        AssetsManager.logo,
                        height: 30.h,
                        width: 30.w,
                      ),
                      10.wBox,
                      Expanded(
                        child: TextWidget(
                          message,
                          textAlign: TextAlign.center,
                          maxLines: 10,
                          overflow: TextOverflow.ellipsis,
                          style: context.bodyMedium
                              .colorExt(ColorManager.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    var controllerDisposed = false;

    void insertToast() {
      if (!overlayState.mounted) {
        animationController.dispose();
        return;
      }
      try {
        overlayState.insert(overlayEntry);
      } catch (e) {
        animationController.dispose();
        return;
      }
      animationController.forward();

      Future.delayed(const Duration(seconds: 2), () {
        try {
          if (!controllerDisposed) {
            animationController.reverse().then((_) {
              try {
                overlayEntry.remove();
              } catch (e) {
                // overlay already removed
              }
              controllerDisposed = true;
              animationController.dispose();
            });
          }
        } catch (e) {
          // controller already disposed or overlay removed
        }
      });
    }

    // Inserting an overlay entry mid-build/layout throws. Defer to the end of
    // the current frame instead of crashing (or silently losing the toast).
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => insertToast());
    } else {
      insertToast();
    }
  }

  /// Shows a toast through the global [navKey] without ever throwing.
  ///
  /// During app init / disposal / cold-start deep links the navigator may not
  /// be attached yet, so `navKey.currentContext` can be null. Reading it via
  /// `?.` and no-oping keeps callers crash-free instead of force-unwrapping a
  /// null context. The underlying [showToast] is itself null-safe.
  static void safeShowToast({
    String message = '',
    bool isError = false,
    bool isLoading = false,
  }) {
    showToast(
      navKey.currentContext,
      message: message,
      isError: isError,
      isLoading: isLoading,
    );
  }

  String formatTimestampWithoutSeconds(String? timestamp) {
    if (timestamp == '') {
      return '';
    } else if (timestamp != null) {
      DateTime dateTime = DateTime.parse(timestamp);
      String formattedDate =
          "${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}";
      String formattedTime =
          "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
      return "$formattedDate $formattedTime";
    } else {
      return '';
    }
  }

  String formatMomentPostedDateTime(String dateTimeStr) {
    DateTime now = DateTime.now();
    DateTime dateTime = DateTime.parse(dateTimeStr);
    Duration difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm', 'en_US').format(dateTime);
    } else if (dateTime.year == now.year) {
      return DateFormat('MM-dd HH:mm', 'en_US').format(dateTime);
    } else {
      return DateFormat('yyyy-MM-dd HH:mm', 'en_US').format(dateTime);
    }
  }

  void userProfileNavigator({
    required BuildContext context,
    String? userId,
    UserEntity? user_,
    bool isPushAndRemoveUntil = false,
    bool comesFromRoom = false,
  }) {
    if (userId == null && user_ == null) {
      if (isPushAndRemoveUntil) {
        Navigator.popAndPushNamed(
          context,
          Routes.userProfile,
          arguments: UserProfileParameter(
            comesFromRoom: comesFromRoom,
          ),
        );
      } else {
        Navigator.pushNamed(
          context,
          Routes.userProfile,
          arguments: UserProfileParameter(
            comesFromRoom: comesFromRoom,
          ),
        );
      }
    } else if (userId == MyDataModel.getInstance().id.toString()) {
      if (isPushAndRemoveUntil) {
        Navigator.pushReplacementNamed(
          context,
          Routes.userProfile,
          arguments: UserProfileParameter(
            comesFromRoom: comesFromRoom,
            userData: MyDataModel.getInstance()
                .convertMyDataEntityToUserEntity(MyDataModel.getInstance()),
          ),
        );
      } else {
        Navigator.pushNamed(
          context,
          Routes.userProfile,
          arguments: UserProfileParameter(
            comesFromRoom: comesFromRoom,
            userData: MyDataModel.getInstance()
                .convertMyDataEntityToUserEntity(MyDataModel.getInstance()),
          ),
        );
      }
    } else if (userId != null) {
      if (isPushAndRemoveUntil) {
        Navigator.pushReplacementNamed(context, Routes.userProfile,
            arguments: UserProfileParameter(
              comesFromRoom: comesFromRoom,
              userId: userId,
            ));
      } else {
        Navigator.pushNamed(context, Routes.userProfile,
            arguments: UserProfileParameter(
              comesFromRoom: comesFromRoom,
              userId: userId,
            ));
      }
    } else {
      if (isPushAndRemoveUntil) {
        Navigator.popAndPushNamed(
          context,
          Routes.userProfile,
          arguments: UserProfileParameter(
            comesFromRoom: comesFromRoom,
            userData: user_,
          ),
        );
      } else {
        Navigator.pushNamed(
          context,
          Routes.userProfile,
          arguments: UserProfileParameter(
            comesFromRoom: comesFromRoom,
            userData: user_,
          ),
        );
      }
    }
  }

  static String getLang() {
    return HiveManager()
        .getData<String>(KeysManager.USER_BOX, KeysManager.LANG_CODE_KEY) ??
        'en';
  }

  static bool isUserUnder18(DateTime birthDate) {
    final today = DateTime.now();
    final age = today.year - birthDate.year;
    if (birthDate.month > today.month ||
        (birthDate.month == today.month && birthDate.day > today.day)) {
      return age - 1 < 18;
    }

    return age < 18;
  }

  static showCupertinoDatePicker({
    required BuildContext context,
    DateTime? initialDateTime,
    required ValueChanged<DateTime> onDateTimeChanged,
    void Function()? onConfirm,
    // Opt-in overrides for the header title and wheel text colour (both
    // were always the panel-driven textPrimary/primary tokens). Null
    // (every existing caller) keeps the current look.
    Color? titleColor,
    Color? pickerTextColor,
    // Opt-in override for the Cancel/Confirm button text (was always the
    // theme-adaptive ColorManager.lightDarkText, which can resolve light
    // and go invisible on a caller that force-locks a white sheet, e.g.
    // the registration page). Null keeps every existing caller's look.
    Color? buttonTextColor,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300.h,
        width: ScreenUtil().screenWidth,
        color: ColorManager.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ButtonWidget(
                  title: StringManager.cancel.tr(),
                  fontSize: 14,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  width: ScreenUtil().screenWidth * 0.3,
                  fontWeight: FontWeight.w500,
                  titleColor: buttonTextColor ?? ColorManager.lightDarkText,
                  backgroundColor: ColorManager.transparent,
                ),
                TextWidget(
                  StringManager.modifyBirthday.tr(),
                  style: context.bodyMedium
                      .size(16)
                      .bold
                      .colorExt(titleColor ?? ColorManager.textPrimary),
                ),
                ButtonWidget(
                  title: StringManager.confirm.tr(),
                  fontSize: 14,
                  onPressed: onConfirm ?? () => Navigator.pop(context),
                  width: ScreenUtil().screenWidth * 0.3,
                  fontWeight: FontWeight.w500,
                  titleColor: buttonTextColor ?? ColorManager.lightDarkText,
                  backgroundColor: ColorManager.transparent,
                ),
              ],
            ),
            Expanded(
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: context.titleLarge
                        .colorExt(
                      pickerTextColor ?? ColorManager.primary,
                    )
                        .size(16)
                        .w500,
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDateTime ?? DateTime.now(),
                  onDateTimeChanged: (DateTime value) =>
                      onDateTimeChanged(value),
                ),
              ),
            ),
            20.hBox,
          ],
        ),
      ),
    );
  }

  bool get isLanguageArabic {
    return di<SharedPreferences>().getString("languagne") == "ar";
  }

  void showWaringGifDialog() {
    try {
      final context = navKey.currentContext;
      if (context == null) return;
      showDialog(
        context: context,
        builder: (_) {
          return AnimatedDialog(
            title: StringManager.warningGif.tr(),
            isUpdateDialog: false,
            description: StringManager.subttitelGif.tr(),
            onTap: () {
              if (context.mounted) Navigator.pop(context);
            },
          );
        },
      );
    } catch (_) {}
  }

  Future<String?> initPlatformState() async {
    String? deviceId;
    try {
      deviceId = await PlatformDeviceId.getDeviceId;
    } on PlatformException {
      deviceId = 'failed_to_get_deviceId';
    }

    return deviceId;
  }

  static showCupertinoCountriesPicker({
    required BuildContext context,
    required ValueChanged<int> onChanged,
    required List<Widget> children,
    required bool isFirstOpen,
    bool isPayment = false,
    // Opt-in override for the header title colour (was always the
    // panel-driven textPrimary token). Null (every existing caller) keeps
    // the current look.
    Color? titleColor,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250.h,
        width: ScreenUtil().screenWidth,
        color: ColorManager.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ButtonWidget(
                  title: StringManager.cancel.tr(),
                  fontSize: 14,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  width: ScreenUtil().screenWidth * 0.3,
                  fontWeight: FontWeight.w500,
                  titleColor: ColorManager.lightDarkText,
                  backgroundColor: ColorManager.transparent,
                ),
                TextWidget(
                  isPayment == true
                      ? StringManager.payment.tr()
                      : StringManager.country.tr(),
                  style: context.bodyMedium
                      .size(16)
                      .bold
                      .colorExt(titleColor ?? ColorManager.textPrimary),
                ),
                ButtonWidget(
                  title: StringManager.confirm.tr(),
                  fontSize: 14,
                  onPressed: () {
                    di<EditInformationBloc>().add(
                      const ChangeCountryEvent(),
                    );
                    Navigator.pop(context);
                  },
                  width: ScreenUtil().screenWidth * 0.3,
                  fontWeight: FontWeight.w500,
                  titleColor: ColorManager.lightDarkText,
                  backgroundColor: ColorManager.transparent,
                ),
              ],
            ),
            Expanded(
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle:
                    context.titleLarge.size(16).w500.copyWith(
                      fontFamily: StringManager.fontFamily,
                      color: ColorManager.lightDarkText,
                    ),
                  ),
                ),
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: CupertinoPicker(
                    itemExtent: 40,
                    scrollController: isFirstOpen == true
                        ? FixedExtentScrollController(
                      initialItem: -1,
                    )
                        : null,
                    selectionOverlay:
                    const CupertinoPickerDefaultSelectionOverlay(
                      background: ColorManager.transparent,
                    ),
                    onSelectedItemChanged: onChanged,
                    children: children,
                  ),
                ),
              ),
            ),
            20.hBox,
          ],
        ),
      ),
    );
  }

  static showCupertinoGenderPicker({
    required BuildContext context,
    required ValueChanged<int> onChanged,
    // Opt-in overrides for the header title and Male/Female wheel text
    // colour (both were always the panel-driven textPrimary/primary
    // tokens). Null (every existing caller) keeps the current look.
    Color? titleColor,
    Color? pickerTextColor,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 180.h,
        width: ScreenUtil().screenWidth,
        color: ColorManager.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ButtonWidget(
                  title: StringManager.cancel.tr(),
                  fontSize: 14,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  width: ScreenUtil().screenWidth * 0.3,
                  fontWeight: FontWeight.w500,
                  titleColor: ColorManager.lightDarkText,
                  backgroundColor: ColorManager.transparent,
                ),
                TextWidget(
                  StringManager.modifyGender.tr(),
                  style: context.bodyMedium
                      .size(16)
                      .bold
                      .colorExt(titleColor ?? ColorManager.textPrimary),
                ),
                ButtonWidget(
                  title: StringManager.confirm.tr(),
                  fontSize: 14,
                  onPressed: () {
                    di<EditInformationBloc>().add(
                      const EditInformationEvent(),
                    );
                    Navigator.pop(context);
                  },
                  width: ScreenUtil().screenWidth * 0.3,
                  fontWeight: FontWeight.w500,
                  titleColor: ColorManager.lightDarkText,
                  backgroundColor: ColorManager.transparent,
                ),
              ],
            ),
            Expanded(
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: context.titleLarge.size(16).w500,
                  ),
                ),
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: CupertinoPicker(
                    itemExtent: 40,
                    selectionOverlay:
                    const CupertinoPickerDefaultSelectionOverlay(
                      background: ColorManager.transparent,
                    ),
                    onSelectedItemChanged: onChanged,
                    scrollController: FixedExtentScrollController(
                      initialItem: -1,
                    ),
                    children: [
                      TextWidget(
                        StringManager.male.tr(),
                        style: context.bodyLarge
                            .colorExt(pickerTextColor ?? ColorManager.primary)
                            .size(16),
                      ),
                      TextWidget(
                        StringManager.female.tr(),
                        style: context.bodyLarge
                            .colorExt(pickerTextColor ?? ColorManager.primary)
                            .size(16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            20.hBox,
          ],
        ),
      ),
    );
  }

  static showCupertinoActionPicker({
    required BuildContext context,
    required bool amITheOwner,
    required bool amIAnAdmin,
    required int familyStatus,
    required String userId,
    required String familyId,
  }) {
    final List<String> options = [];

    if (di<ShowFamilyBloc>().state.showFamilyEntity?.amIOwner ?? false) {
      // Owner can remove both admins and members
      if (familyStatus == 1) {
        options.add(StringManager.removeAdmin);
      } else {
        options.add(StringManager.addAdmin);
      }
      options.add(StringManager.deleteMember);
    } else if (di<ShowFamilyBloc>().state.showFamilyEntity?.amIAdmin ?? false) {
      if (MyDataModel.getInstance().id.toString() == userId) {
        options.add(StringManager.removeAdmin);
        options.add(StringManager.deleteMember);
      } else if (familyStatus != 1) {
        options.add(StringManager.deleteMember);
      }
    }

    if (options.isEmpty) {
      return;
    }

    int selectedIndex = 0; // Default to the first item

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250.h,
        width: ScreenUtil().screenWidth,
        color: ColorManager.scaffoldBackgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ButtonWidget(
              title: StringManager.confirm.tr(),
              onPressed: () {
                Navigator.pop(context); // Close the picker
                if (options[selectedIndex] == StringManager.removeAdmin ||
                    options[selectedIndex] == StringManager.addAdmin) {
                  di<ChangeUserTypeBloc>().add(ChangeUserTypeEvent(
                    userId: userId,
                    type: options[selectedIndex] == StringManager.removeAdmin
                        ? '0'
                        : '1',
                    familyId: familyId,
                  ));
                } else if (options[selectedIndex] ==
                    StringManager.deleteMember) {
                  di<FamilyRemoveUserBloc>().add(RemoverFamilyUser(
                    uId: userId,
                    familyId: familyId,
                  ));
                }
              },
              width: ScreenUtil().screenWidth * 0.25,
              titleColor: ColorManager.primary,
              backgroundColor: ColorManager.transparent,
            ),
            Expanded(
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: context.titleLarge.w500.copyWith(
                      fontFamily: StringManager.fontFamily,
                    ),
                  ),
                ),
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: CupertinoPicker(
                    itemExtent: 40,
                    onSelectedItemChanged: (index) {
                      selectedIndex = index;
                    },
                    children: options
                        .map((option) => TextWidget(
                      option,
                      style: context.bodyLarge,
                    ))
                        .toList(),
                  ),
                ),
              ),
            ),
            20.hBox,
          ],
        ),
      ),
    );
  }

  static String formattedTime({required int seconds}) {
    int sec = seconds % 60;
    int min = (seconds / 60).floor();
    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return "$minute : $second";
  }

  static Future<void> saveUserToken({String? token_}) async {
    final hive = HiveManager();
    // Single chokepoint for login / switch-account / register: a NEW session's
    // token is being set here. Purge the persistent HTTP cache so the incoming
    // session never reads catalog/bootstrap entries written under the previous
    // session's token (defense-in-depth alongside the per-user cache key in
    // DioFactory). Done BEFORE writing the new token so the purge runs while the
    // store is still in the old/anon scope; fire-and-forget — never blocks login.
    DioFactory.clearHttpCache();
    if (token_ != null) {
      await hive.saveData<String>(
        KeysManager.USER_BOX,
        KeysManager.TOKEN_KEY,
        token_,
      );
    } else {
      await hive.saveData<String>(
        KeysManager.USER_BOX,
        KeysManager.TOKEN_KEY,
        token_ ?? "",
      );
    }
  }

  static String getUserToken() {
    final hive = HiveManager();
    return hive.getData<String>(KeysManager.USER_BOX, KeysManager.TOKEN_KEY) ??
        "";
  }

  static Future<void> saveUserLoginAccountIdToken({
    required String token,
    required String accountId,
  }) async {
    final rawMap = HiveManager().getData(
      KeysManager.USER_BOX,
      KeysManager.LOGIN_ACCOUNTS_KEY,
      defaultValue: {},
    ) ??
        {};

    final tokensMap = <String, String>{
      for (var entry in rawMap.entries)
        entry.key.toString(): entry.value.toString()
    };

    tokensMap[accountId] = token;

    await HiveManager().saveData(
      KeysManager.USER_BOX,
      KeysManager.LOGIN_ACCOUNTS_KEY,
      tokensMap,
    );
  }

  void showCompleteInfoDialog(BuildContext? context, FetchUserDataState state) {
    if (context == null) return;
    bool isShowDialog = true;

    List<dynamic> userValues = [
      state.userEntity?.name,
      state.userEntity?.country?.name,
      state.userEntity?.profile?.gender,
      state.userEntity?.profile?.image,
      state.userEntity?.profile?.birthday,
      state.userEntity?.bio,
      state.userEntity?.multiImages,
    ];

    int countAvailable(List<dynamic> values) {
      return values.where((value) {
        if (value == null) return false;
        if (value is String && value.trim().isEmpty) return false;
        if (value is List<MultiImagesEntity> && value.isEmpty) return false;
        return true;
      }).length;
    }

    double calculatePercentage(List<dynamic> values, {int total = 7}) {
      int available = countAvailable(values);
      return (available / total) * 100;
    }

    bool shouldShowDialog = calculatePercentage(userValues) < 100;

    if (isShowDialog && shouldShowDialog) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) => AnimatedDialog(
          showIcon: false,
          title: StringManager.completeYourInfoData.tr(),
          description: StringManager.addImageCountry.tr(),
          conText: StringManager.ok.tr(),
          isHideConfirm: false,
          isUpdateDialog: true,
          // White card (was the panel-driven scaffoldBg/surfaceCardColor),
          // light-black description text, and the brand gradient on the
          // confirm button — requested directly for this Home-page dialog
          // specifically; every other AnimatedDialog caller is unaffected.
          dialogBackgroundColor: ColorManager.white,
          descriptionColor: ColorManager.momentPostTextColor,
          titleColor: ColorManager.momentPostTextColor,
          // Fixed light-black — was the panel-driven textPrimary, which could
          // read light on this dialog's now-white card.
          cancelTextColor: ColorManager.momentPostTextColor,
          confirmGradientColors: ColorManager.brandGradientColors,
          onTapCancel: () {
            navKey.currentState?.pop();
            isShowDialog = false;
          },
          onTap: () {
            navKey.currentState?.pop();

            bool isBasicInfoComplete =
                state.userEntity?.name?.toString().trim().isNotEmpty == true &&
                    state.userEntity?.country?.name
                        ?.toString()
                        .trim()
                        .isNotEmpty ==
                        true &&
                    state.userEntity?.profile?.gender
                        ?.toString()
                        .trim()
                        .isNotEmpty ==
                        true &&
                    state.userEntity?.profile?.image
                        ?.toString()
                        .trim()
                        .isNotEmpty ==
                        true &&
                    state.userEntity?.profile?.birthday
                        ?.toString()
                        .trim()
                        .isNotEmpty ==
                        true &&
                    state.userEntity?.bio?.toString().trim().isNotEmpty == true;
            if (isBasicInfoComplete) {
              navKey.currentState?.pushNamed(
                Routes.addMultiPicture,
              );
            } else {
              navKey.currentState?.pushNamed(
                Routes.editProfile,
                arguments: state.userEntity,
              );
            }
            isShowDialog = false;
          },
          child: Padding(
            padding: context.paddingAll(20),
            child: CircularPercentIndicator(
              backgroundColor: ColorManager.levelColor,
              percent: calculatePercentage(userValues) / 100,
              radius: 70.r,
              lineWidth: 14.w,
              animateFromLastPercent: true,
              addAutomaticKeepAlive: true,
              // Matches the dialog's own confirm-button colour (the brand
              // gradient) instead of the flat panel-driven primary colour.
              progressColor: ColorManager.brandGradientColors.last,
              curve: Curves.ease,
              center: TextWidget(
                "${calculatePercentage(userValues).toInt()}%",
                style:
                context.bodyMedium.colorExt(ColorManager.momentPostTextColor),
              ),
            ),
          ),
        ),
      ).then((_) {
        isShowDialog = false;
      });
    }
  }

  bool isValidNumber({required String iso, required String number}) {
    // Find the country in the list
    final country = countryCodes.firstWhere(
          (c) => c['iso2_cc'] == iso.toUpperCase(),
      orElse: () => {},
    );

    if (country.isEmpty) {
      return false;
    }

    if (iso == 'ID') {
      return _validateIndonesianNumber(number, iso);
    }

    final countryCode = country['e164_cc'];
    final example = country['example'];

    // Remove any non-digit characters
    String cleanedNumber = number.replaceAll(RegExp(r'[^0-9]'), '');

    // Case 1: Number includes country code (like +93 or 0093)
    if (cleanedNumber.startsWith(countryCode)) {
      // Remove country code part
      cleanedNumber = cleanedNumber.substring(countryCode.length);
    }
    // Case 2: Number might start with international prefix (like 00)
    else if (cleanedNumber.startsWith('00')) {
      // Remove the 00 prefix
      cleanedNumber = cleanedNumber.substring(2);
      // Then check if the rest starts with country code
      if (cleanedNumber.startsWith(countryCode)) {
        cleanedNumber = cleanedNumber.substring(countryCode.length);
      }
    }

    // Check if the remaining number matches the expected length/pattern
    // This is a basic check - you might need to enhance it based on specific country rules
    if (example != null) {
      // Remove any formatting from the example
      final cleanedExample = example.replaceAll(RegExp(r'[^0-9]'), '');

      // Check if the cleaned number has the same length as the example
      if (cleanedNumber.length != cleanedExample.length) {
        return false;
      }

      // You could add more specific pattern checks here if needed
      // For example, check if it starts with certain digits
    }

    return true;
  }

  bool _validateIndonesianNumber(String number, String countryCode) {
    // Remove international prefixes
    if (number.startsWith('+62')) {
      number = number.substring(3);
    } else if (number.startsWith('0062')) {
      number = number.substring(4);
    } else if (number.startsWith('62')) {
      number = number.substring(2);
    }

    if (number.startsWith('0')) {
      number = number.substring(1);
    }

    if (RegExp(r'^[89]').hasMatch(number)) {
      return number.length >= 9 && number.length <= 11;
    } else {
      return number.length >= 7 && number.length <= 10;
    }
  }

  bool isValidPhoneNumber(String countryCode, String phoneNumber) {
    final Map<String, dynamic> country = countryCodes.firstWhere(
          (c) => c["iso2_cc"] == countryCode,
      orElse: () => <String, dynamic>{},
    );

    if (!country.containsKey("example")) return false;

    String example = country["example"] ?? "";
    if (example.isEmpty) return false;
    if (countryCode == 'ID') {
      return _validateIndonesianNumber(phoneNumber, countryCode);
    }

    String pattern = r'^(?:' +
        country["e164_cc"] +
        r')?' +
        example.replaceAll(RegExp(r'\d'), '\\d') +
        r'$';
    RegExp regex = RegExp(pattern);

    return regex.hasMatch(phoneNumber);
  }

  bool isRtlLanguage(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  void navigatorToUserChat({
    required BuildContext context,
    required UserEntity userEntity,
  }) {
    Navigator.pushNamed(
      context,
      Routes.messages,
      arguments: MessagesParameter(
        name: userEntity.name.toString(),
        image: userEntity.profile?.image ?? "",
        userId: userEntity.id.toString(),
        hasColorName: userEntity.hasColorName ?? false,
      ),
    );
  }

  void isFriends({
    required UserEntity userEntity,
    required BuildContext context,
  }) {
    if (userEntity.isFriend ?? false) {
      navigatorToUserChat(context: context, userEntity: userEntity);
    } else {
      showToast(
        context,
        message: StringManager.youAreNotFriends.tr(),
        isError: true,
      );
    }
  }

  bool isSvgaFile(String filePath) {
    return filePath.toLowerCase().contains('.svga') ||
        filePath.toLowerCase().contains('.zz') ||
        filePath.toLowerCase().contains('.zzz');
  }

  String getAppLanguage(BuildContext context) {
    Locale locale = Localizations.localeOf(context);
    return locale.languageCode;
  }

  WabblesModel? getUserWabble(int id) {
    if (id == -1 ||
        HiveManager().getData(
          KeysManager.WABBLES_BOX,
          KeysManager.WABBLES_KEY,
        ) ==
            null) {
      return null;
    } else {
      for (final item in jsonDecode(HiveManager().getData(
        KeysManager.WABBLES_BOX,
        KeysManager.WABBLES_KEY,
      ))) {
        final wabble = WabblesModel.fromJson(item);
        if (wabble.id == id) {
          return wabble;
        }
      }
    }
    return null;
  }

  String convertNumerals(String input, {bool? toEnglish = false}) {
    const arabicToEnglishDigits = {
      '٠': '0',
      '١': '1',
      '٢': '2',
      '٣': '3',
      '٤': '4',
      '٥': '5',
      '٦': '6',
      '٧': '7',
      '٨': '8',
      '٩': '9'
    };

    const englishToArabicDigits = {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩'
    };

    final mapping =
    (toEnglish ?? false) ? arabicToEnglishDigits : englishToArabicDigits;

    return input.split('').map((char) {
      return mapping[char] ?? char;
    }).join('');
  }

  String convertToAbbreviatedString(dynamic input) {
    num? value;

    // Try parsing if it's a String
    if (input is String) {
      value = num.tryParse(input);
    } else if (input is num) {
      value = input;
    }

    // Default to 0 if parsing fails
    value ??= 0;

    const List<Map<String, dynamic>> abbreviations = [
      {'suffix': 'Q', 'value': 1000000000000000},
      {'suffix': 'T', 'value': 1000000000000},
      {'suffix': 'B', 'value': 1000000000},
      {'suffix': 'M', 'value': 1000000},
      {'suffix': 'K', 'value': 1000},
    ];

    String truncateToDecimalPlaces(num number, int decimalPlaces) {
      final factor = math.pow(10, decimalPlaces);
      final truncated = (number * factor).truncateToDouble() / factor;
      String result = truncated.toStringAsFixed(decimalPlaces);
      return result.contains('.')
          ? result.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '')
          : result;
    }

    for (final abbreviation in abbreviations) {
      final suffix = abbreviation['suffix'];
      final threshold = abbreviation['value'];

      if (value >= threshold) {
        final shortenedValue = value / threshold;
        final decimalPlaces = shortenedValue % 1 == 0 ? 0 : 2;
        final formatted =
        truncateToDecimalPlaces(shortenedValue, decimalPlaces);
        return formatted + suffix;
      }
    }

    return truncateToDecimalPlaces(value, 2);
  }

  int convertFromAbbreviatedString(String value) {
    const Map<String, int> abbreviations = {
      'Q': 1000000000000000, // Quadrillion
      'T': 1000000000000, // Trillion
      'B': 1000000000, // Billion
      'M': 1000000, // Million
      'K': 1000, // Thousand
    };

    final RegExp regex = RegExp(r'^(\d+\.?\d*)([QTBMK]?)$');
    final match = regex.firstMatch(value);

    if (match != null) {
      double number = double.parse(match.group(1)!);
      String suffix = match.group(2)!;

      return (number * (abbreviations[suffix] ?? 1)).toInt();
    }

    return 0; // Return null for invalid inputs
  }

  String getTimeDifference(String dateString) {
    try {
      final DateFormat format = DateFormat("yyyy-MM-dd HH:mm:ss");
      final DateTime inputDate = format.parseUtc(dateString);
      final DateTime now = DateTime.now().toUtc();

      final Duration difference = inputDate.difference(now);

      if (difference.isNegative) {
        return "0m"; // already passed
      }

      final int months = difference.inDays ~/ 30; // rough month calculation
      final int days = difference.inDays % 30;
      final int hours = difference.inHours % 24;
      final int minutes = difference.inMinutes % 60;

      List<String> parts = [];
      if (months > 0) parts.add("${months}m");
      if (days > 0) parts.add("${days}d");
      if (hours > 0) parts.add("${hours}h");
      if (minutes > 0) parts.add("${minutes}m");

      return parts.join(" ");
    } catch (e) {
      return "";
    }
  }

  String timeDifference(String dateString) {
    if (dateString == '') {
      return '';
    }
    // Parse the provided date string
    final DateTime inputDate = DateTime.parse(dateString);

    // Get the current date and time
    final DateTime now = DateTime.now();

    // Calculate the difference between the current time and the provided date
    final Duration difference = now.difference(inputDate);

    // Calculate years, months, and weeks

    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime visitDay =
    DateTime(inputDate.year, inputDate.month, inputDate.day);
    final int daysDiff = today.difference(visitDay).inDays;

    if (daysDiff == 0) {
      if (difference.inHours > 0) {
        return '${difference.inHours} hour(s) ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute(s) ago';
      } else {
        return '${difference.inSeconds} second(s) ago';
      }
    } else if (daysDiff == 1) {
      return 'Yesterday';
    } else {
      return '${inputDate.year}-${inputDate.month}-${inputDate.day}';
    }
  }

  Future<File> getImageFileFromNetwork(String imageUrl) async {
    var response = await Dio()
        .get(imageUrl, options: Options(responseType: ResponseType.bytes));
    final dir = await getTemporaryDirectory();
    var filename = '${dir.path}/image.png';

    final file = File(filename);
    await file.writeAsBytes(response.data);
    return file;
  }

  static bool getOnBoarding() {
    final hive = HiveManager();
    return hive.getData<bool>(
        KeysManager.USER_BOX, KeysManager.IS_SKIPPED_ONBOARDING_KEY) ??
        false;
  }

  static Future<void> saveOnBoarding() async {
    final hive = HiveManager();

    await hive.saveData<bool>(
        KeysManager.USER_BOX, KeysManager.IS_SKIPPED_ONBOARDING_KEY, true);
  }

  static Future<void> saveLanguageScreen() async {
    final hive = HiveManager();

    await hive.saveData<bool>(
        KeysManager.USER_BOX, KeysManager.IS_SKIPPED_LANGUAGE_KEY, true);
  }

  static bool getLanguageScreen() {
    final hive = HiveManager();
    return hive.getData<bool>(
        KeysManager.USER_BOX, KeysManager.IS_SKIPPED_LANGUAGE_KEY) ??
        false;
  }

  /// Whether the app has ever completed a splash navigation before on this
  /// device. False only on the very first launch after install -- used to
  /// send first-time users straight to the Welcome/login page (skipping the
  /// language/onboarding screens entirely) while returning users see the
  /// brief intro banner instead.
  static bool getHasLaunchedBefore() {
    final hive = HiveManager();
    return hive.getData<bool>(
        KeysManager.USER_BOX, KeysManager.HAS_LAUNCHED_BEFORE_KEY) ??
        false;
  }

  static Future<void> saveHasLaunchedBefore() async {
    final hive = HiveManager();
    await hive.saveData<bool>(
        KeysManager.USER_BOX, KeysManager.HAS_LAUNCHED_BEFORE_KEY, true);
  }

  static String? getMicImageOpen() {
    final hive = HiveManager();
    final path = hive.getData<String?>(
        KeysManager.USER_BOX, KeysManager.MIC_IMAGE_OPEN_KEY);
    if (path != null && !File(path).existsSync()) return null;
    return path;
  }

  static String? getMicImageClose() {
    final hive = HiveManager();
    final path = hive.getData<String?>(
        KeysManager.USER_BOX, KeysManager.MIC_IMAGE_CLOSE_KEY);
    if (path != null && !File(path).existsSync()) return null;
    return path;
  }

  static String? getMicImageOpenUrl() {
    final hive = HiveManager();
    return hive.getData<String?>(
        KeysManager.USER_BOX, KeysManager.MIC_IMAGE_OPEN_URL_KEY);
  }

  static String? getMicImageCloseUrl() {
    final hive = HiveManager();
    return hive.getData<String?>(
        KeysManager.USER_BOX, KeysManager.MIC_IMAGE_CLOSE_URL_KEY);
  }

  String formatDuration(String? durationString) {
    if (durationString == null || durationString.isEmpty) {
      return '';
    }

    List<String> parts = durationString.split(':');

    // Handle cases where the format is "H:MM:SS.SSSSSS"
    int minutes, seconds;

    if (parts.length == 3) {
      // If hours exist, ignore them and use minutes/seconds
      minutes = int.tryParse(parts[1]) ?? 0;
      seconds = int.tryParse(parts[2].split('.')[0]) ?? 0;
    } else if (parts.length == 2) {
      // If only minutes and seconds exist
      minutes = int.tryParse(parts[0]) ?? 0;
      seconds = int.tryParse(parts[1].split('.')[0]) ?? 0;
    } else {
      return '00:00';
    }

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String formatDurationFromDouble(double seconds) {
    Duration duration = Duration(seconds: seconds.toInt());
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String secs = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$secs";
  }

  static Future<void> openUrl(String urlLink) async {
    await safeLaunchUrl(urlLink);
  }

  /// Safely launches a URL. Verifies a handler exists and swallows any
  /// PlatformException (e.g. ACTIVITY_NOT_FOUND when no app/browser/mail
  /// client can handle the intent) so a missing handler never crashes the app.
  static Future<bool> safeLaunchUrl(
      String urlLink, {
        LaunchMode mode = LaunchMode.platformDefault,
      }) async {
    try {
      final uri = Uri.parse(urlLink);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: mode);
      }
    } catch (_) {}
    return false;
  }

  /// Registers the current user with Crashlytics so crashes can be traced to a
  /// specific account. Uses the DB id as the identifier and stores the in-app
  /// special_id (the number users actually know) as a searchable custom key.
  static void identifyUserForCrashlytics() {
    try {
      final user = MyDataModel.getInstance();
      final id = user.id;
      if (id == null || id == 0) return;
      FirebaseCrashlytics.instance.setUserIdentifier(id.toString());
      final special = user.specialId;
      if (special != null && special != 0) {
        FirebaseCrashlytics.instance
            .setCustomKey('special_id', special.toString());
      }
    } catch (_) {}
  }

  /// Records a breadcrumb in Crashlytics so the lead-up to a crash can be
  /// reconstructed. Wrapped in try/catch so logging never throws.
  static void logBreadcrumb(String message) {
    try {
      FirebaseCrashlytics.instance.log(message);
    } catch (_) {}
  }

  /// Attaches a searchable custom key/value to Crashlytics reports for extra
  /// context. Wrapped in try/catch so setting context never throws.
  static void setCrashKey(String key, Object? value) {
    try {
      FirebaseCrashlytics.instance.setCustomKey(key, value.toString());
    } catch (_) {}
  }

  Future<Size?> getImageSize(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;

    final completer = Completer<Size>();
    final image = FileImage(file);
    final stream = image.resolve(const ImageConfiguration());

    late ImageStreamListener listener;
    listener = ImageStreamListener((ImageInfo info, bool _) {
      final myImage = info.image;
      final size = Size(myImage.width.toDouble(), myImage.height.toDouble());
      completer.complete(size);
      stream.removeListener(listener);
    }, onError: (dynamic _, __) {
      stream.removeListener(listener);
    });

    stream.addListener(listener);
    return completer.future;
  }

  static Future<String> detectDevicePlatform() async {
    if (Platform.isIOS) {
      return StringManager.ios;
    }

    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final manufacturer = androidInfo.manufacturer.toLowerCase();

      if (manufacturer.contains('huawei')) {
        return StringManager.huawei;
      } else {
        return StringManager.android;
      }
    }

    return StringManager.android;
  }

  /// Parses an admin-supplied hex color safely. Never throws.
  /// Accepts `#RRGGBB`, `RRGGBB`, `#AARRGGBB`, `AARRGGBB`, `0xRRGGBB`,
  /// `0xAARRGGBB` (case-insensitive, surrounding spaces tolerated).
  /// Returns null for empty/invalid input so call sites can fall back to a
  /// sensible default instead of crashing or rendering white on bad data.
  static Color? safeHexColor(String? hexColor) {
    if (hexColor == null) return null;
    var hex = hexColor.trim();
    if (hex.isEmpty) return null;
    if (hex.startsWith('#')) hex = hex.substring(1);
    if (hex.startsWith('0x') || hex.startsWith('0X')) hex = hex.substring(2);
    if (hex.length == 6) hex = 'ff$hex';
    if (hex.length != 8) return null;
    final value = int.tryParse(hex, radix: 16);
    return value == null ? null : Color(value);
  }

  /// Like [safeHexColor] but never returns null: on empty/invalid input it
  /// returns the caller-supplied [fallback]. Use this at the boundary where a
  /// color is required so a blank/bad admin value can never break the UI.
  static Color hexColorOr(String? hexColor, Color fallback) {
    return safeHexColor(hexColor) ?? fallback;
  }

  static String? getCurrentRouteName() {
    final navigatorState = navKey.currentState;

    if (navigatorState == null) return null;

    String? currentRoute;

    navigatorState.popUntil((route) {
      currentRoute = route.settings.name;
      return true;
    });

    return currentRoute;
  }

  Future<void> whatsAppLink(BuildContext context, String url) async {
    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        action: 'action_view',
        data: url,
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );

      try {
        await intent.launch();
      } catch (e) {
        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (_) => AnimatedDialog(
            title: StringManager.warning,
            titleDivider: false,
            isHideConfirm: true,
            isUpdateDialog: true,
            child: Column(
              children: [
                5.hBox,
                const TextWidget(
                  StringManager.whatsAppNotInstalled,
                ),
              ],
            ),
          ),
        );
      }
    } else {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        log("Cannot launch WhatsAppS");
      }
    }
  }

  String generateRandomFileName({String extension = ''}) {
    final random = math.Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomPart = random.nextInt(1000000); // random number up to 6 digits
    return "file_${timestamp}_$randomPart$extension";
  }

  Future<String> signInAnonymously() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.uid.isNotEmpty) {
        return currentUser.uid;
      }
      final params = await FirebaseAuth.instance.signInAnonymously();

      return params.user?.uid ?? '';
    } catch (e, s) {
      Methods.printLog('Error during anonymous sign-in: $e');
      Methods.printLog('Stack trace: $s');
      return '';
    }
  }

  static Future<void> safeSubscribeToTopic() async {
    const String topic = "system_notifications_topic";
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      Methods.printLog('✅ Subscribed to $topic');
    } catch (e) {
      if (e.toString().contains('SERVICE_NOT_AVAILABLE')) {
        Methods.printLog('⚠️ Network issue, will retry later');
        Future.delayed(
            const Duration(seconds: 10), () => safeSubscribeToTopic());
      } else {
        Methods.printLog('❌ Subscription error: $e');
      }
    }
  }

  static Future<String> getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<void> handleRoomEntry(
      BuildContext context, MyRoom? data) async {
    if (HomePage.isConnectToInternet) {
      // Enter the owned room when a real room was passed (the caller already
      // resolved ownership via the owned MyRoom); only fall back to the
      // create-room form when no room exists. The stale MyDataModel.hasRoom
      // flag must NOT gate this — owning an audio/live room is determined by
      // the passed data, not that field.
      if (data?.id != null) {
        // Instant tap feedback — was silent for the full delay below (the
        // room's own navigateToRoom loading toast only fired once that gap
        // ended), which is what made going live into an owned audio room
        // feel slow/unresponsive compared to before.
        if (context.mounted) {
          Methods.showToast(context, isLoading: true);
        }
        // Was 700ms — a leftover tuned for the OLD go-live bottom sheet's
        // close animation. GoLiveFlow's chooser is now a showGeneralDialog
        // with transitionDuration: 200ms (go_live_flow.dart), so 700ms was
        // adding ~half a second of pure dead wait on top of that dialog's
        // own close + the real room-join network time — this was the actual
        // "not fast anymore" the user reported (the loading toast fix above
        // only hid it, it didn't remove it). 220ms gives the dialog's own
        // close animation just enough time to finish cleanly, nothing more.
        Future.delayed(
          const Duration(milliseconds: 220),
              () {
            di<RoomStateManager>().navigateToRoom(
              RoomEntryRequest(
                context: context,
                roomData: RoomEntity(
                  ownerId: MyDataModel.getInstance().id,
                  id: data?.id,
                  name: data?.name,
                  cover: data?.cover,
                  roomBackground: data?.roomBackground,
                  mode: data?.mode.toString(),
                  uuidOwnerRoom: MyDataModel.getInstance().uuid ?? "",
                  giftPrice: data?.giftPrice,
                  ownerSpecialId: MyDataModel.getInstance().specialIdImage,
                  ownerImageColor: MyDataModel.getInstance().imageColorEntity,
                ),
                isLive: false,
              ),
            );
          },
        );
      } else {
        context.pushNamedRoute(Routes.createRoomPage);
      }
    } else {
      Methods.showToast(
        context,
        isError: true,
        message: StringManager.unableToConnect.tr(),
      );
    }
  }

  static String? safeText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return value;
  }

  static String capitalizeFirstLetter(String? text) {
    if (text == null || text.isEmpty) return text ?? "";
    return text[0].toUpperCase() + text.substring(1);
  }

  static List<BoxShadow> shadow(
      BuildContext context,
      ) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1).withValues(alpha: 0.05),
        blurRadius: 3,
        offset: const Offset(0, -1),
        spreadRadius: -2,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1).withValues(alpha: 0.08),
        blurRadius: 5,
        offset: const Offset(0, 2),
        spreadRadius: -1,
      ),
    ];
  }
}

/// Centralized, crash-safe access to the global [navKey].
///
/// The navigator backing [navKey] is null before the first frame is mounted
/// and after the root navigator is torn down. Async callbacks (deep links,
/// realtime events, post-init flows) frequently fire in those windows, so any
/// bare `navKey.currentContext!` / `navKey.currentState!` is a latent crash
/// ("Null check operator used on null value"). Use these helpers — they read
/// the navigator via `?.` and degrade gracefully (no-op / null) when it is not
/// available, instead of throwing.
abstract final class SafeNavigator {
  /// The current root [BuildContext], or null if the navigator is not mounted.
  static BuildContext? get context => navKey.currentState?.context;

  /// The current root [NavigatorState], or null if not mounted.
  static NavigatorState? get state => navKey.currentState;

  /// Pushes a named route if the navigator is available, otherwise no-ops.
  static Future<T?>? pushNamed<T>(String routeName, {Object? arguments}) {
    final nav = navKey.currentState;
    if (nav == null) return null;
    return nav.pushNamed<T>(routeName, arguments: arguments);
  }

  /// Pops the top route if the navigator is available and can pop.
  static void pop<T>([T? result]) {
    final nav = navKey.currentState;
    if (nav == null || !nav.canPop()) return;
    nav.pop<T>(result);
  }

  /// Runs [action] with the current root context only if it is available.
  static void withContext(void Function(BuildContext context) action) {
    final ctx = navKey.currentState?.context;
    if (ctx == null) return;
    action(ctx);
  }
}
