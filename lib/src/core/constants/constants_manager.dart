import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/setting/setting.dart';

class ConstantsManager {
  const ConstantsManager._();

  /// Max characters per chat text message (DM and group). Single source of
  /// truth so both composers enforce the same cap.
  static const int maxMessageLength = 3000;

  static bool isVariantBuildA = false;
  static bool isVariantBuildB = false;

  /// Maps deployed legacy UI-variant values to their de-branded equivalents so
  /// a client that already cached/sends the old value renders the same shell.
  ///   'new_theme' -> 'theme_1'   (was isNewThemeEnabled)
  ///   'jo_live'   -> 'theme_2'   (legacy theme-2 alias)
  static const Map<String, String> _uiVariantAliases = {
    'new_theme': 'theme_1',
    'jo_live': 'theme_2',
  };

  /// Normalizes any raw UI-variant value (from backend config or Hive cache)
  /// to the canonical de-branded value. Empty/null -> 'default'; legacy aliases
  /// are remapped; anything else passes through unchanged.
  static String normalizeUiVariant(String? raw) {
    final v = (raw ?? '').trim();
    if (v.isEmpty) return 'default';
    return _uiVariantAliases[v] ?? v;
  }

  /// Runtime-selectable UI variant — single source of truth, set from the
  /// admin control panel via the backend config (key: app_ui_variant).
  /// Values: 'default' (Normal), 'theme_2', 'theme_1'. Defaults to Normal.
  ///
  /// Backed by [appUiVariantNotifier] so a runtime change (panel switch picked
  /// up by a config reload) can drive a live re-render / re-navigation instead
  /// of only taking effect on the next cold launch.
  static String _appUiVariant = 'default';

  static String get appUiVariant => _appUiVariant;

  static set appUiVariant(String value) {
    if (_appUiVariant == value) return;
    _appUiVariant = value;
    appUiVariantNotifier.value = value;
  }

  /// Notifies listeners when the UI variant actually changes. Used by the
  /// layout shell to re-navigate so the correct screens render live.
  static final ValueNotifier<String> appUiVariantNotifier =
  ValueNotifier('default');

  static bool get isTheme2 => appUiVariant == 'theme_2';

  /// الـ versionCode الفعلي للبناء — بيتقري أوتوماتيك في main() من PackageInfo.buildNumber.
  /// ده اللي بيتبعت للسيرفر لفحص التحديث الإجباري، فيمنع أي لخبطة بين رقم الكود ورقم البناء.
  /// default = الـ versionCode الحالي كـ fallback آمن لو القراءة فشلت.
  static int appVersionCode = 20;

  /// الـ versionName الفعلي للبناء (مثل "1.0.17") — بيتقري أوتوماتيك في main() من PackageInfo.version.
  /// بيتبعت للسيرفر كـ version_name للعرض في الأدمن فقط؛ المقارنة الداخلية تظل بالـ appVersionCode.
  /// default = الـ versionName الحالي كـ fallback آمن لو القراءة فشلت.
  static String appVersionName = "1.0.18";

  /// اسم التطبيق المعروض — بيتقري أوتوماتيك في main() من PackageInfo.appName
  /// (المصدر native: android:label / CFBundleDisplayName). يُستخدم كعنوان شاشة
  /// المحادثات بدل نص ثابت، فيشتغل على أي flavor بلا hard-code. fallback آمن لو القراءة فشلت.
  ///
  /// White-label: القيمة الحية تأتي من native app label (لكل flavor)؛ هذا مجرد
  /// احتياطي محايد لا يُثبّت اسم عميل بعينه، وقابل للضبط لكل بناء:
  ///   flutter build ... --dart-define=APP_BRAND_NAME=<Brand>
  static String appDisplayName =
  const String.fromEnvironment('APP_BRAND_NAME', defaultValue: 'Live');

  // theme_1 + default → OLD rank UI; theme_2 + theme_3 → new unified rank UI
  // (6 sections incl. lucky + 4 periods incl. hourly). BOTH read the same Redis ZSET
  // data (data is shape-independent). Owner mapping 2026-06-19.
  static bool get isOldRankingUI =>
      appUiVariant == 'default' || appUiVariant == 'theme_1';
  static List<int> activeModes = [];
  static bool isShowRoomBoom = true;

  /// app-check's `room_boom.cache_assets`: the panel published new boom art and
  /// this handset's cached theme is behind. Consumed at room entry (where the
  /// theme is fetched) rather than on cold start, so the lazy-fetch design is
  /// kept -- it only decides whether that fetch may use the Hive copy.
  static bool isBoomThemeStale = false;
  static bool isHostAgencyVisible = true;
  static bool isReelsVisible = false;
  // True only while the reels tab is the active tab in the main layout.
  // The new layout doesn't drive LayoutBloc, so the reels' own play/pause logic
  // (which used to read LayoutBloc.currentIndex == 1) reads this flag instead —
  // otherwise videos stay paused/frozen because the layout index check is wrong.
  static bool isReelsTabActive = false;
  static bool isSvgaNavBar = true;
  static String devicePlatform = '';
  static bool isColorUpdated = false;
  static bool hasFilter = false;
  static bool isShowCinemaMode = false;
  static bool isShowLive = false;
  static bool isShowPK = false;
  static bool isShowRoomActivity = false;
  static String appURL = '';
  static bool isOptionalUpdate = true;
  static bool get isTheme1 => appUiVariant == 'theme_1';

  /// Temporary back-compat alias for [isTheme1]. Remove after all call sites
  /// migrate to the de-branded getter.
  @Deprecated('Use isTheme1')
  static bool get isNewThemeEnabled => isTheme1;
  static bool isShowMoment = false;
  static TextDirection LTR = TextDirection.ltr;
  static bool isShowIndonesia = false;
  static bool isShowHostLevels = false;
  static bool isShareWithFriends = false;
  static bool isShowGridView = false;

  static bool isAudioRoomsEnabled = false;
  static String homeScreen = '';
  static bool isCharismaBadge = false;

  static final ValueNotifier<int> bodyThemeNotifier = ValueNotifier(0);

  /// Bumped whenever admin colors are (re)applied into [ColorManager] so any
  /// already-mounted widget reading the color statics can rebuild immediately
  /// instead of waiting for a later launch.
  static final ValueNotifier<int> colorsNotifier = ValueNotifier(0);

  static final ValueNotifier<String> iso = ValueNotifier('');
  static final ValueNotifier<double> lat = ValueNotifier(0.0);
  static final ValueNotifier<double> long = ValueNotifier(0.0);

  // Optional: helper methods to update them cleanly
  static void updateLocation({
    required double latitude,
    required double longitude,
    required String isoCode,
  }) {
    // Update latitude
    lat.value = latitude;
    lat.notifyListeners();

    // Update longitude
    long.value = longitude;
    long.notifyListeners();

    // Update isoCode
    iso.value = isoCode;
    iso.notifyListeners();
    DioFactory().refreshHeaders();

    Methods.printLog('[LocationInit] ✅ update location completed.');
  }

  static List<String> settingsTitles = [
    StringManager.aboutUs.tr(),
    StringManager.blockList.tr(),
    StringManager.privacyPolicy.tr(),
    StringManager.vipPrivilege.tr(),
    StringManager.logOut.tr(),
  ];

  static List<String> accountSettingsTitles = [
    StringManager.whatsapp.tr(),
    StringManager.huawei.tr(),
    StringManager.googleAccount.tr(),
    if (Platform.isIOS) StringManager.appleId.tr(),
  ];
  static List<String> accountSettingIcon = [
    AssetsManager.phone,
    AssetsManager.googleIcon,
    AssetsManager.googleIcon,
    if (Platform.isIOS) AssetsManager.appleIcon,
  ];

  static List<Function()> settingsOnTaps = [
        () {
      SafeNavigator.context?.pushNamedRoute(Routes.accountSettingPage);
    },
        () {
      SafeNavigator.context
          ?.pushNamedRoute(Routes.languageScreen, arguments: false);
    },
        () {
      SafeNavigator.context?.pushNamedRoute(Routes.deleteAccountPage);
    },
        () {
      SafeNavigator.context?.pushNamedRoute(Routes.appSettingsScreen);
    }
  ];

  static List<Function()> settingsOnTaps2({BuildContext? context}) => [
        () {
      SafeNavigator.context?.pushNamedRoute(Routes.aboutUsPage);
    },
        () {
      SafeNavigator.context?.pushNamedRoute(Routes.blockListScreen);
    },
        () {
      SafeNavigator.context?.pushNamedRoute(Routes.privacy);
    },
        () {
      SafeNavigator.context?.pushNamedRoute(Routes.privacyScreen);
    },
        () {
      showDialog(
        context: context!,
        builder: (_) => AnimatedDialog(
          title: StringManager.clearCache.tr(),
          description: StringManager.clearCacheDesc.tr(),
          dialogBackgroundColor: ColorManager.white,
          titleColor: ColorManager.black,
          descriptionColor: ColorManager.black.withValues(alpha: 0.65),
          onTap: () async {
            try {
              // Clear image cache
              await DefaultCacheManager().emptyCache();
              PaintingBinding.instance.imageCache.clear();
              PaintingBinding.instance.imageCache.clearLiveImages();
              // Also purge the persistent HTTP response cache
              // (FileCacheStore): DefaultCacheManager only clears images, so
              // without this the user-facing "Clear cache" left cached
              // catalog/bootstrap GET bodies on disk.
              await DioFactory.clearHttpCache();

              if (context.mounted) {
                Methods.showToast(context, message: 'Cache cleared');
                Navigator.of(context).pop();
              }
            } catch (e) {
              if (context.mounted) {
                Methods.showToast(context, message: 'Could not clear the cache');
              }
            }
          },
        ),
      );
    },
        () {
      showDialog(
        context: context!,
        builder: (_) => AnimatedDialog(
          title: StringManager.logOut.tr(),
          description: StringManager.logOutDescribe.tr(),
          onTap: () async {
            if (di<RoomStateManager>().isInRoom) {
              // exitRoom() handles all Zego cleanup (leave, uninit, pip)
              // internally -- no manual uninit needed here.
              await di<RoomStateManager>().exitRoom(context);
              Future.delayed(const Duration(milliseconds: 300), () {
                di<LogOutBloc>().add(const LogOutEvent());
              });
            } else {
              di<LogOutBloc>().add(const LogOutEvent());
            }
          },
        ),
      );
    },
  ];
}