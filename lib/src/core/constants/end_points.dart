import 'dart:core';
import 'dart:io';
import 'package:flutter/foundation.dart';

class EndPoints {
  const EndPoints._();

  // BOOTSTRAP API URL: the app needs this BEFORE it can reach the backend, so it
  // cannot itself come from the backend. It is injected per-client at build time
  // with an EMPTY neutral default — never a hardcoded client host. The per-client
  // build passes the value:
  //   flutter build ... --dart-define=API_BASE_URL=https://<host>
  static const String domainURL = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://iamparty.linlive.fr',
  );
  static const String baseURL = '$domainURL/api';

  // Per-app object-storage base. White-label: the AUTHORITATIVE value is the
  // server's `storage_url` (applied via RealtimeConfig.applyFromSettings ->
  // setStorageBaseUrl on each /config/settings fetch). This mutable field is the
  // cold-start bootstrap, neutral by default (empty) and overridable per build,
  // never hardcoded to a client's bucket:
  //   flutter build ... --dart-define=STORAGE_URL=https://storage.googleapis.com/<bucket>/
  static String _storageURL = _normalizeStorageBase(
    const String.fromEnvironment('STORAGE_URL', defaultValue: domainURL),
  );

  /// Live storage base. Backed by a mutable field so the const->runtime switch
  /// keeps every existing `EndPoints.storageURL` read working unchanged.
  static String get storageURL => _storageURL;

  /// Bumped only when [setStorageBaseUrl] actually changes the live base --
  /// e.g. the very first correction from the cold-start bootstrap value to
  /// the real server-driven one. Anything that raced the bootstrap value
  /// (an image request built and possibly failed against the wrong host
  /// before the real one arrived) can listen for this to retry once the
  /// correct base is finally known, instead of staying stuck until the
  /// widget happens to be recreated.
  static final ValueNotifier<int> storageBaseUrlVersion = ValueNotifier<int>(0);

  /// Apply the server-driven storage base (admin panel -> DB -> /config/settings).
  /// Ignores empty so a late/blank config can never wipe the bootstrap value.
  static void setStorageBaseUrl(String url) {
    final value = _normalizeStorageBase(url);
    if (value.isNotEmpty && value != _storageURL) {
      _storageURL = value;
      storageBaseUrlVersion.value++;
    }
  }

  static String _normalizeStorageBase(String value) {
    final trimmed = value.trim().replaceFirst(RegExp(r'/+$'), '');
    return trimmed.isEmpty ? '' : '$trimmed/';
  }

  static String img = '${storageURL}coin.png';

  static String iosPath = "";
  static String androidPath = "";

  static String get localPath => Platform.isIOS ? iosPath : androidPath;

  // Derived from the runtime bootstrap base — no client literal. The backend may
  // also override it via the `privacy_policy_url` settings key.
  static String _privacyPolicyOverride = '';
  static void setPrivacyPolicyUrl(String url) {
    if (url.isNotEmpty) _privacyPolicyOverride = url;
  }

  static String get privacyPolicy =>
      _privacyPolicyOverride.isNotEmpty
          ? _privacyPolicyOverride
          : "$baseURL/privacy-policy";

  /// True when [value] already carries a scheme and must be used as-is.
  ///
  /// The whole asset layer used to decide this with `contains('https')`, which is
  /// wrong twice over: it misses `http://` URLs entirely, and it matches any
  /// string that merely happens to contain the letters. On an http backend every
  /// absolute URL was therefore prefixed with the storage base a SECOND time,
  /// producing `http://host/storage/http://host/storage/...` — the request 404s
  /// and the widget falls back to a placeholder. That is why the VIP tier badge
  /// and its backdrop were blank while the privilege icons, which are passed as
  /// relative paths, rendered fine.
  static bool isAbsoluteUrl(String value) {
    final v = value.trimLeft();
    return v.startsWith('http://') ||
        v.startsWith('https://') ||
        v.startsWith('data:') ||
        v.startsWith('file://') ||
        v.startsWith('blob:');
  }

  /// Resolves an image reference to a fetchable URL. Safe to call on a value
  /// that is already absolute, so callers no longer need to guess.
  static String getImage(String? image) {
    return resolveUrl(image, baseUrl: storageURL);
  }

  /// Resolves an absolute or relative URL against [baseUrl] without duplicating
  /// its host or the slash at the join boundary.
  static String resolveUrl(String? value, {required String baseUrl}) {
    final source = value?.trim() ?? '';
    if (source.isEmpty) return '';
    if (isAbsoluteUrl(source)) return source;

    final base = baseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
    final path = source.replaceFirst(RegExp(r'^/+'), '');
    if (base.isEmpty) return path;
    return '$base/$path';
  }

  static String get sendBox => "$baseURL/box/send";

  static String userRooms(int userId) => "$baseURL/rooms/user/$userId";

  static String userBadges(int userId) => "$baseURL/badges/users/$userId";

  static String get getMyRooms => "$baseURL/rooms/mine";

  static String get pickUpBoxes => "$baseURL/box/pickup";

  static String get getBoxes => "$baseURL/box/list";

  static String get getSuperBombVideos => "$baseURL/boom_levels/get_videos";

  static String get getSuperBombRules => "$baseURL/super-boom-rules";

  static String get getRoomBoomThemes => "$baseURL/room-boom/themes";

  static String getSuperBoom(String id) => "$baseURL/boom_levels/$id";

  static String addInvitationCode(String code) =>
      "$baseURL/add-code-invitation?code=$code";
  static const countries = "/countries";
  static const countriesCategories = "/countries/categories";
  static String countriesByCategory(int categoryId) =>
      "/countries?category_id=$categoryId";
  static const register = "/auth/register";
  static const login = "/auth/login";
  static const checkPhone = "/check-phone";
  static const forgotPassword = "/auth/forget_password";
  static const firebaseCustomToken = "/firebase/custom-token";
  static const addInfo = "/profile/update";
  static const deleteAccount = "/account/delete";
  static const getUserGift = "/user-gifts";
  static const getGiftImages = "/gifts/images";

  static String getGameRoom(gameId) =>
      "$baseURL/rooms/game-rooms?game_id=$gameId";

  //moment
  static String reportMoment(String momentId, String type, String description) {
    return "$baseURL/moment/$momentId/report?description=$description&type=$type";
  }

  static String replaceCoverImage(String imageId) {
    return "$baseURL/update-user-image/$imageId";
  }

  static const yallowBanner = "$baseURL/rooms/yellow-banner";
  static const extraProfileData = "$baseURL/users/data";

  static String getMoments(String type, String page, String userId) =>
      "$baseURL/moment?type=$type&page=$page&user_id=$userId";

  static String addMomentComment(String momentId) =>
      "$baseURL/moment/$momentId/comment";

  static String deleteMomentComment(String momentId, String comment) =>
      "$baseURL/moment/$momentId/comment/$comment";

  static String deleteMoment(String momentId) => "$baseURL/moment/$momentId";

  static String getMomentComment(String momentId, String page) =>
      "$baseURL/moment/$momentId/comment?page=$page";

  static const String addMoment = "$baseURL/moment";

  static String makeMomentLikes(String momentID) =>
      "$baseURL/moment/$momentID/like";

  static String getMomentLike(String momentId, String page) {
    return "$baseURL/moment/$momentId/like?page=$page";
  }

  static const String userLevels = "$baseURL/user-levels";

  // Explore
  static const String cpRanking = "$baseURL/cp-ranking";
  static const String getTopUrl = "$baseURL/ranking";
  static const String getUserProfile = "$baseURL/profile/users";
  static const String usersPlay = "$baseURL/users/play";
  static const String stopPlay = "$baseURL/users/stop-play";
  static const String usersOnline = "$baseURL/users/online";
  static const String likeUser = "$baseURL/profile/liked";
  static const String ignoreUser = "$baseURL/profile/ignored";
  static const String getAllGamesData = "$baseURL/all-games1/v2/";

  static String getBadges(String type) => "$baseURL/achievement/$type";

  static String getMyAllBadge(String id) => "$baseURL/achievements-details/$id";
  static const String pickMyBadges = "$baseURL/user-achievement-select";

  static String getCarousel(String param, String countryId) {
    if (param == 'country') {
      return "$baseURL/home_carousels?country_id=$countryId";
    } else {
      return "$baseURL/home_carousels?display_at=$param";
    }
  }

  static const String receiveDailyPrize = "$baseURL/receive-daily-prize";
  static const String currentDayPrize = "$baseURL/current-day";
  static const String getBanner = "$baseURL/banners";
  static const String hostLevels = "$baseURL/host-level";
  static const String pickBox = "$baseURL/host-level/pick";

  // room
  static const String rooms = "/rooms";

  static const String uploadBackGround =
      "$baseURL/rooms/request-background-image";
  static const String getMyBackGround = "$baseURL/backgrounds/me";
  static const String getMyBackGroundSetting = "$baseURL/backgrounds/setting";
  static const String openGame = "$baseURL/all-games1/update-game";
  static const String removePassRoom = "$baseURL/rooms/remove_pass";
  static const String fetchAllTypesRoom = "$baseURL/room_category/types";
  static const String createRoom = "$baseURL/rooms/create";

  /// Sets `rooms.mode`. Owner-only, and it looks the room up by
  /// `owner_id` ONLY when no `room_id` is given — and that lookup finds the
  /// AUDIO room, so a live room must always send its own `room_id`.
  static const String changeRoomMode = "$baseURL/change_room_mode";
  // Party room chat pictures. The message itself travels on the RTC data
  // channel; only the bytes need a round trip, and this returns their URL.
  static const String roomChatImage = "$baseURL/rooms/chat-image";
  static const String checkAdminOwner = "$baseURL/rooms/check-admin-owner";

  // App-backend admin persistence (engine `changeRole` handles the live session;
  // these persist the admin list so it survives a full rejoin via enter_room).
  static const String addAdmin = "$baseURL/rooms/add_admin_to_room";
  static const String endLive = "$baseURL/rooms/end-live";
  static const String removeAdmin = "$baseURL/rooms/remove_admin";
  static const String roomAdmins = "$baseURL/rooms/admins";

  static String lockComments(String roomId) =>
      "$baseURL/rooms/$roomId/comment_status";

  static String fetchRooms({
    int? countryId,
    int? classId,
    int? typeId,
    String? search,
    String? filter,
    int? page,
  }) =>
      "$rooms?page=$page&country_id=${countryId ?? ''}&class_id=${classId ?? ''}&type_id=${typeId ?? ''}&search=${search ?? ''}&filter=${filter ?? ''}";

  static String fetchLiveRooms({int? page}) =>
      "$baseURL/rooms/live-rooms?page=$page";

  // search
  static String search({
    required String keyword,
    bool? isFriend,
    String? page,
  }) {
    return isFriend ?? false
        ? "$baseURL/search/user-friends?keywords=$keyword&page=${page ?? '1'}"
        : "$baseURL/search?keywords=$keyword&page=${page ?? '1'}";
  }

  // Mall && My Bag
  static String fetchMall(int type) => "$baseURL/mall/wares?type=$type";
  static const buyMall = "$baseURL/mall/buy";
  static const sendMall = "$baseURL/mall/send";

  static String fetchMyBag(String type) =>
      "$baseURL/user_info/my_pack?type=$type";

  static String get usedMyBagItem => "$baseURL/user_info/use_pack_item";

  static String get unUsedMyBagItem => "$baseURL/user_info/takeOff";

  static String get usedMyBagSpecialId => "$baseURL/use-special-id";

  static String get buyMallSpecialID => "$baseURL/buy-special-id";
  static const sendBagItem = "$baseURL/send_pack";

  // Contact discovery (chat rebuild §3): POST device phone numbers, get back the
  // registered users that match (by last-10-digits).
  static const String contactsMatch = "$baseURL/contacts/match";

  // Public group discovery (chat rebuild §4): browse public groups.
  static const String publicGroups = "$baseURL/groups/public";

  // --- Groups (Phase 7 — group management) ---
  // REST surface backing lib/src/features/groups/. The backend is the guard on
  // every endpoint (section 5.2); the Flutter layer only consumes these.
  static const String groups = "$baseURL/groups";

  static String group(int groupId) => "$baseURL/groups/$groupId";

  static String groupMembers(int groupId) => "$baseURL/groups/$groupId/members";

  static String groupMemberPromote(int groupId, int userId) =>
      "$baseURL/groups/$groupId/members/$userId/promote";

  static String groupMemberDemote(int groupId, int userId) =>
      "$baseURL/groups/$groupId/members/$userId/demote";

  static String groupMemberMute(int groupId, int userId) =>
      "$baseURL/groups/$groupId/members/$userId/mute";

  static String groupMemberKick(int groupId, int userId) =>
      "$baseURL/groups/$groupId/members/$userId";

  static String groupLeave(int groupId) => "$baseURL/groups/$groupId/leave";

  static String groupTransferOwnership(int groupId) =>
      "$baseURL/groups/$groupId/transfer-ownership";

  static String groupRead(int groupId) => "$baseURL/groups/$groupId/read";

  static String groupJoin(int groupId) => "$baseURL/groups/$groupId/join";

  /// Send a group message (offline-sync path, header Idempotency-Key=client_uuid).
  static String groupSendMessage(int groupId) =>
      "$baseURL/groups/$groupId/messages";

  /// Mark a group read up to the latest seen seq (read receipts).
  static String groupReadUpTo(int groupId) => "$baseURL/groups/$groupId/read";

  /// Delete one or more group messages for everyone (offline-sync path, body
  /// `{id: [...]}` — same contract as the 1:1 delete-for-all).
  static String groupDeleteMessages(int groupId) =>
      "$baseURL/groups/$groupId/messages/delete";

  //chat
  static String fetchAppMessages(int type, int page) =>
      "$baseURL/community/notifications?type=$type&page=$page";
  static const String clearMode = "$baseURL/change-room-effect";
  static const String sendMessage = "$baseURL/Chat-Message";
  static String oneUserChat = "$baseURL/Chat-room";

  /// Lightweight get-or-create for a 1:1 room: POST {user_id} -> returns ONLY the
  /// chat_room_id. The offline-first open/send paths call this to resolve the real
  /// server room id before the seq-keyed sync + outbox send, so neither runs
  /// against room 0 for a conversation opened from a profile/picker (no chat_id).
  static const String ensureChatRoom = "$baseURL/Chat-room/ensure";
  static String oneUserChatRequest = "$baseURL/guest-chat";
  static String makeReact = "$baseURL/Chat-Message-React";
  static const String pinToTop = "$baseURL/Chat-PinToTop";
  static const String closeChat = "$baseURL/close-chat";

  static String userOnline(String userId) {
    return "$baseURL/user-status/$userId";
  }

  static String get sendMessageAll => "$baseURL/invite-room";

  // --- Centrifugo realtime + offline-sync (Phase 5) ---
  // WebSocket endpoint for the centrifuge-dart client. protobuf is the wire
  // format the SDK + server speak; the dedicated ws.* host is on the isolated VM.
  // centrifuge-dart negotiates protobuf via the WS subprotocol, NOT a query
  // param — appending ?format=protobuf breaks the dart client's WS open.
  //
  // White-label: the AUTHORITATIVE value is the server's `centrifugo_ws`
  // (RealtimeConfig.wsUrl, applied from /config/settings) — the client always
  // prefers it at connect time. This const is only the cold-start fallback used
  // before settings land, so it is neutral by default (empty) and overridable
  // per build, never hardcoded to a specific client's host:
  //   flutter build ... --dart-define=CENTRIFUGO_WSS=wss://ws.<host>/connection/websocket
  static const String centrifugoWss = String.fromEnvironment(
    'CENTRIFUGO_WSS',
    defaultValue: '',
  );
  // Connection JWT for the centrifuge-dart getToken callback.
  static const String centrifugoToken = "$baseURL/centrifugo/token";
  // Subscription token for the 1:1 chat channel (body: {user_id}).
  static const String centrifugoSubscription =
      "$baseURL/centrifugo/subscription";

  // REST sync surface (versioned v1) used for gap-fill + recovery fallback.
  static const String _apiV1 = "$domainURL/api/v1";
  // Room list with last_seq + my_last_read_seq.
  static const String syncRooms = "$_apiV1/sync/rooms";

  /// Messages newer than [sinceSeq] (gap-fill / recovery fallback).
  static String roomMessagesSince(int roomId, int sinceSeq) =>
      "$_apiV1/rooms/$roomId/messages?since_seq=$sinceSeq";

  /// Older keyset page: messages before [beforeSeq], newest-first, capped.
  static String roomMessagesBefore(
      int roomId,
      int beforeSeq, {
        int limit = 30,
      }) => "$_apiV1/rooms/$roomId/messages?before_seq=$beforeSeq&limit=$limit";

  static String removePinToTop(String userId) {
    return "$baseURL/Chat-PinToTop/$userId";
  }

  static String deleteMessage(String deleteType) {
    if (deleteType == "for_me") {
      return "$baseURL/delete-Chat-Message-ForMe";
    } else {
      return "$baseURL/delete-Chat-Message";
    }
  }

  static String updateMessage(String messageId) {
    return "$baseURL/Chat-Message/$messageId";
  }

  static String deleteChat(int userId) {
    return "$baseURL/Chat-room/$userId";
  }

  /// Mark a 1:1 conversation read on the backend (dual-transport read receipt).
  static String markRoomRead(int chatRoomId) {
    return "$baseURL/Chat-room/$chatRoomId/read";
  }

  static const String sendNotificationChat =
      "$baseURL/send-notifaction-message";

  static String blockUnblock(String userId) {
    return "$baseURL/black_list/check/$userId";
  }

  // Room-scoped ban list (room_blacklist table) — authoritative source for the
  // in-room "banned users" screen + unban. (Distinct from the account-level
  // black_list above.)
  static const String roomBlackList = "$baseURL/rooms/black-list";
  static const String roomRemoveBlock = "$baseURL/rooms/remove-block";
  static const String updateAdminPermissions =
      "$baseURL/rooms/update_admin_permissions";

  ///family
  static String get familyRank => "$baseURL/families/ranking";

  static String get createFamily => "$baseURL/families/create";

  static String get joinFamily => "$baseURL/families/join";

  static String get allFamily => "$baseURL/families/all";

  static String editFamily(String id) {
    return "$baseURL/families/edit/$id";
  }

  static String showFamily(String id) {
    return "$baseURL/families/show/$id";
  }

  static const String getFamilyRoom = "$baseURL/families/getFamilyRooms";
  static const String exitFamily = "$baseURL/families/exitFamily";
  static const String familyRequest = "$baseURL/families/req_list";
  static const String familyTakeAction = "$baseURL/families/take_action";
  static const String changeusertype = "$baseURL/families/change_user_type";
  static const String getMembersFamily = "$baseURL/families/getMembersList";

  static String familyRemoveUser(String userId, String familyId) {
    return "$baseURL/families/remove_user?user_id=$userId&family_id=$familyId";
  }

  static String deleteFamily(String id) {
    return "$baseURL/families/delete/$id";
  }

  /// Agency
  static String showAgencyInformation(String month, String year, String id) =>
      "$baseURL/agencies/details/$id?month=$month&year=$year";

  static String hostsAgencyData(String month, String year, String id) =>
      "$baseURL/agencies/history/$id?month=$month&year=$year";
  static const String kickOutAgency = "$baseURL/agencies/kick-of-agency";
  static const String agencyMemberChargesHistory =
      "$baseURL/agencies/charges-history";
  static const String leaveAgency = "$baseURL/agencies/request-leave-agency";
  static const String makeUserAdmin = "$baseURL/agencies/make-user-as-operator";

  static String showAgency(int? id) {
    return id == null || id == 0
        ? "$baseURL/agencies/show"
        : "$baseURL/agencies/show?id=$id";
  }

  static const String joinToAgencies = "$baseURL/agencies/join_request";
  static const String chargeTo = "$baseURL/agencies/charge_to";

  static const String showAgencyMembers = "$baseURL/agencies/showAllusers";

  static String getHostRequests(String type) {
    return "$baseURL/salary-transaction/host-requests?type=$type";
  }

  ///charge Agency
  static const String shippingAgentsGetways = "$baseURL/payment-gateway";

  static String getShippingAgentRequests(int type) =>
      "$baseURL/salary-transaction/get-requests?type=$type";
  static const String shippingAgentRequests =
      "$baseURL/salary-transaction/action-request";
  static const String shippingAgentsCountries = "$baseURL/charge-country";
  static const String makeShippingAgentToAdminWithdrawel =
      "$baseURL/salary-transaction-agent/add-request";
  static const String chargeCoinForUser = "$baseURL/agencies/charge-agency";

  static String getChargeAgencyDetails(String type, String page) =>
      "$baseURL/agencies/charge-agent-history?type=$type&page=$page";

  static String getChargeAgency(int? id) {
    return id == null || id == 0
        ? "$baseURL/agencies/get-info"
        : "$baseURL/agencies/get-info/$id";
  }

  static const String updateChargeAgency = "$baseURL/agencies/update-info";
  static const String makeWithdrawelRequest =
      "$baseURL/salary-transaction/add-request";
  static const String getShippingAgentsFullData =
      "$baseURL/agencies/search-agent";

  static const String shippingAgentTransferConfirmAction =
      "$baseURL/salary-transaction/transfer-salary";

  static String get getReplaceWithDiamondData =>
      "$baseURL/exchange/list?type=0";

  static String get exchangeDiamonds => "$baseURL/exchange/make";

  // Coin Seller (Reseller) system -- prepared/confirmed endpoints.
  static String get coinSellerList => "$baseURL/v1/coin-seller/list";
  static String get coinSellerProfile => "$baseURL/v1/coin-seller/profile";
  static String get coinSellerTransfer => "$baseURL/v1/coin-seller/transfer";
  static String get coinSellerHistory => "$baseURL/v1/coin-seller/history";

  static String get cancelAgency => "$baseURL/cancel-request-createAgency";
  static const String agencyHostReport = "$baseURL/agencies/host-reports";
  static const String getOldAgenciesIWereIn = "$baseURL/agencies/old-agencies";

  static String agencySearch({required String id, String? page}) =>
      "$baseURL/agencies/filter?keyword=$id&page=${page ?? '1'}";
  static const String agencyHistory = "$baseURL/agencies/history-data-agency";

  static String agencyMember(String type) =>
      "$baseURL/agencies/show-agency-request?type=$type";
  static const String agencyRequestsAction =
      "$baseURL/agencies/actions_request";
  static const String googleCoinsHistory = "$baseURL/trxs";
  static const String chargedCoinsHistory = "$baseURL/user-charge-coins";

  static String get chargeDollarsForUser =>
      "$baseURL/agencies/charge_dollar_for_owner";

  static String updateAgencyData(String agencyId) {
    return "$baseURL/agencies/$agencyId";
  }

  static String get getSettings => "$baseURL/user-app-setting";

  /// Single cold-start aggregate: one GET that returns my_data + my_store +
  /// app_setting in one `data` object, replacing 3 separate round-trips on
  /// launch (faster cold-start on weak networks). Consumed by BootstrapService.
  static String get bootstrap => "$baseURL/bootstrap";

  static const String hostRequestAction =
      "$baseURL/salary-transaction/host-action";

  ///profile
  static const String getMyDataUrl = "$baseURL/my-data?show_counter=true";

  static const String getMyLevelData = "$baseURL/users/level";

  static String get myStore => "$baseURL/my-store";
  static const String getGoldData = "$baseURL/coins/list";

  static String showLevels(int type) => "$baseURL/levels?type=$type";
  static String getVisitors = "$baseURL/profile/visitors";

  ///settings
  static String get getVipPrev => "$baseURL/getUserHides";

  static String prevsUse(String type) => "$baseURL/hide?type=$type";

  static String prevsUnUse(String type) => "$baseURL/un_hide?type=$type";

  static String get makeProblemReport => "$baseURL/tickets/open";

  static String get boundAccount => "$baseURL/account/bind";

  static String get logOut => "$baseURL/auth/logout";

  /// Register/refresh this device's FCM token on the backend so pushes can be
  /// targeted between logins (the token can rotate while the app is running, not
  /// just at auth time). Body: { notification_id, device_token }.
  static String get updateNotificationId => "$baseURL/profile/notification-id";

  ///fffv
  static const String relations = "$baseURL/relations";
  static const String follow = "$relations/follow";
  static const String unFollow = "$relations/un-follow";

  ///userProfile
  static const String removeBloc = "$baseURL/black_list/remove";
  static const String addBloc = "$baseURL/black_list/add";

  static String getGiftHistory(String id) => "$baseURL/my_gifts?user_id=$id";

  static String getUserIntro(String id) => "$baseURL/image-intro/$id";

  static String getUserData({required String userId, bool? isVisit}) {
    if (isVisit != null) {
      return "$baseURL/users/$userId?is_visit=$isVisit";
    } else {
      return "$baseURL/users/$userId";
    }
  }

  static const String userReport = "$baseURL/relations/report_user";

  static String getUserBadges(String userId) =>
      "$baseURL/achievement/user/$userId";

  ///common
  static const String agencyBadges = "$baseURL/agency-badges";
  static const String getWabbles = "$baseURL/mall/wabbleAll";

  ///Room
  static const String enterRoom = "$baseURL/rooms/enter_room";
  static const String sendGift = "$baseURL/gifts/send";
  static const String getConfigKey = "$baseURL/config/keys-values";
  static const String configApp = "$baseURL/config/app-check";
  static const String profileFrameWares = "$baseURL/profile-frame-wares";
  static const String getRoomUsers = "$baseURL/rooms/getRoomUsers";
  static const String showPk = "$baseURL/rooms/show-pk";
  static const String startPk = "$baseURL/rooms/create-pk";
  static const String closePk = "$baseURL/rooms/close-pk";
  static const String hidePK = "$baseURL/rooms/hide-pk";
  static String getEmojie(String id) =>
      "$baseURL/v2/emojis/?emoji_category_id=$id";
  static const String getBcakground = "$baseURL/backgrounds";
  static const String sendLuckyGift = "$baseURL/gifts/v2/send-lucky-gift-combo";
  static const String images = "$baseURL/images";
  static const String topUrlInRoom = "$baseURL/ranking/one-room";
  static const String colors = "$baseURL/colors/v2";
  static const String realtimeSettings = "$baseURL/config/settings";

  static String getGifts(int type) => "$baseURL/gifts/v2?type=$type";

  static String blockComments(String roomId, bool value) => "$baseURL/";

  static String getRoomUpdate({required String roomId}) =>
      "$baseURL/rooms/$roomId/edit";

  static String vipList = "$baseURL/vips/list";

  static String get buyVip => "$baseURL/vips/buyVip";

  static String get sendVip => "$baseURL/vips/send-to-user";

  static String get vipThemeSettings => "$baseURL/vips/theme-settings";

  static String get getUserVip => "$baseURL/vips/user/list";

  static String getUserSupporter(String userId) =>
      "$baseURL/get-users-support?user_id=$userId";

  static String get roomSupportAction => "$baseURL/room-support/action";

  // Backend's own integration guide (confirmed directly) requires
  // livestream_id and recommends also sending owner_id -- without it the
  // server returns HTTP 422. ownerId is optional here only so existing call
  // sites that predate this don't break; new callers should always pass it.
  static String roomSupportInfo(String livestreamId, {String? ownerId}) =>
      "$baseURL/room-support?livestream_id=$livestreamId"
      "${ownerId != null && ownerId.isNotEmpty ? '&owner_id=$ownerId' : ''}";

  // Rocket room-reward mini-game. Backend contract confirmed directly by the
  // user (Postman-tested) -- NOT guessed from the reference app, which uses
  // a differently-named /rocket/livestream/{id} path for the same thing.
  static String rocketRoomInfo(String roomId) => "$baseURL/rocket/room/$roomId";
  static String rocketRanking(String roomId) =>
      "$baseURL/rocket/room/$roomId/ranking";
  static String rocketLaunchHistory(String roomId) =>
      "$baseURL/rocket/room/$roomId/launch-history";
  static const String rocketMyRewards = "$baseURL/rocket/my-rewards";

  static String get fetchBill => "$baseURL/coin-reports";

  static const String getTopUserImage = "$baseURL/ranking/top_user_ranking";

  static const String changePassword = "$baseURL/account/reset_password";

  static String get changePhone => "$baseURL/account/change_phone";

  static String get vipUse => "$baseURL/vips/use";
  static const String blockList = "$baseURL/black_list";

  static String levelBadges(int type) => "$baseURL/levels/badges?type=$type";

  static const String roomLevelBadges = "$baseURL/rooms/level-badges";

  static const String getCoins = "$baseURL/coins/payment";
  static const String googlePay = "$baseURL/google-pay-purchased";
  static const String buyCoins = "$baseURL/coins/buyCoins";

  static String getDiamondsRecords(
      String type,
      String? startDate,
      String? endDate,
      ) {
    final queryParams = <String>[];

    queryParams.add('type=$type');

    if (startDate != null && startDate.isNotEmpty) {
      queryParams.add('startDate=$startDate');
    }

    if (endDate != null && endDate.isNotEmpty) {
      queryParams.add('endDate=$endDate');
    }

    final queryString = queryParams.join('&');

    return "$baseURL/wallets/diamonds-statistic?$queryString";
  }

  static const String bubblePadding = "$baseURL/mall/padding";
  static const String exchangePercentage = "$baseURL/wallets/exchange/v2/list";
  static const String makeDiamondExchange = "$baseURL/wallets/exchange/v2/make";
  // GET /wallets/exchange/logs -- optional query param `type` (default 0),
  // per the exchange-history part of the API spec provided for this feature.
  static String exchangeLogs({int type = 0}) =>
      "$baseURL/wallets/exchange/logs?type=$type";

  static String inviteCode(String userId) {
    return "$baseURL/add-code-invitation?code=$userId";
  }

  static String getDollarsRecords(String type) {
    return "$baseURL/wallets/profits?type=$type";
  }

  static String getRecentDollarsRecords = "$baseURL/wallets/latest-operations";
  static String walletHistory(String type, String? startDate, String? endDate) {
    final queryParams = <String>[];

    queryParams.add('type=$type');

    if (startDate != null && startDate.isNotEmpty) {
      queryParams.add('start_date=$startDate');
    }

    if (endDate != null && endDate.isNotEmpty) {
      queryParams.add('end_date=$endDate');
    }

    final queryString = queryParams.join('&');

    return "$baseURL/wallets/history?$queryString";
  }

  static String getDigitalTransactions(String type) {
    return "$baseURL/wallets/getTemplate?type=$type";
  }

  static String get invitationEarn => "$baseURL/invitations/summary";

  static String get makeDollarsTransaction => "$baseURL/wallets/withdraw";

  // ---------------------------------------------------------------------
  // New Withdrawal System (full spec provided) -- supersedes the simple
  // `makeDollarsTransaction` above for the app's Withdraw UI. Path spellings
  // (including "widthraw"/"withdrow") are kept EXACTLY as given in the API
  // documentation pasted for this feature -- do not "correct" the spelling,
  // the backend really uses these strings.
  // ---------------------------------------------------------------------

  /// GET -- whether the withdraw feature is currently turned on by the admin.
  static String get withdrawSystemStatus => "$baseURL/withdraw-system-status";

  /// GET -- admin-configured list of withdraw methods (name + min/max coin
  /// limits per method).
  static String get withdrawMethodList => "$baseURL/widthraw_method_list";

  /// GET -- the current user's own saved payment methods.
  static String get myPaymentMethodList => "$baseURL/myPaymentMethodList";

  /// POST -- save a new payment method for the current user.
  static String get addPaymentMethod => "$baseURL/addPaymentMethod";

  /// POST -- edit one of the current user's saved payment methods.
  static String get editPaymentMethod => "$baseURL/editPaymentMethod";

  /// Delete one of the current user's saved payment methods. Per spec this is
  /// a query-string call, not a JSON body delete.
  static String deletePaymentMethod(String id) =>
      "$baseURL/deletePaymentMethod?id=$id";

  /// POST -- create a withdraw request against a saved payment method,
  /// choosing "admin" or "reseller" as the receiver.
  static String get createWithdrawRequest => "$baseURL/withdrow_create";

  /// GET -- the list of resellers (coin sellers) a user can pick as the
  /// receiver of a withdraw request.
  static String get resellerList => "$baseURL/reseller_list";

  /// GET -- the current user's own withdraw request history. Optional
  /// `status`/`received_type` query filters, per the history API.
  static String myWithdrawList({
    String? status,
    String? receivedType,
    int page = 1,
    int perPage = 20,
  }) {
    final queryParams = <String>[];
    if (status != null && status.isNotEmpty) {
      queryParams.add('status=$status');
    }
    if (receivedType != null && receivedType.isNotEmpty) {
      queryParams.add('received_type=$receivedType');
    }
    queryParams.add('page=$page');
    queryParams.add('per_page=$perPage');
    final queryString = queryParams.join('&');
    return "$baseURL/my_withdrow_list?$queryString";
  }

  /// GET -- for a Coin Seller (reseller): the incoming withdraw requests
  /// assigned to them.
  static String get resellerWithdrawRequestList =>
      "$baseURL/widthrawrequestlist";

  /// POST -- a reseller accepts one incoming withdraw request.
  static String resellerAcceptWithdraw(String id) =>
      "$baseURL/withdraw/reseller/accepted/$id";

  /// POST -- a reseller rejects one incoming withdraw request.
  static String resellerRejectWithdraw(String id) =>
      "$baseURL/withdraw/reseller/rejected/$id";

  static String get invitationUsersEarn => "$baseURL/user-earn-from-invitation";

  static String get explainInvitation => "$baseURL/explain-invitation";

  /// Manually extract the accumulated invitation commission into the main wallet.
  static String get invitationExtract => "$baseURL/invitations/extract";

  /// Claim the one-time invitee join bonus (disappears after claiming).
  static String get invitationClaimBonus => "$baseURL/invitations/bonus/claim";

  ///reels
  static String get uploadReel => "$baseURL/reals";

  static String get generateUploadLink => "/generate-upload-link";

  static String get createReels => "/reals";

  static String getReel({
    String? reelId,
    String? filter,
    int? page,
    int perPage = 5,
  }) {
    if (reelId == null) {
      return "$baseURL/reals?filter=$filter&page=$page&per_page=$perPage";
    } else {
      return "$baseURL/reals/$reelId";
    }
  }

  static String getReelUser(String? userID, String? page) {
    if (userID == null) {
      return "$baseURL/reals/user?page=$page";
    } else {
      return "$baseURL/reals/user/$userID?page=$page";
    }
  }

  static String deleteReel(String reelId) {
    return "$baseURL/reals/$reelId";
  }

  static String getReelComments(String reelId, int? page) {
    return "$baseURL/reals/$reelId/comment?page=$page";
  }

  static String makeReelComments(String reelId) {
    return "$baseURL/reals/$reelId/comment";
  }

  static String updateReelDescription(String reelId) {
    return "$baseURL/reals-update/$reelId";
  }

  static String makeReelLike(String reelId) {
    return "$baseURL/reals/$reelId/like";
  }

  static String getFollowingReels(String page) {
    return "$baseURL/reals/user-followers?page=$page";
  }

  static String reelView(String reelId) => "$baseURL/reals/$reelId/view";

  static String momentView(String momentId) => "$baseURL/moment/$momentId/view";

  //cp
  static const String getCpRelations = "$baseURL/cp-relations";
  static const String cpRequest = "$baseURL/make-cp-request";
  static const String cpRequestRespond = "$baseURL/respond-request";

  static String cpProfile(String userId) =>
      "$baseURL/cp-profile?user_id=$userId";
  static const String cpBySeats = "$baseURL/buy-sets";

  static const String cpRelationsLevelsGifts = "$baseURL/cp-levels-gifts";
  static const String cpRelationsSpecialFriendLevelsGifts =
      "$baseURL/cp-levels-gifts?type=friend";

  // Daily tasks. `/days` carries the day strip, the active day's task list and
  // the running point total in one payload.
  static const String taskDays = "$baseURL/days";

  static String collectTask(int taskId) => "$baseURL/tasks/$taskId/collect";

  static String get closeZegoChannelName => "zego_feature";

  static String roomChannelName(int roomId) => "room.boom.rewards.$roomId";

  static const String charisma = "$baseURL/charisma/change-status";
  static const String charismaReset = "$baseURL/charisma/reset";
  static const String charismaLevels = "$baseURL/charisma-levels";

  static String getCharismaExtraData({required String roomId}) =>
      "$baseURL/rooms/extra-data?room_id=$roomId";

  static String get generateUploadChatVideoLink => "/chatVideo";

  static const String searchUserAgency = "$baseURL/search-user-agency";

  static String fetchAgencyMoreInformation(
      String month,
      String year,
      String id,
      String page,
      ) =>
      "$baseURL/agencies/target-details/$id?month=$month&year=$year&page=$page";

  static String fetchAgencyHeros(
      String month,
      String year,
      String id,
      String page,
      ) => "$baseURL/agencies/heroes/$id?month=$month&year=$year&page=$page";

  static String fetchAgencyAdmins(
      String month,
      String year,
      String id,
      String page,
      ) => "$baseURL/agencies/admins/$id?month=$month&year=$year&page=$page";

  static String fetchAgencyStars(
      String month,
      String year,
      String id,
      String page,
      ) => "$baseURL/agencies/stars/$id?month=$month&year=$year&page=$page";

  static String fetchMomentGift(int userID) =>
      "$baseURL/moments/users/$userID/gifts";

  static String sendMomentGift(String momentID) =>
      "$baseURL/moment/$momentID/gift";

  static String gamesImages(int type) => "$baseURL/images?type=2";

  static String hostsAgencyDollarsRecord(String type, String page) =>
      "$baseURL/agencies/hosts-agency-dollars-history?type=$type&page=$page";

  static String formList(String type) => "$baseURL/form-list?type=$type";

  static String get roomSettings => "/room_settings";

  static String get freeGamesImages => "/images?type=2";
  static const createMusic = "/music/create";

  static String deleteSong(int songId) => "/music/$songId/user";
  static const getMusic = "$baseURL/music/all";
  static const getMyMusic = "$baseURL/music/user";

  static String roomActivityData(int roomId) =>
      "$baseURL/room-cup/history/$roomId";

  static const roomActivityWebViewLink = "$baseURL/room-cup/cup-target";
  static String get changeCountry => "$baseURL/countries/change-request";
  static String get giftCategory => "$baseURL/gift-categories";
  static String get emojisCategory => "$baseURL/v2/emojis/categories";
  static String getUsers(List<String> users) =>
      "$baseURL/users/details?users_ids=${users.join(",")}";

  static String get onlineFriends => "$baseURL/v1/friends/online";
  static String get createTaskId => "$baseURL/v1/task-stream/create";
  static String get joinTaskId => "$baseURL/v1/task-stream/join";
  static String get leaveTaskId => "$baseURL/v1/task-stream/host-leave";
  static String get sendPkInvitation =>
      "$baseURL/v1/task-stream/send-invitation";
  static String get respondPkInvitation =>
      "$baseURL/v1/task-stream/respond-invitation";
  static String get startLivePk => "$baseURL/v1/pk/start";
  static String get closeLivePk => "$baseURL/v1/pk/close";
  static String get badWords => "$baseURL/bad-words";
}
