import 'package:general/src/core/index.dart';

class ConfigModel extends Equatable {
  final bool? isAuth;
  final bool? isShowChargeAgencies;
  final bool? isForce;
  final bool? isLastVersion;
  final bool? isUpdateGiftCache;
  final bool? isUpdateAgencyBadges;
  final bool? isUpdateWabbles;
  final bool? isUpdateBubbles;
  final bool? isUpdateSuperBoomVideos;
  final bool? isUpdateFrameCache;
  final bool? isUpdateExtraCache;
  final bool? isUpdateIntroCache;
  final bool? isUpdateEmojiCache;
  final bool? isProfileFrameUpdated;
  final bool? isColorUpdated;
  final bool? isBackgroundUpdated;
  final bool? isDisableChat;
  final bool? isShowReels;
  final bool? isUpdateGamesImage;
  final bool? colorTime;
  final bool? isShowCinemaMode;
  final bool? isShowLive;
  final String? roomBG;
  final bool? isShowRoomActivity;
  final String? appURL;
  final bool? isNewThemeEnabled;
  final String? appUiVariant;
  final bool? isShowMoment;
  final bool? isShowPK;
  final bool? isShowHostLevels;
  final bool? isShareWithFriends;
  final bool? isShowGridView;
  final bool? isShowRoomBoom;
  final bool? useBoomCacheTheme;
  final bool? isAudioRoomsEnabled;
  final String? homeScreen;
  final List<int>? activeModes;
  final MicImagesModel? micImages;
  final bool? isDarkModeEnabled;
  final bool? isBodyThemeEnabled;
  final BackgroundBodyThemeModel? backgroundBodyTheme;
  final bool? isCharismaBadge;

  const ConfigModel({
    this.isBackgroundUpdated,
    this.isUpdateAgencyBadges,
    this.isForce,
    this.isAuth,
    this.isUpdateEmojiCache,
    this.isUpdateIntroCache,
    this.isLastVersion,
    this.isUpdateWabbles,
    this.isUpdateBubbles,
    this.isUpdateGiftCache,
    this.isUpdateFrameCache,
    this.isUpdateExtraCache,
    this.isDisableChat,
    this.isColorUpdated,
    this.isProfileFrameUpdated,
    this.isShowChargeAgencies,
    this.isShowReels,
    this.isUpdateGamesImage,
    this.isUpdateSuperBoomVideos,
    this.colorTime,
    this.isShowCinemaMode,
    this.isShowLive,
    this.roomBG,
    this.isShowRoomActivity,
    this.appURL,
    this.isNewThemeEnabled = false,
    this.appUiVariant = 'default',
    this.isShowMoment = false,
    this.isShowPK,
    this.isShowRoomBoom,
    this.useBoomCacheTheme,
    this.isAudioRoomsEnabled,
    this.homeScreen,
    this.isShowHostLevels = false,
    this.isShareWithFriends = false,
    this.isShowGridView = false,
    this.activeModes,
    this.micImages,
    this.isDarkModeEnabled = false,
    this.isBodyThemeEnabled = false,
    this.backgroundBodyTheme,
    this.isCharismaBadge = false,
  });

  factory ConfigModel.fromJson(Map<String, dynamic> json) {
    final bool newTheme = parseValue<bool>(json['is_new_theme_enabled'], false);
    final String rawUiVariant =
        parseValue<String>(json['app_ui_variant'], '');
    // Backward compatible: when the backend doesn't send app_ui_variant,
    // derive it from the legacy is_new_theme_enabled flag. Legacy values
    // ('jo_live'/'new_theme') are remapped to their de-branded equivalents
    // ('theme_2'/'theme_1') so a deployed client renders the same shell.
    final String resolvedUiVariant = rawUiVariant.isNotEmpty
        ? ConstantsManager.normalizeUiVariant(rawUiVariant)
        : (newTheme ? 'theme_1' : 'default');
    return ConfigModel(
      isAuth: parseValue<bool>(json['is_auth'], false),
      isForce: parseValue<bool>(json['is_force'], false),

      isLastVersion: parseValue<bool>(json['is_last_version'], false),

      /// cache
      isUpdateWabbles: parseValue<bool>(json['cache_update']['wapple'], false),
      isUpdateBubbles:
          parseValue<bool>(json['cache_update']['bubble_frame'], false),
      isProfileFrameUpdated: parseValue<bool>(
          json['cache_update']['profile_frame_updated'], false),
      isUpdateAgencyBadges: parseValue<bool>(json['badges-agency'], false),

      /////
      isUpdateExtraCache:
          parseValue<bool>(json['cache_update']['extras'], false),
      isUpdateFrameCache:
          parseValue<bool>(json['cache_update']['frames'], false),
      isUpdateGiftCache: parseValue<bool>(json['cache_update']['gifts'], false),
      isUpdateEmojiCache:
          parseValue<bool>(json['cache_update']['emoji'], false),
      isUpdateIntroCache:
          parseValue<bool>(json['cache_update']['intro'], false),
      isDisableChat: parseValue<bool>(json["enable_chat"], false),
      isShowReels: parseValue<bool>(json["reel_status"], false),
      isColorUpdated:
          parseValue<bool>(json['cache_update']['color_time'], false),
      isBackgroundUpdated:
          parseValue<bool>(json['cache_update']['background'], false),
      isShowChargeAgencies:
          parseValue<bool>(json['is_show_shipping_agencies'], false),
      isUpdateGamesImage: parseValue<bool>(json['images'], false),
      isUpdateSuperBoomVideos:
          parseValue<bool>(json['cache_update']['room_boom_videos'], false),
      colorTime: parseValue<bool>(json['cache_update']['color_time'], false),
      isShowCinemaMode: parseValue<bool>(json['youtube_status'], false),
      isShowLive: parseValue<bool>(json['live_status'], false),
      roomBG: parseValue<String>(json['default_room_background'], ''),
      isShowRoomActivity:
          parseValue<bool>(json['is_show_room_activity'], false),
      appURL: parseValue<String>(json['app_url'], ""),
      isNewThemeEnabled: newTheme,
      appUiVariant: resolvedUiVariant,
      isShowMoment: parseValue<bool>(json['moment_status'], false),
      isShowPK: parseValue<bool>(json['is_pk_live_active'], false),
      isShowHostLevels: parseValue<bool>(json['is_show_host_levels'], false),
      isShareWithFriends:
          parseValue<bool>(json['is_share_with_friends'], false),
      isShowGridView: parseValue<bool>(json['is_show_grid_view'], false),
      isShowRoomBoom: parseValue<bool>(json['room_boom']['enabled'], false),
      useBoomCacheTheme: parseValue<bool>(json['room_boom']['cache_assets'], false),
      isAudioRoomsEnabled: parseValue<bool>(json['audio_room_enabled']['enable'], false),
      homeScreen: parseValue<String>(json['audio_room_enabled']['metadata']['default_screen'], ''),
      activeModes: parseValue<List<int>>(json['active_mode'], []),
      micImages: json['mic_images'] is Map<String, dynamic>
          ? MicImagesModel.fromJson(json['mic_images'] as Map<String, dynamic>)
          : null,
      isDarkModeEnabled:
          parseValue<bool>(json['is_dark_mode_enabled'], false),
      isBodyThemeEnabled:
          parseValue<bool>(json['is_body_theme_enabled'], false),
      backgroundBodyTheme: json['background_body_theme'] is Map<String, dynamic>
          ? BackgroundBodyThemeModel.fromJson(
              json['background_body_theme'] as Map<String, dynamic>)
          : null,
      isCharismaBadge: parseValue<bool>(json['charisma_badge'], false),
    );
  }

  @override
  List<Object?> get props => [
        isAuth,
        isShowRoomBoom,
        useBoomCacheTheme,
        isLastVersion,
        isForce,
        isUpdateExtraCache,
        isUpdateFrameCache,
        isUpdateGiftCache,
        isUpdateIntroCache,
        isUpdateAgencyBadges,
        isUpdateEmojiCache,
        isProfileFrameUpdated,
        isColorUpdated,
        isBackgroundUpdated,
        isUpdateWabbles,
        isUpdateBubbles,
        isShowChargeAgencies,
        isShowReels,
        isDisableChat,
        isUpdateGamesImage,
        isUpdateSuperBoomVideos,
        colorTime,
        roomBG,
        isShowRoomActivity,
        appURL,
        isNewThemeEnabled,
        appUiVariant,
        isShowMoment,
        isShowPK,
        isShowHostLevels,
        isShareWithFriends,
        isShowGridView,
        isAudioRoomsEnabled,
        homeScreen,
        activeModes,
        micImages,
        isDarkModeEnabled,
        isBodyThemeEnabled,
        backgroundBodyTheme,
        isCharismaBadge,
      ];
}

class MicImagesModel extends Equatable {
  final String? open;
  final String? close;

  const MicImagesModel({this.open, this.close});

  factory MicImagesModel.fromJson(Map<String, dynamic> json) {
    return MicImagesModel(
      open: json['open'] as String?,
      close: json['close'] as String?,
    );
  }

  @override
  List<Object?> get props => [open, close];
}

class BackgroundBodyThemeModel extends Equatable {
  final String? type;
  final String? color;
  final String? gradientOne;
  final String? gradientTwo;
  final String? gradientThree;
  final String? image;

  const BackgroundBodyThemeModel({
    this.type,
    this.color,
    this.gradientOne,
    this.gradientTwo,
    this.gradientThree,
    this.image,
  });

  factory BackgroundBodyThemeModel.fromJson(Map<String, dynamic> json) {
    return BackgroundBodyThemeModel(
      type: parseValue<String>(json['type'], ''),
      color: parseValue<String>(json['color'], ''),
      gradientOne: parseValue<String>(json['gradient_one'], ''),
      gradientTwo: parseValue<String>(json['gradient_two'], ''),
      gradientThree: parseValue<String>(json['gradient_three'], ''),
      image: parseValue<String>(json['image'], ''),
    );
  }

  @override
  List<Object?> get props =>
      [type, color, gradientOne, gradientTwo, gradientThree, image];
}

class ConfigModelBody {
  final String appVersion;
  final String devicePlatform;

  const ConfigModelBody({
    required this.appVersion,
    required this.devicePlatform,
  });
}
