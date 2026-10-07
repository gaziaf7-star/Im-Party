class KeysManager {
  KeysManager._privateConstructor();

  static final KeysManager _instance = KeysManager._privateConstructor();

  factory KeysManager() {
    return _instance;
  }
  // [Boxes]
  static const String USER_BOX = "user";
  static const String MUSIC_BOX = "music";
  static const String ROOMS_BOX = "rooms";
  static const String FRAMES_BOX = "frames";
  static const String WABBLES_BOX = "wabbles";
  static const String AGENCY_BADDES_BOX = "agency_badges";
  static const String BUBBLE_PADDING_BOX = "bubble_padding";
  static const String VIP_THEME_SETTINGS_BOX = "vip_theme_settings";
  static const String GAMES_BOX = "games";
  static const String ROOM_USERS_BOX = "room_users";
  static const String Last_Time_Cache_Box = "last_time_cache";
  static const String roomTokensBox = "room_tokens";
  static const String rtmTokensBox = "rtm_tokens";

  //* [Keys]
  static const String LOGIN_ACCOUNTS_KEY = "login_accounts";
  static const String WABBLES_KEY = "wabbles";
  static const String GAMES_KEY = "games";
  static const String TOKEN_KEY = "user_token";
  static const String VIP_FRAMES_KEY = "frames_vip";
  static const String AGENCY_BADGES_KEY = "agency_badges";
  static const String CACHE_MUSIC_KEY = "cache_music";
  static const String LANG_CODE_KEY = "language_code";
  static const String IS_SKIPPED_ADDED_INFO_KEY = "is_skiped_added_information";
  static const String IS_SKIPPED_ONBOARDING_KEY = "is_skipped_on_boarding";
  static const String IS_SKIPPED_LANGUAGE_KEY = "is_skipped_language";
  static const String HAS_LAUNCHED_BEFORE_KEY = "has_launched_before";
  static const String PK_WIN_STREAK = "pk_win_streak";
  static const String LAST_LIVE_TITLE_KEY = "last_live_title";

  static const String MINIMIZE_GIFT_KEY = "minimize_gift";
  static const String ACCEPT_YOUTUBE_TERMS_KEY = "accept_youtube_terms";
  static const String LAAT_MUSIC_INDEX_KEY = "laat_music_index";
  static const String BUBBLE_PADDING_KEY = "bubble_padding";
  static const String VIP_THEME_SETTINGS_KEY = "vip_theme_settings";
  static const String LIKED_SONG_IDS_KEY = "liked_song_ids_key";
  static const String LOCATION_PERMISSION_KEY = "location_permission_key";

  //* [App Settings Keys]
  static const String MIC_BACKGROUND_DIALOG_SHOWN_KEY =
      "mic_background_dialog_shown";
  static const String MUTE_MIC_IN_BACKGROUND_KEY = "mute_mic_in_background";

  //* [Colors Keys]
  static const String BACKGROUND_KEY = "app_background";
  static const String BOTTOM_NAV_ICONS_KEY = "bottom_nav_icons";

  /// Cached ordered bottom-nav icon URLs from the panel: a list of
  /// "active|inactive" strings (one per tab). Restored on cold start so the bar
  /// renders the custom icons before the colors response returns.
  static const String NAV_ICON_URLS_KEY = "nav_icon_urls";
  static const String BACKGROUND_TYPE_KEY = "app_background_type";

  /// Cached panel-driven region backgrounds (`regions.nav` / `regions.body`),
  /// each stored as the compact `type|image|c1,c2,...` form so the region
  /// applies on cold start before the colors response returns.
  static const String NAV_REGION_KEY = "nav_region";
  static const String BODY_REGION_KEY = "body_region";
  static const String PRIMARY_COLOR_KEY = "primary_color";
  static const String SECONDARY_COLOR_KEY = "secondary_color";

  /// The PARSED page-fill colour from `background.value`. Separate from
  /// [BACKGROUND_KEY], which holds the raw value and may be an image URL.
  static const String BACKGROUND_COLOR_KEY = "app_background_color";
  static const String BOTTOM_NAV_COLOR_KEY = "bottom_nav_color";
  static const String ACTIVE_COLOR_KEY = "active_color";
  static const String INACTIVE_COLOR_KEY = "inactive_color";
  static const String HEADER_COLOR_KEY = "header_bar_color";
  static const String BUTTON_TEXT_COLOR_KEY = "button_text_color";
  static const String BUTTON_COLOR_KEY = "button_color";
  static const String TEXT_PRIMARY_COLOR_KEY = "text_primary_color";
  static const String TEXT_SECONDARY_COLOR_KEY = "text_secondary_color";
  static const String ICON_COLOR_KEY = "icon_color";
  static const String CARD_COLOR_KEY = "card_color";

  /// Cached per-color `{key}_grad` gradient tokens, each stored as the compact
  /// `type|c1,c2,...|direction|reverse` form so the gradient applies on cold
  /// start before the colors response returns. A missing entry leaves the
  /// matching flat color as the solid fallback.
  static const String PRIMARY_GRAD_KEY = "primary_color_grad";
  static const String HEADER_GRAD_KEY = "header_bar_color_grad";
  static const String BUTTON_TEXT_GRAD_KEY = "button_text_color_grad";
  static const String TEXT_PRIMARY_GRAD_KEY = "text_primary_color_grad";
  static const String TEXT_SECONDARY_GRAD_KEY = "text_secondary_color_grad";
  static const String ICON_GRAD_KEY = "icon_color_grad";
  static const String CARD_GRAD_KEY = "card_color_grad";

  //* [Config Keys]
  static const String IS_REELS_VISIBLE_KEY = "is_reels_visible";
  static const String IS_SHOW_CINEMA_MODE_KEY = "is_show_cinema_mode";
  static const String IS_SHOW_LIVE_KEY = "is_show_live";
  static const String IS_SHOW_PK_KEY = "is_show_pk";
  static const String IS_SHOW_GRID_VIEW_KEY = "is_show_grid_view";
  static const String IS_SHOW_ROOM_ACTIVITY_KEY = "is_show_room_activity";
  static const String APP_URL_KEY = "app_url";
  static const String IS_NEW_THEME_ENABLED_KEY = "is_new_theme_enabled";
  static const String APP_UI_VARIANT_KEY = "app_ui_variant";
  static const String IS_SHOW_MOMENT_KEY = "is_show_moment";
  static const String IS_SHOW_HOST_LEVELS_KEY = "is_show_host_levels";
  static const String IS_SHARE_WITH_FRIENDS_KEY = "is_share_with_friends";

  //* [Body Theme Keys]
  static const String IS_DARK_MODE_ENABLED_KEY = "is_dark_mode_enabled";
  static const String IS_BODY_THEME_ENABLED_KEY = "is_body_theme_enabled";
  static const String BODY_THEME_TYPE_KEY = "body_theme_type";
  static const String BODY_THEME_COLOR_KEY = "body_theme_color";
  static const String BODY_THEME_GRADIENT_ONE_KEY = "body_theme_gradient_one";
  static const String BODY_THEME_GRADIENT_TWO_KEY = "body_theme_gradient_two";
  static const String BODY_THEME_GRADIENT_THREE_KEY =
      "body_theme_gradient_three";
  static const String BODY_THEME_IMAGE_KEY = "body_theme_image";

  //* [Mic Images Keys]
  static const String MIC_IMAGE_OPEN_KEY = "mic_image_open";
  static const String MIC_IMAGE_CLOSE_KEY = "mic_image_close";
  static const String MIC_IMAGE_OPEN_URL_KEY = "mic_image_open_url";
  static const String MIC_IMAGE_CLOSE_URL_KEY = "mic_image_close_url";
}
