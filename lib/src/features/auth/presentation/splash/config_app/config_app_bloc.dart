import 'dart:async';
import 'dart:io';
import 'package:general/src/core/cache/image_cache_manager.dart';
import 'package:general/src/features/auth/data/model/config_model.dart';
import 'package:general/src/features/auth/domain/use_cases/config_app_uc.dart';
import 'package:general/src/features/auth/presentation/splash/colors_bloc/colors_bloc.dart';
import 'package:general/src/features/auth/presentation/splash/get_vip_frames_bloc/get_vip_frames_bloc.dart';
import 'package:general/src/features/auth/presentation/splash/get_wabbles_bloc/get_wabbles_bloc.dart';
import 'package:general/src/features/room/presentation/component/messages/bloc/bubble_padding/get_bubble_padding_bloc.dart';
import 'package:general/src/features/vip/vip.dart';

part 'config_app_event.dart';
part 'config_app_state.dart';

class ConfigAppBloc extends Bloc<BaseConfigAppEvent, ConfigAppState> {
  final GetConfigAppUseCase configAppUseCase;

  ConfigAppBloc({required this.configAppUseCase})
      : super(const ConfigAppState()) {
    on<ConfigAppEvent>(_configApp);
  }

  Future<void> _configApp(
    ConfigAppEvent event,
    Emitter<ConfigAppState> emit,
  ) async {
    di<ColorsBloc>().applyCachedColors();
    applyCachedConfig();
    emit(state.copyWith(requestState: RequestState.loading));

    final result = await configAppUseCase(
      ConfigModelBody(
        appVersion: event.versionApp,
        devicePlatform: event.devicePLATFORM,
      ),
    );

    await result.fold(
      (failure) {
        emit(state.copyWith(requestState: RequestState.error));
      },
      (config) async {
        ConstantsManager.isReelsVisible = config.isShowReels ?? false;
        ConstantsManager.isShowCinemaMode = config.isShowCinemaMode ?? false;
        ConstantsManager.isShowLive = config.isShowLive ?? false;
        ConstantsManager.isShowPK = config.isShowPK ?? false;
        // Respect the user's manual choice (saved in Hive) â€” only fall back to
        // the server default when the user has never toggled the view.
        final savedGridPref = HiveManager()
            .getData<bool>(KeysManager.USER_BOX, KeysManager.IS_SHOW_GRID_VIEW_KEY);
        ConstantsManager.isShowGridView =
            savedGridPref ?? (config.isShowGridView ?? false);
        ConstantsManager.isShowRoomBoom = config.isShowRoomBoom ?? false;
        // `cache_assets` was parsed into the config model and then read by
        // nothing, so a handset that had cached the boom theme once never
        // fetched it again -- new artwork uploaded in the panel could not
        // reach the fleet at all.
        ConstantsManager.isBoomThemeStale = config.useBoomCacheTheme ?? false;
        ConstantsManager.isShowRoomActivity =
            config.isShowRoomActivity ?? false;
        ConstantsManager.appURL = config.appURL ?? "";
        ConstantsManager.appUiVariant = config.appUiVariant ?? 'default';
        ConstantsManager.isShowMoment = config.isShowMoment ?? false;
        ConstantsManager.isShowHostLevels = config.isShowHostLevels ?? false;
        ConstantsManager.isAudioRoomsEnabled =
            config.isAudioRoomsEnabled ?? false;
        ConstantsManager.homeScreen = config.homeScreen ?? "";
        ConstantsManager.isShareWithFriends =
            config.isShareWithFriends ?? false;
        ConstantsManager.isCharismaBadge =
            config.isCharismaBadge ?? false;

        ConstantsManager.activeModes = config.activeModes ?? [];

        // Cache config values
        cacheConfigValues(config);

        // Cache mic images (only re-download if URL changed)
        await _cacheMicImages(config.micImages);

        final hasToken = Methods.getUserToken().isNotEmpty;

        if (hasToken) {
          final isUpdated = (config.isColorUpdated ?? false);
          ConstantsManager.isColorUpdated = isUpdated;

          // Colors changed in the panel: fetch + APPLY the new colors into
          // ColorManager BEFORE emitting `loaded` (which drives the splash to
          // navigate). The post-splash tree then builds against the fresh
          // colors on this very launch. Awaiting here is the fix for the bug
          // where colors only appeared after several enter/exit cycles â€”
          // previously this was fire-and-forget and the tree built against the
          // old cached colors, picking up the new ones only on a later launch.
          // No change â†’ keep cache-first (already applied at the top of this
          // handler) so the perf path is untouched.
          // Refresh on every cold start, not only when app-check reports a
          // change.
          //
          // This build does not send `colors_updated_time` in the app-check body
          // â€” only version, version_name, OS and profile_frame_updated â€” so the
          // server's isUpdated() always takes its "client gave me no time"
          // branch and answers `colors: false`. The panel could therefore never
          // signal a palette change, the forceRefresh path never ran, and the
          // plain GET kept being served out of dio's on-disk cache. A build
          // pointed at a new backend stayed on the PREVIOUS server's palette
          // permanently: /api/colors/v2 was never requested once.
          //
          // The cached palette is already applied at the top of this handler, so
          // first paint is unaffected; this is one ~1.3 KB GET per launch, which
          // is a fair price for the panel actually controlling the colours.
          Methods.printLog(
            "Refreshing colors on cold start (app-check said: ${config.isColorUpdated})",
          );
          await di<ColorsBloc>().fetchAndApplyColors(forceRefresh: true);

          emit(
            state.copyWith(
              requestState: RequestState.loaded,
              config: config,
            ),
          );

          if (config.isUpdateBubbles == true) {
            di<GetBubblePaddingBloc>().add(const GetBubblePaddingEvent());
          }

          if (config.isUpdateWabbles == true) {
            di<GetWabblesBloc>().add(GetWabblesEvent());
          }
          if (config.isProfileFrameUpdated == true) {
            di<GetVipFramesBloc>().add(GetVipFramesEvent());
          }

          // Room/feature data (VIP theme, super-boom videos & themes, games
          // images, charisma levels) moved OFF cold-start â€” now fetched lazily
          // at their point-of-use (room entry / dialog open).
        } else {
          di<ColorsBloc>().add(const FetchColorsEvent());
          emit(
            state.copyWith(
              requestState: RequestState.empty,
              config: config,
            ),
          );
        }
      },
    );
  }
}

// Apply cached config values
void applyCachedConfig() {
  ConstantsManager.isReelsVisible = HiveManager().getData<bool>(
          KeysManager.USER_BOX, KeysManager.IS_REELS_VISIBLE_KEY) ??
      false;
  ConstantsManager.isShowCinemaMode = HiveManager().getData<bool>(
          KeysManager.USER_BOX, KeysManager.IS_SHOW_CINEMA_MODE_KEY) ??
      false;
  ConstantsManager.isShowLive = HiveManager()
          .getData<bool>(KeysManager.USER_BOX, KeysManager.IS_SHOW_LIVE_KEY) ??
      false;
  ConstantsManager.isShowPK = HiveManager()
          .getData<bool>(KeysManager.USER_BOX, KeysManager.IS_SHOW_PK_KEY) ??
      false;
  ConstantsManager.isShowGridView = HiveManager().getData<bool>(
          KeysManager.USER_BOX, KeysManager.IS_SHOW_GRID_VIEW_KEY) ??
      false;
  ConstantsManager.isShowRoomActivity = HiveManager().getData<bool>(
          KeysManager.USER_BOX, KeysManager.IS_SHOW_ROOM_ACTIVITY_KEY) ??
      false;
  ConstantsManager.appURL = HiveManager()
          .getData<String>(KeysManager.USER_BOX, KeysManager.APP_URL_KEY) ??
      "";
  final cachedUiVariant = ConstantsManager.normalizeUiVariant(
    HiveManager()
        .getData<String>(KeysManager.USER_BOX, KeysManager.APP_UI_VARIANT_KEY),
  );
  ConstantsManager.appUiVariant = cachedUiVariant;
  // Persist the normalized value so a client that cached a legacy variant
  // ('jo_live'/'new_theme') is migrated to the de-branded value on disk.
  HiveManager().saveData(
      KeysManager.USER_BOX, KeysManager.APP_UI_VARIANT_KEY, cachedUiVariant);
  ConstantsManager.isShowMoment = HiveManager().getData<bool>(
          KeysManager.USER_BOX, KeysManager.IS_SHOW_MOMENT_KEY) ??
      false;
  ConstantsManager.isShowHostLevels = HiveManager().getData<bool>(
          KeysManager.USER_BOX, KeysManager.IS_SHOW_HOST_LEVELS_KEY) ??
      false;
  ConstantsManager.isShareWithFriends = HiveManager().getData<bool>(
          KeysManager.USER_BOX, KeysManager.IS_SHARE_WITH_FRIENDS_KEY) ??
      false;
}

// Cache config values
void cacheConfigValues(ConfigModel config) {
  HiveManager().saveData(KeysManager.USER_BOX, KeysManager.IS_REELS_VISIBLE_KEY,
      config.isShowReels ?? false);
  HiveManager().saveData(KeysManager.USER_BOX,
      KeysManager.IS_SHOW_CINEMA_MODE_KEY, config.isShowCinemaMode ?? false);
  HiveManager().saveData(KeysManager.USER_BOX, KeysManager.IS_SHOW_LIVE_KEY,
      config.isShowLive ?? false);
  HiveManager().saveData(KeysManager.USER_BOX, KeysManager.IS_SHOW_PK_KEY,
      config.isShowPK ?? false);
  // Grid view is a USER preference (toggled from the home filter row), not a
  // server-forced flag: seed it from the server config only the first time
  // (when nothing is stored yet) so a later config refresh never clobbers the
  // user's own choice.
  if (HiveManager().getData<bool>(
          KeysManager.USER_BOX, KeysManager.IS_SHOW_GRID_VIEW_KEY) ==
      null) {
    HiveManager().saveData(KeysManager.USER_BOX,
        KeysManager.IS_SHOW_GRID_VIEW_KEY, config.isShowGridView ?? false);
  }
  HiveManager().saveData(
      KeysManager.USER_BOX,
      KeysManager.IS_SHOW_ROOM_ACTIVITY_KEY,
      config.isShowRoomActivity ?? false);
  HiveManager().saveData(
      KeysManager.USER_BOX, KeysManager.APP_URL_KEY, config.appURL ?? "");
  HiveManager().saveData(KeysManager.USER_BOX,
      KeysManager.APP_UI_VARIANT_KEY, config.appUiVariant ?? 'default');
  HiveManager().saveData(KeysManager.USER_BOX, KeysManager.IS_SHOW_MOMENT_KEY,
      config.isShowMoment ?? false);
  HiveManager().saveData(KeysManager.USER_BOX,
      KeysManager.IS_SHOW_HOST_LEVELS_KEY, config.isShowHostLevels ?? false);
  HiveManager().saveData(
      KeysManager.USER_BOX,
      KeysManager.IS_SHARE_WITH_FRIENDS_KEY,
      config.isShareWithFriends ?? false);
  HiveManager().saveData(KeysManager.USER_BOX,
      // IM PARTY has no dark variant, so the panel flag is pinned off rather
      // than stored. Nothing reads it any more; writing the server's value
      // would only leave a live switch behind that flips the app's ink to white.
      KeysManager.IS_DARK_MODE_ENABLED_KEY, false);
  HiveManager().saveData(KeysManager.USER_BOX,
      KeysManager.IS_BODY_THEME_ENABLED_KEY, config.isBodyThemeEnabled ?? false);
  HiveManager().saveData(KeysManager.USER_BOX, KeysManager.BODY_THEME_TYPE_KEY,
      config.backgroundBodyTheme?.type ?? '');
  HiveManager().saveData(KeysManager.USER_BOX, KeysManager.BODY_THEME_COLOR_KEY,
      config.backgroundBodyTheme?.color ?? '');
  HiveManager().saveData(
      KeysManager.USER_BOX,
      KeysManager.BODY_THEME_GRADIENT_ONE_KEY,
      config.backgroundBodyTheme?.gradientOne ?? '');
  HiveManager().saveData(
      KeysManager.USER_BOX,
      KeysManager.BODY_THEME_GRADIENT_TWO_KEY,
      config.backgroundBodyTheme?.gradientTwo ?? '');
  HiveManager().saveData(
      KeysManager.USER_BOX,
      KeysManager.BODY_THEME_GRADIENT_THREE_KEY,
      config.backgroundBodyTheme?.gradientThree ?? '');
  HiveManager().saveData(KeysManager.USER_BOX, KeysManager.BODY_THEME_IMAGE_KEY,
      config.backgroundBodyTheme?.image ?? '');

  ConstantsManager.bodyThemeNotifier.value++;
}

/// Downloads and caches mic images only when the URL has changed.
Future<void> _cacheMicImages(MicImagesModel? micImages) async {
  if (micImages == null) return;

  final hive = HiveManager();
  final cacheManager = AssetCacheManager();

  await Future.wait([
    _cacheMicImageIfChanged(
      hive: hive,
      cacheManager: cacheManager,
      newUrl: micImages.open,
      cacheKey: KeysManager.MIC_IMAGE_OPEN_KEY,
      urlCacheKey: KeysManager.MIC_IMAGE_OPEN_URL_KEY,
    ),
    _cacheMicImageIfChanged(
      hive: hive,
      cacheManager: cacheManager,
      newUrl: micImages.close,
      cacheKey: KeysManager.MIC_IMAGE_CLOSE_KEY,
      urlCacheKey: KeysManager.MIC_IMAGE_CLOSE_URL_KEY,
    ),
  ]);
}

/// Builds the expected local file path from the URL, then compares it
/// with the previously saved path. If different or file missing â†’ downloads
/// and saves the new local path. If same and file exists â†’ skips download.
Future<void> _cacheMicImageIfChanged({
  required HiveManager hive,
  required AssetCacheManager cacheManager,
  required String? newUrl,
  required String cacheKey,
  required String urlCacheKey,
}) async {
  if (newUrl == null || newUrl.isEmpty) return;

  final fullUrl =
      EndPoints.getImage(newUrl);

  // Always save the network URL for fallback
  hive.saveData(KeysManager.USER_BOX, urlCacheKey, fullUrl);

  final cleanKey = cacheManager.extractRelativePath(fullUrl);
  final expectedPath = '${cacheManager.getCachePath()}/$cleanKey';

  final cachedPath =
      hive.getData<String>(KeysManager.USER_BOX, cacheKey) ?? '';

  if (cachedPath == expectedPath && File(expectedPath).existsSync()) {
    Methods.printLog('[MicImages] $cacheKey unchanged, skipping download.');
    return;
  }

  Methods.printLog('[MicImages] $cacheKey changed, downloading: $fullUrl');
  final file = await cacheManager.getCachedAsset(fullUrl);
  if (file != null) {
    hive.saveData(KeysManager.USER_BOX, cacheKey, file.path);
    Methods.printLog('[MicImages] $cacheKey cached at: ${file.path}');
  }
}

