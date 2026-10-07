import 'package:general/src/core/index.dart';

class AssetsManager {
  const AssetsManager._();
  // NEW PROFILE
  static String get bgMine => "bg_mine".svgaImg;
  /// Profile menu's Wallet tile artwork, on request (was AssetsManager.agencyWallet).
  static String get walletIconTiger => "wallet_icon_tiger".pngIcon;
  // Mine tab hero cards (generated art, 1000x480 webp).
  static String get meWalletCard => "me_wallet".webPImg;
  static String get meSvipCard => "me_svip".webPImg;
  static String get icMeAgency => "ic_me_agency".webPIcon;
  static String get icMeAudioRoom => "ic_me_audio_room".webPIcon;
  static String get icMeCheckIn => "ic_me_check_in".webPIcon;
  static String get icMeInvitation => "ic_me_invitation".pngIcon;
  static String get icMeMedal => "ic_me_medal".webPIcon;
  static String get icMeLevel => "ic_me_level".webPIcon;
  static String get icMeShop => "ic_me_shop".webPIcon;
  static String get icMeSupport => "ic_me_support".webPIcon;
  static String get icMeVip => "ic_me_vip".webPIcon;
  static String get bgMineWallet1 => "bg_mine_wallet_1".webPImg;
  static String get bgMineWallet2 => "bg_mine_wallet_2".webPImg;
  static String get icMeBlack => "ic_me_black".webPIcon;
  static String get icMeFeedback => "ic_me_feedback".webPIcon;
  static String get icMeSettings => "ic_me_settings".webPIcon;

  static String get musicFloatIcon => "ui_music_icon".svgaIcon;

  static String get agencyRoomProfileBG => "ic_user_info_guild_bg".webPImg;
  static String get roomProfileSendGift => "ic_user_info_send_gift".webPIcon;
  static String get roomProfileAddAttention =>
      "ic_user_info_add_attention".webPIcon;
  static String get roomProfileAttentioned =>
      "ic_user_info_attentioned".webPIcon;

  static String get icHomeMagicIndicatorArrowSelect =>
      "ic_home_magic_indicator_arrow_select".webPIcon;
  static String get icHomeMagicIndicatorArrowNormal =>
      "ic_home_magic_indicator_arrow_normal".webPIcon;

  static String get pkRank2 => "bg_ranking_second".webPIcon;
  static String get pkRank3 => "bg_ranking_third".webPIcon;

  static String get blueSeat => "ahi".webPIcon;
  static String get redSeat => "ahj".webPIcon;
  static String get closePkIcon => "greedy_cat_ic_close".pngIcon;

  static String get pkRank1 => "bg_ranking_first".webPIcon;
  // NEW HOME
  static String get icStartLive => "icon_start_live".webPIcon;
  static String get icHomeSearch => "icon_home_search".webPIcon;
  static String get icCrBg => "icon_cr_bg".webPIcon;
  static String get icCrCrown1 => "icon_cr_crown_1".webPIcon;
  static String get icCrCrown2 => "icon_cr_crown_2".webPIcon;
  static String get icCrCrown3 => "icon_cr_crown_3".webPIcon;
  static String get icWrBg => "icon_wr_bg".webPIcon;
  static String get icWrCrown1 => "icon_wr_crown_1".webPIcon;
  static String get icWrCrown2 => "icon_wr_crown_2".webPIcon;
  static String get icWrCrown3 => "icon_wr_crown_3".webPIcon;
  static String get icHomeItemLive => "ic_home_item_live".webPIcon;
  static String get icHomeItemAudio => "ic_home_item_audio".webPIcon;
  static String get icLuckyBag => "ic_lucky_bag_small".webPIcon;
  // BOTTOM NAV — generic fallback set ONLY. The themed bottom-nav icon sets
  // (jo / new-theme / svga) were removed: nav icons now come from the admin
  // panel (active + inactive URLs, fetched + cached on device). These plain
  // icons are used solely when a panel URL is empty so the bar is never blank.
  static String get icHome => "ic_home".pngIcon;
  static String get icGame => "ic_game".pngIcon;
  static String get icBubble => "ic_bubble".pngIcon;
  static String get icWorld => "ic_world".pngIcon;
  static String get icProfile => "ic_profile".pngIcon;
  static String get icReel => "ic_reel".pngIcon;

  // BOTTOM NAV — redesigned bar (layout_page.dart _BottomNavigationBar).
  // Dedicated SVG line-icon set requested for the new pill/circle nav
  // design; rendered locally and tinted per active/inactive state, NOT
  // pulled from the admin panel like the generic set above.
  static String get navHomeIcon => "home_icon".svgIcon;
  static String get navMomentIcon => "moment_icon".svgIcon;
  static String get navMessageIcon => "hel_tab_msg".svgIcon;
  static String get navProfileIcon => "profile_icon".svgIcon;
  static String get navGoLiveIcon => "hel_tab_live".svgIcon;

  // WEEKLY LEVEL
  static String get icWeeklyTier1 => "ic_weekly_level_1".webPImg;
  static String get icWeeklyTier2 => "ic_weekly_level_2".webPImg;
  static String get icWeeklyTier3 => "ic_weekly_level_3".webPImg;
  static String get icWeeklyTier4 => "ic_weekly_level_4".webPImg;
  static String get icWeeklyTier6 => "ic_weekly_level_6".webPImg;
  static String get icWeeklyTier7 => "ic_weekly_level_7".webPImg;
  static String get icWeeklyDirectionUp => "up-arrow".pngImg;

  static String get gift => "gift".pngIcon;
  static String get downloadIcon => "download".pngIcon;
  static String get updateIllustration => "update_illustration".pngImg;

  static String get dailyPrize => "daily_prize".pngIcon;

  static String get onlineHi => "hel_online_hi".svgaIcon;

  static String get soundWaves => "hel_party_wave".svgaImg;

  //
  static String get onlineLove => "hel_online_love".svgaIcon;

  static String get hiMeetUser => "hel_online_hi_small".svgaIcon;

  static String get videoOn => "icons8-video-50".pngIcon;

  //
  static String get videoOff => "icons8-no-video-50".pngIcon;

  //
  static String get request => "icons8-infinity-24".pngIcon;

  //
  static String get switchCamera => "switch-camera".pngIcon;

  static String get breakIcon => "icons8-break-64".pngIcon;

  //
  // //video
  static String get gamesBackground => "assets/videos/games_background.mp4";

  //images
  static String get frameTopThreeCp => "frame_top_three_cp".pngImg;

  //
  static String get luckyBoxBanner => "lucky_box_banner".pngImg;

  //
  static String get frameTopTwoCp => "frame_top_two_cp".pngImg;

  static String get pkBackground => "bg_pk".webPImg;
  static String get pkTimer => "bg_pk_timer.9".pngIcon;
  static String get pkLogo => "ic_pk_title_new".pngIcon;

  //
  static String get frameTopOneCp => "frame_top_one_cp".pngImg;

  static String get frameHomeTopOne => "frame_home_top_one".pngImg;

  static String get frameHomeTopTwo => "frame_home_top_two".pngImg;

  static String get frameHomeTopThree => "frame_home_top_three".pngImg;

  static String get backgroundRankHomeWealth =>
      "background_rank_home_wealth".pngImg;

  static String get backgroundRankHomeRoom =>
      "background_rank_home_room".pngImg;

  static String get backgroundRankHomeCharm =>
      "background_rank_home_charm".pngImg;

  static String get backgroundRankHomeGame =>
      "background_rank_home_game".pngImg;

  static String get reelPlaceholder => "reel_placeholder".pngImg;

  static String get cpLoveIcon => "hel_cp_heart".svgaImg;

  static String get fireWorks => "hel_active_fireworks".svgaImg;

  static String get cinemaLogo2 => "cinema_logo2".pngImg;

  static String get cinemaScreen => "cinema_screen".pngImg;

  static String get cinemaBackground => "bg_move_new".pngImg;

  static String get seat8ModeBackground => "seat8-mode_bg".pngImg;

  static String get seat2ModeBackground => "date_mode_bg".pngImg;

  static String get cinemaBackgroundTop => "bg_move_top 1".pngImg;

  static String get coupleModeBg => "couple_mode_bg".pngImg;

  static String get coupleModeSeat => "couple_mode_seat".pngImg;

  static String get heartCpProfile => "heart_cp_profile".pngIcon;

  static String get youtube => "youtube".pngImg;

  static String get cinema => "cinema".pngIcon;

  static String get coinsIcon => "coins_icon".pngIcon;

  static String get sendGiftRoom => "send_gift_room".pngIcon;

  static String get messageIcon => "message-icon".pngIcon;
  static String get messageIconNew => "message-icon".webPIcon;
  static String get micOnIcon => "mic_on".webPIcon;
  static String get micOffIcon => "mic_off".webPIcon;
  static String get soundOnIcon => "sound_on".webPIcon;
  static String get soundOffIcon => "sound_off".webPIcon;
  static String get basicTool => "basic_tool".pngIcon;
  static String get basicToolNew => "basic_tool".webPIcon;
  static String get chatIcon => "chat_icon".webPIcon;

  /// Audio room bottom bar -- new custom icon set (on request):
  /// chat/message bubble, mic muted, mic unmuted, and the gift icon (svga).
  static String get mailAudioIcon => "mailAudio".pngIcon;
  static String get muteAudioIcon => "Mute".pngIcon;
  static String get unmuteAudioIcon => "unmuteAudio".pngIcon;
  static String get giftIconAudio => "gift_icon".svgaIcon;

  static String get heartCp => "bao 2".pngIcon;

  static String get banFromRoom => "ban_from_room".pngIcon;

  static String get ban => "ban".pngImg;

  static String get downArrow => "down-arrow".pngIcon;
  static String get downArrowNew => "down".pngIcon;
  static String get infoIcon => "ic_user_info_operator".pngIcon;

  static String get google => "google".pngIcon;

  static String get pilling => "pilling".pngIcon;

  static String get refresh => "refresh".pngIcon;

  static String get apple => "apple".pngIcon;

  static String get huawei => "huawei".pngIcon;

  static String get groupChat => "group-chat".pngIcon;

  static String get roomIntroMessageIcon => "roomIntroMessageIcon".pngIcon;

  static String get agencyIcon => "agency_profile".pngIcon;

  static String get coinIcon => "tiger_coin_icon".pngIcon;

  static String get femaleIcon => "female_icon".pngImg;

  static String get copyId => "copy".pngIcon;

  static String get dangerIcon => "danger_icon".pngIcon;

  static String get loveHeartIcon => "love_heart_icon".pngIcon;

  static String get loveHeartIcon2 => "love_heart_icon2".pngIcon;

  static String get commentIcon2 => "comment_icon".pngIcon;

  static String get levelUpIcon => "level_up_icon".pngIcon;

  static String get badgeIcon => "badge_icon".pngIcon;

  static String get mallShoppingIcon => "mall_shopping".pngIcon;

  static String get walletTigerIcon => "wallet_icon_tiger".pngIcon;

  static String get man => "man".pngIcon;

  //levels

  // reels

  static String get iconShareGroupChat => "icon_share_groupChat".pngIcon;

  static String get addReel => "add_reel_icon".pngIcon;

  static String get topOneFrame => "top_one_frame".pngIcon;

  static String get topTwoFrame => "top_two_frame".pngIcon;

  static String get topThreeFrame => "top_three_frame".pngIcon;

  static String get dailyPrizeBackground => "daily_prize".pngImg;

  static String get cpCardBackground => "cp_card_background".pngImg;

  static String get dailyPrizeCard => "daily_prize_card".pngImg;

  /// Decorative gift-box artwork for the redesigned weekly sign-in dialog —
  /// exact path requested by the client.
  static String get dailyRewardGiftBox => "assets/icons/DailyRewrd gift.png";

  static String get familyCardBackground => "family_card_background".pngImg;

  static String get homeIconActive => "home_icon".svgaIcon;

  static String get chatIconActive => "hel_tab_msg".svgaIcon;

  static String get streamIconActive => "hel_tab_live".svgaIcon;

  static String get streamIconUnActive => "live_home_icon".pngIcon;

  static String get gamesIconUnActive => "hel_tab_game".pngIcon;

  static String get gamesIconActive => "hel_tab_game".svgaIcon;

  static String get momentIconActive => "moment_icon".svgaIcon;

  static String get momentIcon => "moment_icon".pngIcon;

  static String get profileIconActive => "profile_icon".svgaIcon;

  static String get myRoomCardBackground => "my_room_card_background".pngImg;

  static String get plusIcon2 => "plus".pngIcon;

  static String get quickGames => "quick_games".pngIcon;

  static String get rechargeChargeAgency => "recharge_charge_agency".pngIcon;

  static String get grid1 => "top1room".svgaImg;

  static String get grid2 => "top2room".svgaImg;

  static String get grid3 => "top3room".svgaImg;

  static String get newSoundWave => "109190".pngIcon;

  static String get bannerRoom1 => "banner_room_1".svgaImg;

  static String get bannerRoom2 => "banner_room_2".svgaImg;

  static String get bannerRoom3 => "banner_room_3".svgaImg;

  static String get multiple5 => "hel_reback_gift_multiple5".svgaImg;
  static String get multiple10 => "hel_reback_gift_multiple10".svgaImg;
  static String get multiple20 => "hel_reback_gift_multiple20".svgaImg;
  static String get multiple50 => "hel_reback_gift_multiple50".svgaImg;
  static String get multiple100 => "hel_reback_gift_multiple100".svgaImg;
  static String get multiple250 => "hel_reback_gift_multiple250".svgaImg;
  static String get multiple500 => "hel_reback_gift_multiple500".svgaImg;
  static String get multiple1000 => "hel_reback_gift_multiple1000".svgaImg;

  static String get arBanner250 => "ar250".svgaImg;
  static String get arBanner500 => "ar500".svgaImg;
  static String get arBanner1000 => "ar1000".svgaImg;

  static String get enBanner250 => "en250".svgaImg;
  static String get enBanner500 => "en500".svgaImg;
  static String get enBanner1000 => "en1000".svgaImg;

  static String get yallowBanner => "yallow_banner".svgaImg;

  static String cpRelationLevelHeart({required int level}) {
    if (level == 0) {
      return "hel_cp_heart".svgaImg;
    }
    return "hel_cp_heart_lv$level".svgaImg;
  }

  static String get cpHeartAvatar => "hel_cp_avatar".svgaImg;

  //rankSvga
  static String get charmRank1Frame => "hel_home_charm_rank_1".svgaImg;

  static String get charmRank2Frame => "hel_home_charm_rank_2".svgaImg;

  static String get charmRank3Frame => "hel_home_charm_rank_3".svgaImg;

  static String get roomRank1Frame => "hel_home_room_rank_1".svgaImg;

  static String get roomRank2Frame => "hel_home_room_rank_2".svgaImg;

  static String get roomRank3Frame => "hel_home_room_rank_3".svgaImg;

  static String get wealthRank1Frame => "hel_home_wealth_rank_1".svgaImg;

  static String get wealthRank2Frame => "hel_home_wealth_rank_2".svgaImg;

  static String get wealthRank3Frame => "hel_home_wealth_rank_3".svgaImg;

  static String get gameRank1Frame => "hel_home_game_rank_1".svgaImg;

  static String get gameRank2Frame => "hel_home_game_rank_2".svgaImg;

  static String get gameRank3Frame => "hel_home_game_rank_3".svgaImg;

  static String get backgroundMedalsSvga => "background_medals_svga".svgaImg;

  static String get searchIcon => "search_icon".pngIcon;
  static String get searchIcon1 => "search (1)".pngIcon;
  static String get briefcase => "briefcase".pngIcon;

  static String get exchangeDiamondIcon => "exchange_diamond_icon".pngIcon;

  static String get clearChat => "tool_icon_clear_on".pngIcon;

  static String get closeComments => "close_moments".pngIcon;

  static String get effect => "tool_icon_effects_on".pngIcon;

  //recharge coins
  static String get gameIconHome => "game_icon_home".pngIcon;

  static String get roomSupportIcon => "room Support".pngImg;

  static String get roomSupportActionImage => "Room Supporimage".pngImg;

  static String get roomSupportTextImage => "room support text".pngImg;

  static String get redPocketIcon => "redpoket".pngImg;

  static String get audioRedPocketIcon => "audioredpoket ".pngImg;

  static String get rocketPathImage => "roketpath".pngImg;

  static String get gameIconRank => "game_icon_rank".pngIcon;

  static String get coinsVip => "coins_vip".pngIcon;

  static String get teenPattiIcon => "ui_icons/Teen Patty".pngIcon;

  static String get greedyLionIcon => "ui_icons/GreadyLion".pngIcon;

  static String get greedyBabyIcon => "assets/icons/ui_icons/greadybaby.jfif";

  static String get rouletteIcon => "assets/icons/ui_icons/rollet.jpg";

  static String get ferryWheelIcon => "assets/icons/ui_icons/Freewell.jpg";

  static String get lucky77Icon => "assets/icons/ui_icons/ucky77 (1).png";

  static String get coinPayment => "coin_payment".pngIcon;

  // //payment

  static String get profileHintImage => "profile_hint_image".pngImg;

  static String get splashBackground => "splash_background".pngImg;

  // The full-screen splash background requested to replace the small
  // centered logo -> assets/icons/solashfastbg.png.
  static String get splashFullBg => "solashfastbg".pngIcon;

  static String get send => "send".pngIcon;

  static String get mic => "mic".pngIcon;

  static String get line => "line".pngIcon;

  static String get rankHeartIcon => "rank_heart_icon".pngIcon;

  static String get roomRankCoin => "room_rank_coin".pngIcon;

  static String get rankWealthIcon => "rank_wealth_icon".pngIcon;

  static String get cpBackground => "cp_background".pngImg;

  static String get cpBackgroundRank => "back_ground_cp_rank".pngImg;

  static String get rankBackground => "rank_background".jpgImg;

  static String get roomRankingBackground => "room_ranking_bg".pngImg;
  static String get wealthRankingBackground => "wealth_ranking_bg".pngImg;
  static String get charmRankingBackground => "charm_ranking_bg".pngImg;
  static String get agencyRankingBackground => "agency_ranking_bg".pngImg;
  static String get gameRankingBackground => "game-ranking-bg".pngImg;

  static String get top1Frame => "newtop1".pngImg;
  static String get top2Frame => "newtop2".pngImg;
  static String get top3Frame => "newtop3".pngImg;

  static String get top1Bg => "top1_bg".pngImg;
  static String get top2Bg => "top2_bg".pngImg;
  static String get top3Bg => "top3_bg".pngImg;

  static String get supporterCoin => "supporter_coin_icon".pngIcon;

  static String get billIcon => "bill_icon".pngIcon;

  static String get rechargeCoinsIcon => "recharge_coins_icon".pngIcon;

  static String get starCoinsIcon => "star_coins_icon".pngIcon;

  static String get diamondsIcon => "diamonds_icon".pngIcon;

  static String get roomRankBadge => "room_rank_badge".pngImg;

  static String get filterIcon => "filter-search".pngIcon;

  static String get goldCardBackground => "cold_card".pngImg;

  static String get diamondCardBackground => "dimond_card".pngImg;

  // //mall
  static String get lockIcon => "lock_icon".pngIcon;

  static String get starBadge => "star_badge".pngIcon;

  static String get lockRoomIcon => "lock_room_icon".pngIcon;

  static String get diamondIcon => "dimond_icon".pngIcon;

  static String get playCircle => "play_circle".pngIcon;

  //setting
  static String get trashIcon => "trash_icon".pngIcon;

  static String get appleIcon => "apple_icon".pngIcon;

// /////////////////////////////////////
  static String get cp => "cp".pngImg;

//   // icons
  static String get profileMsgIcon => "message_icon".pngIcon;

  static String get editMyProfile => "edit_my_profile".pngIcon;

  static String get cpCoin => "cp_coin".pngIcon;

  static String get shareRoom => "share".pngIcon;

  static String get shareMoment => "share_moment".pngIcon;

  static String get shareIcon => "share_icon".pngIcon;

  static String get shareFriends => "share_friends".pngIcon;

  static String get buyItem => "buy_item".pngIcon;

  static String get manInfo => "man".pngImg;

  static String get women => "woman".pngImg;

  static String get familyCreateIc => "family_create_center_ic".pngIcon;

  static String get familyCreateIncomeIc => "family_create_income_ic".pngIcon;

  static String get familyCreateTaskIc => "family_create_task_ic".pngIcon;

  static String get familyCreatePeopleIc => "family_create_people_ic".pngIcon;

  // lottie
  static String get error => "assets/lottie/error.json";

  static String get noWifi => "assets/lottie/no_wifi.json";

  static String get loading => "assets/lottie/loading.json";

  static String get empty => "assets/lottie/empty.json";

  ///family

  static String get soundIcon => "sound".svgIcon;

  static String get acceptIcon => "acceptIcon".pngIcon;

  static String get declineIcon => "declineIcon".pngIcon;

  static String get emptyFamily => "empty_family".pngIcon;

  static String get agencycalendar => "guild_anchor_data_calendar_ic".pngIcon;

  static String get agencyclock => "guild_anchor_data_clock_ic".pngIcon;

  static String get agencydiamond => "guild_anchor_data_diamond_ic".pngIcon;

  static String get identitySetting2 => "identity_setting".pngIcon;

  ///mall_bag
  static String get mallCoin => "mall_coin".pngIcon;

  ///profile

  static String get settings => "settings_profile".pngIcon;

  static String get titleIconPrivilege => "title_icon_privilege".pngIcon;

  static String get cpFrame1 => "cp_frame_1".pngIcon;

  static String get cpFrame2 => "cp_frame_2".pngIcon;

  static String get cpFrame3 => "cp_frame_3".pngIcon;

  static String get emptyUserRelation => "empty_user_relation".pngIcon;

  static String vipBackground({required int vip}) =>
      "vip_background$vip".pngImg;

  static String get vipBackground4 => "vip_profile".pngImg;

  static String get vipBackground6 => "cp_rank_background".pngImg;

  // Per-SVIP-tier background image, always loaded from the app's own local
  // assets folder — requested so each tier's background never comes from
  // the admin panel/backend API. `vip` is 1-indexed to match the tier
  // number. Several tiers now SHARE one supplied decorative background
  // file, with the exact filenames given (spacing kept literal — note
  // the space in "svip 7,8", unlike the others):
  //   SVIP1        -> assets/icons/svip1.png
  //   SVIP2, SVIP3 -> assets/icons/svip2,3 (1).png
  //   SVIP4, SVIP5 -> assets/icons/svip4,5 (1).png
  //   SVIP6        -> assets/icons/svip6 (1).png
  //   SVIP7, SVIP8 -> assets/icons/svip 7,8 (1).png
  static String svipBackground({required int vip}) {
    if (vip <= 1) return "svip1".pngIcon;
    if (vip == 2 || vip == 3) return "assets/icons/svip2,3 (1).png";
    if (vip == 4 || vip == 5) return "assets/icons/svip4,5 (1).png";
    if (vip == 6) return "assets/icons/svip6 (1).png";
    return "assets/icons/svip 7,8 (1).png";
  }

  static String vip1({required int vip}) => "vip$vip".svgaVip;

  static String get giftBanner1 => "gift_1".svgaImg;

  static String get chatFriends => "chat_friends".pngIcon;

  static String get notification => "notification".pngIcon;

  static String get muteUser => "mute_user".pngIcon;

  static String get friendRequest => "friend_request".pngIcon;

  static String get officialMessage => "official_message".pngIcon;

  static String get addGallery => "gallery-add".pngIcon;

  static String get volume => "volume".pngIcon;

  static String get userBlock => "user-block".pngIcon;

  static String get volumeOff => "volume-off".pngIcon;

  static String get giftRoom => "gift_room".svgaIcon;
  static String get giftIconNew => "gift_room_new".svgaIcon;

  static String get music => "icon_music".pngIcon;

  static String get seat => "seat".pngIcon;

  static String get cinemaMic => "movie_mic".pngIcon;

  static String get cinemaSeat => "movie_seat".pngIcon;

  // User-supplied replacement icon (exact path requested), swapped in for
  // the vendor's grey padlock glyph on the locked-seat state.
  static String get lockSeat => "assets/icons/locksett.png";

  static String get team1 => "team1".pngImg;

  static String get team2 => "team2".pngImg;

  static String get pkIcon => "pk_icon 1".pngIcon;

  static String get timerBBackground => "countdown_bj 1".pngImg;

  static String get noData => "no_data".pngImg;

  static String get miniRoomIcon => "mini_room_icon".pngIcon;

  static String get exitRoomIcon => "exit_room_icon".pngIcon;

  static String get chatWithUser => "chat_with_user".pngIcon;

  static String get notificationSystem => "notification_system".pngIcon;

  static String get emptyBadge => "empty_badge".pngIcon;

  static String get userAddInfo => "user_add_info".pngIcon;

  static String get micMode => "mic_mode_icon".pngIcon;

  // Generated art, not vendor art. Kept as PNG rather than SVG because the
  // glossy 3D shading is per-pixel; each one is quantised RGBA under 5 KB.
  static String get genderMale => "gender_male".pngIcon;
  static String get genderFemale => "gender_female".pngIcon;
  static String get seatRing => "seat_ring".pngIcon;
  // User-supplied replacement icon (exact path requested), swapped in for
  // the generated sofa glyph on the empty-seat state.
  static String get seatSofa => "assets/icons/7.png";
  static String get adminBadge => "admin_badge".pngIcon;
  static String get hostBadge => "host_badge".pngIcon;

  static String get previousMusic => "previous_music".pngIcon;

  static String get groupMusic => "group_music".pngIcon;

  static String get nextMusic => "next_music".pngIcon;

  static String get musicFilter => "music-filter".pngIcon;

  static String get admins => "admins".pngIcon;

  static String get pkRoom => "pk_room".pngIcon;
  static String get pkRoomNew => "pk_room".webPIcon;

  static String get hideRoom => "hide_room".pngIcon;

  static String get volumeHigh => "volume-high".pngIcon;

  static String get musicIcon => "music".pngIcon;
  static String get crown => "assets/images/crown.webp";
  static String get luckyImage =>
      "assets/images/ic_gift_broadcast_lucky_bg.webp";

  static String get themeIcon => "theme".pngIcon;

  ///charge agency
  static String get info => "info_charge_agency".pngIcon;

  static String get detailsIcon => "details".pngIcon;

  static String get chatWithHim => "chat_with_him".pngIcon;

//todo

  ///agency
  static String get coin => "coin".pngIcon;

  static String get success => "success_img".pngImg;

  static String get rich => "rich".pngImg;

  //////// Vip Profile

  static String get frameOne => "frame_top_one".pngImg;

  static String get frameOneRank => "top1".pngImg;

  static String get frameTowRank => "top2".pngImg;

  static String get frameThreeRank => "top3".pngImg;

  static String get background_ => "background_image".pngImg;

  static String get mail => "mail".pngIcon;

  static String get female => "female".pngIcon;

  static String iconsCoine = "icon_coin".pngIcon;

  static String get vip => "vip_profile".pngIcon;

  static String get family => "family_profile".pngIcon;

  static String get report => "report".pngIcon;

  static String get femaleIconInfo => "female_icon".pngIcon;

  static String get seatCpRank => "seat_cp_rank_pink".pngImg;

  static String get cpLoveAvatar => "cp_love_avatar".pngImg;

  static String get reward => "family_detail_reward_cup_ic".pngIcon;

  static String get cpContainer => "cp_container".pngImg;

  static const String backgroundCharmRAnk =
      "assets/images/background_charm_rank.png";

  static const String backgroundRoomRAnk =
      "assets/images/room_rank_background.png";
  static const String backgroundCpRAnk = "assets/images/cp_rank_background.png";

  static const String senderBackgroundRank =
      "assets/images/sender_background_rank.png";

  static const String reciverRankImage = "assets/images/reciver_image_rank.png";

  static const String roomImageRank = "assets/images/room_image_rank.png";

  static String get sendIcon => "send_icon".pngIcon;

  static String dic1 = "dice1".pngIcon;
  static String dic2 = "dice2".pngIcon;
  static String dic3 = "dice3".pngIcon;
  static String dic4 = "dice4".pngIcon;
  static String dic5 = "dice5".pngIcon;
  static String dic6 = "dice6".pngIcon;
  static String luckyNum1 = "ic_digital_1".pngIcon;
  static String luckyNum2 = "ic_digital_2".pngIcon;
  static String luckyNum3 = "ic_digital_3".pngIcon;
  static String luckyNum4 = "ic_digital_4".pngIcon;
  static String luckyNum5 = "ic_digital_5".pngIcon;
  static String luckyNum6 = "ic_digital_6".pngIcon;
  static String luckyNum7 = "ic_digital_7".pngIcon;
  static String luckyNum8 = "ic_digital_8".pngIcon;
  static String luckyNum9 = "ic_digital_9".pngIcon;

  static String sadBear = "sad-bear".pngIcon;

  static String familyBackground1 = "family_background".pngImg;

  static String familyCamera = "carme 1".pngIcon;
  static String number = "number".svgaIcon;
  static String fire2 = "fire".pngIcon;

  static String familyRank1 = "family_coin1".pngIcon;
  static String familyRank2 = "family_coin2".pngIcon;
  static String familyRank3 = "family_coin3".pngIcon;

  static String copyFamily1 = "copy_whit 1".pngIcon;

  static String rankBase = "rank_base".pngImg;

  static String adminIcon = "noun_profile".pngIcon;
  static String cpBackGround = "cp_back_ground".pngImg;
  static const String cpBackgroundImage = "assets/images/CpBackgroundimage.png";

  static String dollar1 = "dollar_symbol".pngIcon;
  static const String logo = "assets/images/logo (2).png";
  static const String superBoomIcon = "assets/images/superboom.png";
  static const String messageBackground =
      "assets/images/message bgimage.png";

  static String firstPart = "part1".pngImg;
  static String secondPart = "part2".pngImg;

  static String dollarIc = "dollar".pngIcon;

  static String homeIcon = "home_icon".pngIcon;
  static String profileIcon = "profile_icon".pngIcon;

  static String googleIcon = "google".pngImg;
  static String phone = "phone".pngImg;
  static String dateIcon = "date_icon".pngIcon;

  static String google_ = "google_intro".pngIcon;

  //onboarding
  static String onboarding1 = "onboarding1".pngImg;
  static String onboarding2 = "onboarding2".pngImg;
  static String onboarding3 = "onboarding3".pngImg;

  static String moneyDropping = "dollersdropping".jpegImg;

  static String bannerGameWinSVGA = "banner_game_win_screen".svgaImg;
  static String newGamesBannerSVGA = "new_games_banner".svgaImg;
  static String invitation = "invitation".pngIcon;
  static String googlePlayUpdate = "google-play".pngIcon;

  static String cpRelationRule2 = "cp_love_avatar".pngIcon;
  static String cpRelationRule3 = "cp_love_avatar".pngIcon;

  ///reels
  static String reelsLiked = "heart_filled".pngIcon;
  static String reelsChat = "reel_bubble_chat".pngIcon;
  static String addImasges = "add_images".pngIcon;
  static String reelsSend = "reel_share_icon".pngIcon;
  static String userProfileIcon = "user_edit_profile".pngIcon;

  static String get refreshIcon => "refresh-icon".pngIcon;

  static String get mobileValidate => "mobile_validate".pngIcon;

  static String get mention => "at-sign".pngIcon;
  static String get mentionNew => "ic_user_info_at_user".webPIcon;
  static String get messageNew => "ic_user_info_message".webPIcon;
  static String get homeNew => "ic_user_info_home".webPIcon;

  static String get userAdmin => "user".pngIcon;

  static String get hotDesign => "hot_design".pngIcon;

  static String get helRoomRank1 => "hel_room_rank_1".svgaIcon;

  static String get helRoomRank2 => "hel_room_rank_2".svgaIcon;

  static String get helRoomRank3 => "hel_room_rank_3".svgaIcon;

  static String get agencyWallet => "wallet_black_white".pngIcon;

  static String get moneyBag => "money-bag".pngIcon;

//........................
  static String get agencyStar => "star".pngIcon;

  static String get agencySuperHero => "superhero".pngIcon;

  static String get warning => "warning".pngIcon;

  static String get profileDefaultBG => "profile_default_bg".pngImg;

  static String get agencyProfileBG => "agency_profile_bg".pngImg;

  static String get shippingAgencyProfileBG =>
      "shipping_agency_profike_bg".pngImg;

  static String get familyProfileBG => "family_profile_bg".pngImg;

  static String get group => "Group 1".pngImg;

  static String get seat1 => "assets/images/seat1.png";
  static String get seat2 => "assets/images/seat2.png";
  static String get seat3 => "assets/images/seat3.png";
  static String get seat4 => "assets/images/seat4.png";
  static String get seat5 => "assets/images/seat5.png";
  static String get seat6 => "assets/images/seat6.png";
  static String get seat7 => "assets/images/seat7.png";
  static String get seat8 => "assets/images/seat8.png";
  static String get dateModeSeat1 => "assets/images/date_mode_seat1.png";
  static String get dateModeSeat2 => "assets/images/date_mode_seat2.png";
  static String get roomPkDizuo => "assets/images/room_pk_dizuo3.png";
  static String get superBoomBanner => "assets/images/super_boom_banner.png";
  static String get winBubble => "assets/images/win-bubble.png";
  static String get luckyBoxNum7 => "assets/images/7.png";
  static String get luckyBoxNum8 => "assets/images/8.png";
  static String get luckyBoxWinner => "assets/images/lucky_box_winner.png";
  static String get decorateGameRecord =>
      "assets/images/decorate_gamerecord.png";
  static String get pkAggBackground => "assets/images/agg.webp";
  static String get usersIcon24 => "assets/icons/icons8-users-24.png";
  static String get cancelIcon50 => "assets/icons/icons8-cancel-50.png";
  static String get acceptIcon128 => "assets/icons/icons8-accept-128.png";
  static String get inviteBg => "assets/icons/inviteBg.png";

  static String get brick => "img_1".pngImg;

  static String get paper => "img_2".pngImg;

  static String get scissors => "img_3".pngImg;

  static String get rpsGameIcon => "rps_game_icon".pngIcon;

  static String get number12 => "number-12".pngIcon;

  static String get dices => "dices".pngIcon;

  static String get closeLuckyBox => "close_lucky_box".pngImg;

  static String get openLuckyBox => "open_lucky_box".pngImg;

  static String get badLucky => "bad_luck".gifImg;

  static String get luckyBox => "lucky_box".pngImg;

  static String get bgLuckyBox => "lucky_box_background".pngImg;

  static String get sendBackground => "send_lucky_box_botton".pngImg;

  static String get backgroundMusicDialog => "backgroun_music_dialog".pngImg;

  static String get rankCharmFrame1 => "frame".pngImg;
  static String get rankCharmFrame2 => "frame (1)".pngImg;
  static String get rankCharmFrame3 => "frame (2)".pngImg;
  static String get rankGamesFrame1 => "frame (3)".pngImg;
  static String get rankGamesFrame2 => "frame (4)".pngImg;
  static String get rankGamesFrame3 => "frame (5)".pngImg;
  static String get rankRoomFrame1 => "frame (6)".pngImg;
  static String get rankRoomFrame2 => "frame (7)".pngImg;
  static String get rankRoomFrame3 => "frame (8)".pngImg;
  static String get rankWealthFrame1 => "frame (9)".pngImg;
  static String get rankWealthFrame2 => "frame (10)".pngImg;
  static String get rankWealthFrame3 => "frame (11)".pngImg;

  // UI Icons
  static String get cpTop1BorderImg => "ui_icons/cp_top1_border_img".pngIcon;
  static String get bgIntro => "ui_icons/login_top_bg".webPIcon;
  // Bundled level / charm glyphs, used when the panel has no per-tier art.
  static String get icLevelBadge => "ui_icons/ic_level".webPIcon;
  static String get icCharmBadge => "ui_icons/me_charm".webPIcon;
  static String get loginWithPhone => "ui_icons/login_24_phone".webPIcon;
  static String get homeActivityImg => "ui_icons/home_activity_img".pngIcon;
  static String get homeRankTop3BorderImg =>
      "ui_icons/home_rank_top3_border_img".pngIcon;
  static String get homeTabCreateRoom =>
      "ui_icons/home_tab_create_room".pngIcon;
  static String get homeTabRank => "ui_icons/home_tab_rank".pngIcon;
  static String get homeTaskCenterIc =>
      "ui_icons/home_task_center_ic".pngIcon;
  static String get icCoinBgV2 => "ui_icons/ic_coin_bg_v2".webPIcon;
  static String get icCostumer => "ui_icons/ic_costumer".webPIcon;
  static String get icCrystalBgV2 => "ui_icons/ic_crystal_bg_v2".webPIcon;
  static String get icDecoration => "ui_icons/ic_decoration".webPIcon;
  static String get icFamily => "ui_icons/ic_family".webPIcon;
  static String get icInviteAwards => "ui_icons/ic_invite_awards".pngIcon;
  static String get icInviteFriends => "ui_icons/ic_invite_friends".pngIcon;
  static String get icLevel => "ui_icons/ic_level".webPIcon;
  static String get icPrivacy => "ui_icons/ic_privacy".webPIcon;
  static String get icSetting => "ui_icons/ic_setting".webPIcon;
  static String get icStore => "ui_icons/ic_store".webPIcon;
  static String get meCharm => "ui_icons/me_charm".webPIcon;
  static String get mePremiumChair => "ui_icons/me_premium_chair".webPIcon;
  static String get mePremiumEmpty => "ui_icons/me_premium_empty".webPIcon;
  static String get mePremiumEntranceBg =>
      "ui_icons/me_premium_entrance_bg".pngIcon;
  static String get profileRelationshipAddCpIc =>
      "ui_icons/profile_relationship_add_cp_ic".pngIcon;
  static String get profileRelationshipBestieBg =>
      "ui_icons/profile_relationship_bestie_bg".pngIcon;
  static String get profileRelationshipCpBg =>
      "ui_icons/profile_relationship_cp_bg".pngIcon;
  static String get profileRelationshipCpCorner =>
      "ui_icons/profile_relationship_cp_corner".pngIcon;
  static String get profileRelationshipFriendBg =>
      "ui_icons/profile_relationship_friend_bg".pngIcon;
  static String get normalSearchGrayIc =>
      "ui_icons/normal_search_gray_ic".pngIcon;
}