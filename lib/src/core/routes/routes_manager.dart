import 'package:general/src/core/widgets/web_view_events.dart';
import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_badge/user_badges_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:general/src/features/agency/presentation/charge_agency/view/component/recharg_coins/view/recharge_coins_screen.dart';
import 'package:general/src/features/agency/presentation/charge_agency/view/component/withdrawal_request_screen/view/withdrawal_request_screen.dart';
import 'package:general/src/features/agency/presentation/host_agency/view/component/agency_manager_screen/view/componants/agency_memeber_charges_history_screen.dart';
import 'package:general/src/features/agency/presentation/host_agency/view/component/agency_manager_screen/view/componants/details_hosts_agency.dart';
import 'package:general/src/features/agency/presentation/host_agency/view/component/update_agency/view/update_host_agency_screen.dart';
import 'package:general/src/features/agency/presentation/host_agency/view/widgets/agency_members_history.dart';
import 'package:general/src/features/agency/presentation/host_agency/view/widgets/agency_setting_screen.dart';
import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/live_room/presentation/live_room_screen.dart';
import 'package:general/src/features/auth/domain/use_cases/change_phone_us.dart';
import 'package:general/src/features/auth/presentation/change_phone/bloc/change_number_bloc.dart';
import 'package:general/src/features/auth/presentation/change_phone/view/change_new_phone.dart';
import 'package:general/src/features/auth/presentation/country/country_page.dart';
import 'package:general/src/features/auth/presentation/forget_password_setting/reset_password/reset_password_bloc.dart';
import 'package:general/src/features/auth/presentation/forget_password_setting/view/new_password_page.dart';
import 'package:general/src/features/auth/presentation/intro/view/intro_page.dart';
import 'package:general/src/features/auth/presentation/on_boarding_screen.dart';
import 'package:general/src/features/auth/presentation/refresh/refresh_screen.dart';
import 'package:general/src/features/auth/presentation/splash/colors_bloc/colors_bloc.dart';
import 'package:general/src/features/auth/presentation/splash/config_app/config_app_bloc.dart';
import 'package:general/src/features/auth/presentation/terms_and_condition/view/privacy_policy_page.dart';
import 'package:general/src/features/chats/chats.dart';
import 'package:general/src/features/tasks/tasks.dart';
import 'package:general/src/features/groups/groups.dart';
import 'package:general/src/features/chats/presentation/activity_message/view/activity_message_page.dart';
import 'package:general/src/features/chats/presentation/chats/view/chats_page.dart';
import 'package:general/src/features/cp/presentation/cp/view/cp_page.dart';
import 'package:general/src/features/cp/presentation/cp_rank/view/cp_rank.dart';
import 'package:general/src/features/cp/presentation/cp_store/view/cp_store_page.dart';
import 'package:general/src/features/family/family.dart';
import 'package:general/src/features/family/presentation/create_family/view/create_family_intro.dart';
import 'package:general/src/features/family/presentation/family_screen/view/components/delete_family.dart';
import 'package:general/src/features/games/presentation/games/view/games_page.dart';
import 'package:general/src/features/games/presentation/ranking/rank_screen.dart';
import 'package:general/src/features/games/presentation/ranking/old_ranking/old_rank_screen.dart';
import 'package:general/src/features/home/presentation/home/view/components/filter_room_page.dart';
import 'package:general/src/features/home/presentation/search_screen/view/search_screen.dart';
import 'package:general/src/features/theme2_app/auth/intro/theme2_intro_page.dart';
import 'package:general/src/features/theme2_app/auth/login/theme2_login_page.dart';
import 'package:general/src/features/theme2_app/layout/presentation/screens/theme2_layout_page.dart';
import 'package:general/src/features/theme2_app/user_profile/presentation/screens/theme2_visitor_profile_page.dart';
import 'package:general/src/features/mall_bag/mall_bag.dart';
import 'package:general/src/features/messages/presentation/messages/view/messages_page.dart';
import 'package:general/src/features/moment/presentation/view/component/gift_list/gift_rank_screen.dart';
import 'package:general/src/features/moment/presentation/view/component/moment_content/moment_content_screen.dart';
import 'package:general/src/features/payment/presentation/view/coins_screen.dart';
import 'package:general/src/features/profile/presentation/bill_coin/view/bill_page.dart';
import 'package:general/src/features/profile/presentation/coin_seller/view/coin_seller_screen.dart';
import 'package:general/src/features/profile/presentation/exchange_diamond/view/exchange_diamond_page.dart';
import 'package:general/src/features/profile/presentation/exchange_diamond/view/rechange_diamond_page.dart';
import 'package:general/src/features/profile/presentation/exchange_diamond/view/exchange_v2_page.dart';
import 'package:general/src/features/profile/presentation/exchange_diamond/view/exchange_logs_page.dart';

import 'package:general/src/features/profile/presentation/f_f_f_v/view/page/f_f_f_screen.dart';
import 'package:general/src/features/profile/presentation/levels/view/level_page.dart';
import 'package:general/src/features/profile/presentation/levels/view/room_level_page.dart';
import 'package:general/src/features/profile/presentation/medals/view/medals_page.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/edit_info_screen/edit_profile_screen.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/add_or_delete_block/add_or_delete_block_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/view/profile_screen.dart';
import 'package:general/src/features/profile/presentation/support_people/support_screen.dart';
import 'package:general/src/features/reels/domain/entities/reel_entity.dart';
import 'package:general/src/features/reels/presentation/main_reels_page/view/main_reels_screen.dart';
import 'package:general/src/features/reels/presentation/main_reels_page/view/play_myreels_view.dart';
import 'package:general/src/features/room/presentation/component/room_header/room_activity/room_activity_screen.dart';
import 'package:general/src/features/home/data/model/my_rooms_model.dart';
import 'package:general/src/features/room/presentation/create_room/view/create_room_page.dart';
import 'package:general/src/features/room/presentation/manager/manager_get_config_key/get_config_keys_bloc.dart';
import 'package:general/src/features/room/presentation/music/view/component/music_list.dart';
import 'package:general/src/features/room/presentation/music/view/music_page.dart';
import 'package:general/src/features/room/presentation/room_handler/room_handler_screen.dart';
import 'package:general/src/features/room/presentation/super_bomb/view/widgets/super_boom_rules_screen.dart';
import 'package:general/src/features/room/presentation/theme/view/theme_dialog.dart';
import 'package:general/src/features/room/room.dart';
import 'package:general/src/features/setting/presentation/about_us/view/about_us_page.dart';
import 'package:general/src/features/setting/presentation/account_setting/bind_number/bind_number_bloc.dart';
import 'package:general/src/features/setting/presentation/account_setting/view/account_setting_page.dart';
import 'package:general/src/features/setting/presentation/account_setting/view/page/bind_number_screen.dart';
import 'package:general/src/features/setting/presentation/app_settings/app_settings_screen.dart';
import 'package:general/src/features/setting/presentation/bloc_list/bloc/block_list_bloc.dart';
import 'package:general/src/features/setting/presentation/bloc_list/block_list_screen.dart';
import 'package:general/src/features/setting/presentation/delete_account/view/delete_account_page.dart';
import 'package:general/src/features/setting/presentation/invitation/view/invit_screen_dtails.dart';
import 'package:general/src/features/setting/presentation/invitation/view/invite_bonus_screen.dart';
import 'package:general/src/features/setting/presentation/invitation/view/widgets/parent_users_screen.dart';
import 'package:general/src/features/setting/presentation/settings_screen.dart';
import 'package:general/src/features/setting/setting.dart';
import 'package:general/src/features/vip/presentation/view/vip_screen.dart';

import '../../../reels_viewer/src/share/share_internel_screen.dart';
import '../../features/profile/presentation/exchange_diamond/view/wallet_withdraw_page.dart';
import '../../features/room/presentation/share/share_room_internal_screen.dart';
import '../../features/agency/presentation/charge_agency/view/component/recharg_coins/view/records/records_screen.dart';
import '../../features/agency/presentation/search_agency_screen/view/agency_search.dart';
import '../../features/chats/presentation/chat_request/view/chat_request_page.dart';
import '../../features/chats/presentation/notification/view/notification_screen.dart';
import '../../features/chats/presentation/official_message/view/official_message_screen.dart';
import '../../features/home/presentation/banner/view/banner_screen.dart';
import '../../features/profile/presentation/bill_coin/view/coins_record_page.dart';
import '../../features/profile/presentation/bill_coin/view/diamond_record_page.dart';
import '../../features/profile/presentation/bill_coin/view/recharge_record_page.dart';
import '../../features/profile/presentation/exchange_diamond/view/rechange_coins_page.dart';
import '../../features/reels/presentation/main_reels_page/view/components/add_video_screen/edit_video.dart';

class Routes {
  static const String splash = "/";
  static const String login = "/login_page";
  static const String register = "/register_page";
  static const String addInformation = "/add_info_page";
  static const String otp = "/otp_page";
  static const String recoverPassword = "/recover_password_page";
  static const String createPassword = "/create_password_page";
  static const String layout = "/layout_page";
  static const String chatPage = "/chat_page";
  static const String profile = "/profile";
  static const String notFound = "/not_found";
  static const String searchScreen = "/search_screen";
  static const String reelsScreen = "/reels_screen";
  static const String myReelsView = "/my_reels_view";
  static const String addVideoScreen = "/add_video_screen";
  static const String fileUploaderTest = "/fileUploaderTest";
  static const String onBoardingScreen = "/on_boarding_screen";
  static const String privacyPolicyScreen = "/privacy_policy_screen";
  static const String refreshScreen = "/refresh_screen";
  static const String messages = "/messages_page";
  static const String signUpScreen = "/sign_up_screen";
  static const String editInfo = "/edit_info";
  static const String editProfile = "/edit_profile";
  static const String friendFollowing = "/f_f_f_screen";
  static const String visitor = "/visitor";
  static const String levelScreen = "/level_screen";
  static const String roomLevelScreen = "/room_level_screen";
  static const String vipPage = "/vip_page";
  static const String bannerScreen = "/banner_screen";
  static const String shareScreenInternal = "/shareScreenInternal";
  static const String shareRoomScreenInternal = "/shareRoomScreenInternal";
  static const String endedLiveScreen = "/EndedLiveScreen";

  ///family
  static const String familyScreen = "/family_screen";
  static const String createFamilyScreen = "/create_family_screen";
  static const String familyRankPage = "/family_rank_screen";
  static const String familyRequests = "/family_requests";
  static const String familyMembers = "/family_members";
  static const String deleteScreen = "/deleteScreen";
  static const String createFamilyIntro = "/create_family_intro";

  ///chat
  static const String chatPageBody = "/chat_page_body";
  static const String officialMessageScreen = "/official_message_screen";
  static const String systemMessageScreen = "/system_message_screen";
  static const String editVideoScreen = "/edit_video_screen";
  static const String fullScreenImage = "/full_screen_image";
  static const String videoPlayerScreen = "/video_player_screen";
  static const String mallScreen = "/mall_screen";
  static const String bagScreen = "/bag_screen";
  static const String coinsPage = "/coins_page";
  static const String cpStorePage = "/cpStorePage";

  ///agency
  static const String newAgencyScreen = "/new_agency_screen";
  static const String searchForAgencyScreen = "/search_for_agency_screen";
  static const String agencySearch = "/agency_search";
  static const String identitySetting = "/identity_setting";
  static const String withDrawScreen = "/withdraw_screen";
  static const String successTransferScreen = "/success_transfer_screen";

  static const String infoChargeAgencyScreen = "/info_charge_agency_screen";
  static const String detailsChargeAgency = "/details_charge_agency";
  static const String joinRequestsScreen = "/join_requests_screen";
  static const String shippingAgentRequestsDetails =
      "/shipping_agent_requests_details";
  static const String shippingAgentWithdrawel =
      "/shipping_agent_withdrawel_screen";
  static const String chargeAgencyScreen = "/charge_agency_screen";
  static const String withdrawalRequestScreen = "/withdrawal_request_screen";
  static const String hostWithdrawel = "/host_withdrawel_screen";

  ///profile
  static const String profileScreen = "/profile_screen";
  static const String userProfile = "/user_profile_screen";
  static const String vipScreen = "/vip_screen";
  static const String medalsScreen = "/medals_screen";
  static const String addMultiPicture = "/AddMultiPicture";

  ///settings
  static const String settingsScreen = "/settings_screen";
  static const String languageScreen = "/language_screen";
  static const String privacyScreen = "/privacy_screen";
  static const String privacy = "/privacy_policy_screen";
  static const String accountSettingPage = "/account_setting_screen";
  static const String deleteAccountPage = "/delete_account_screen";
  static const String problemReportsScreen = "/problem_reports_screen";
  static const String aboutUsPage = "/about_us_page";
  static const String appSettingsScreen = "/app_settings_screen";
  static const String roomScreen = "/room_screen";
  static const String liveRoomScreen = "/live_room_screen";
  static const String livesPage = "/lives_page";
  static const String roomHandlerScreen = "/room_handler_screen";
  static const String musicPage = "/music_page";
  static const String musicList = "/music_list";
  static const String musicSingleLivePage = "/Music_Single_Live_Page";
  static const String billPage = "/bill_page";
  static const String exchangeDiamondPage = "/exchange_diamond_page";
  static const String coinSellerScreen = "/coin_seller_screen";
  static const String rechargeDiamondPage = "/recharge_diamond_page";
  static const String rechargeCoindPage = "/recharge_coin_page";
  static const String tabBarViewDiamonds = "/view_diamonds";
  static const String rankScreen = "/rank_screen";
  static const String createNewPassword = "/create_new_password";
  static const String changePhoneScreen = "/change_phone_screen";
  static const String changePhoneNewScreen = "/change_phone_new_screen";
  static const String taskPage = "/task_page";
  static const String bindNumber = "/bind_number";
  static const String createRoomPage = "/create_room_page";
  static const String settingScreenRoom = "/settingScreen";
  static const String themePage = "/theme_page";
  static const String blockListScreen = "/block_list_page";
  static const String supportScreen = "/support_screen";
  static const String intro = "/intro";
  static const String editProfileNameOrBio = "/edit_profile_name_or_bio";
  static const String countriesScreen = "/countries_screen";
  static const String activityMessagePage = "/activity_message_page";

  static const String notificationScreen = "/notification_screen";
  static const String chatRequestPage = "/chatRequestPage";
  static const String webViewEvents = "/web_view_events";
  static const String cpPage = "/cpPage";
  static const String inviteScreen = "/inviteScreen";
  static const String inviteBonus = "/inviteBonus";
  static const String inviteUser = "/inviteUser";
  static const String filterRoomPage = "/filterRoomPage";
  static const String chatsPage = "/chatsPage";
  static const String groupsListScreen = "/groups_list_screen";
  static const String createGroupScreen = "/create_group_screen";
  static const String groupChatDetailScreen = "/group_chat_detail_screen";
  static const String groupViewScreen = "/group_view_screen";
  static const String groupInfoScreen = "/group_info_screen";
  static const String groupMembersScreen = "/group_members_screen";
  static const String joinGroupScreen = "/join_group_screen";
  static const String rechargeRecord = "/recharge_record";
  static const String diamondRecord = "/diamond_record";
  static const String coinsRecord = "/coins_record";
  static const String rechargeCoinsScreen = "/RechargeCoinsScreen";
  static const String recordsScreen = "/recordsScreen";
  static const String cpRank = "/cp_rank";
  static const String gamesPage = "/gamesPage";
  static const String exchangeV2Page = "/exchangeV2Page";
  static const String exchangeLogsPage = "/exchangeLogsPage";
  static const String walletWithdrawPage = "/walletWithdrawPage";
  static const String momentContent = "/momentContentPage";
  static const String updateHostAgencyScreen = "/updateHostAgencyScreen";
  static const String agencySettingScreen = "/AgencySettingScreen";
  static const String herosScreen = "/HerosScreen";
  static const String adminsScreen = "/AdminsScreen";
  static const String starsScreen = "/StarsScreen";
  static const String giftRankScreen = "/GiftRankScreen";
  static const String superBoomRulesScreen = "/SuperBoomRulesScreen";
  static const String startLive = "/LiveStreamScreen";
  static const String roomActivityScreen = "/RoomActivityScreen";
  static const String hostsAgencyDollarsRecordsScreen =
      "/HostsAgencyDollarsRecordsScreen";
  static const String agencyMemberChargesHistoryScreen =
      "/agencyMemberChargesHistoryScreen";
  static const String agencyMembersHistoryScreen =
      "/agencyMembersHistoryScreen";

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
    // ── Auth ──
      case Routes.splash:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: di<SplashBloc>()),
              BlocProvider.value(value: di<ConfigAppBloc>()),
              BlocProvider.value(value: di<ColorsBloc>()),
            ],
            child: const SplashPage(),
          ),
        );

      case Routes.login:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider.value(
            value: di<LoginBloc>(),
            child: ConstantsManager.isTheme2
                ? const Theme2LoginPage()
                : const LoginPage(),
          ),
        );

      case Routes.register:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => RegisterBloc(di<RegisterUc>())),
              BlocProvider.value(value: di<OtpBloc>()),
              BlocProvider.value(value: di<SendCodeBloc>()),
              BlocProvider.value(value: di<RecoverPasswordBloc>()),
              BlocProvider.value(value: di<LoginBloc>()),
            ],
            child: RegisterPage(
              phoneNumber: args?["poneNumber"] ?? "",
              countryName: args?["countryName"] ?? "",
              countryCode: args?["countryCode"] ?? "",
            ),
          ),
        );

      case Routes.otp:
        final params = settings.arguments as SendCodeParameter;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: di<SendCodeBloc>()),
              BlocProvider.value(value: di<RecoverPasswordBloc>()),
              BlocProvider.value(value: di<ChangePhoneBloc>()),
              BlocProvider.value(value: di<AccountBloc>()),
              BlocProvider.value(value: di<AddInformationBloc>()),
              BlocProvider.value(value: di<RegisterBloc>()),
            ],
            child: OtpPage(parameter: params),
          ),
        );

      case Routes.recoverPassword:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: di<RecoverPasswordBloc>()),
              BlocProvider.value(value: di<SendCodeBloc>()),
              BlocProvider.value(value: di<OtpBloc>()),
            ],
            child: const RecoverPasswordPage(),
          ),
        );

      case Routes.createPassword:
        final params = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider<RecoverPasswordBloc>.value(
            value: di<RecoverPasswordBloc>(),
            child: NewPasswordPage(
              code: '${params['code']}',
              phone: '${params['phone']}',
            ),
          ),
        );

      case Routes.createNewPassword:
        final params = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider<ResetPasswordBloc>.value(
            value: di<ResetPasswordBloc>(),
            child: NewRecoverPasswordPage(
              code: '${params['code']}',
              phone: '${params['phone']}',
            ),
          ),
        );

      case Routes.addInformation:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: di<AddInformationBloc>()),
              BlocProvider.value(value: di<RegisterBloc>()),
            ],
            child: const AddInformationPage(),
          ),
        );

      case Routes.intro:
        final String? error = settings.arguments as String?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ConstantsManager.isTheme2
              ? Theme2IntroPage(error: error)
              : IntroPage(error: error),
        );

      case Routes.onBoardingScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const OnBoardingScreen(),
        );

      case Routes.refreshScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RefreshScreen(),
        );

      case Routes.countriesScreen:
        final bool pramiter = settings.arguments as bool;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CountriesScreen(isEditProfile: pramiter),
        );

      case Routes.changePhoneNewScreen:
        final params = settings.arguments as SendCodeParameter;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => ChangePhoneBloc(
                  changeNumberUseCase: di<ChangeNumberUseCase>(),
                ),
              ),
              BlocProvider.value(value: di<SendCodeBloc>()),
            ],
            child: ChangeNewPhoneScreen(parameter: params),
          ),
        );

      case Routes.bindNumber:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: di<AccountBloc>()),
              BlocProvider.value(value: di<OtpBloc>()),
              BlocProvider.value(value: di<SendCodeBloc>()),
            ],
            child: const BindNumberScreen(),
          ),
        );

    // ── Layout ──
      case Routes.layout:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ConstantsManager.isTheme2
              ? const Theme2LayoutPage()
              : const LayoutPage(),
        );

    // ── Home ──
      case Routes.searchScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SearchScreen(),
        );

      case Routes.bannerScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const BannerScreen(),
        );

      case Routes.filterRoomPage:
        final param = settings.arguments as FilterRoomsParam;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => FilterRoomPage(param: param),
        );

    // ── Room ──
      case Routes.roomScreen:
        final roomPramiter = settings.arguments as RoomParameter;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => di<GetConfigKeysBloc>()),
              BlocProvider(create: (_) => di<UpdateRoomBloc>()),
            ],
            child: RoomScreen(
              userModel: roomPramiter.myDataModel,
              isHost: roomPramiter.isHost,
              isLocked: roomPramiter.isLocked,
              roomId: roomPramiter.roomId,
              ownerId: roomPramiter.ownerId,
              isGame: roomPramiter.isGame,
              isExit: roomPramiter.isExit,
              fromDynamicLink: roomPramiter.fromDynamicLink,
              gameDataEntity: roomPramiter.gameDataEntity,
              imageColorEntity: roomPramiter.imageColorEntity,
              specialIdImage: roomPramiter.specialIdImage,
            ),
          ),
        );

    // ── Live (video) room ──
      case Routes.liveRoomScreen:
        final liveParam = settings.arguments as RoomParameter;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => LiveRoomScreen(
            userModel: liveParam.myDataModel,
            roomId: liveParam.roomId,
            ownerId: liveParam.ownerId,
            isHost: liveParam.isHost,
            isLocked: liveParam.isLocked,
          ),
        );

      case Routes.roomHandlerScreen:
        final roomId = settings.arguments as String;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RoomHandlerScreen(roomId: roomId),
        );

      case Routes.createRoomPage:
      // Optional bool arg selects live-creation mode; existing no-arg callers
      // (audio create) fall through to false.
        final isLiveCreate = settings.arguments as bool? ?? false;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CreateRoomPage(isLive: isLiveCreate),
        );

    // Routes.startLive removed: go-live now opens GoLiveFlow's chooser dialog
    // (TikTok-style) — no standalone "start a show" page.
      case Routes.settingScreenRoom:
        final roomData = settings.arguments as EnterRoomModel;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SettingScreen(roomData: roomData),
        );

      case Routes.themePage:
        final param = settings.arguments as String?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ThemePage(ownerId: param ?? ''),
        );

      case Routes.musicPage:
        final param = settings.arguments as String?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MusicPage(ownerId: param ?? ''),
        );

      case Routes.musicList:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MusicListWidget(),
        );

      case Routes.roomActivityScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RoomActivityScreen(),
        );

      case Routes.superBoomRulesScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SuperBoomRulesScreen(),
        );

      case Routes.shareRoomScreenInternal:
        final roomEntity = settings.arguments as EnterRoomModel;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ShareRoomInternalScreen(roomEntity: roomEntity),
        );

    // ── Room Live (video) removed — routes intentionally unregistered.
    //    Any stray live navigation falls through to the default route. ──

    // ── Chat ──
      case Routes.chatsPage:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ChatsPage(),
        );

      case Routes.messages:
        final parameter = settings.arguments as MessagesParameter;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MessagesPage(params: parameter),
        );

    // ── Groups (Phase 7 — group management) ──
      case Routes.groupsListScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const GroupsListScreen(),
        );

      case Routes.createGroupScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CreateGroupScreen(),
        );

      case Routes.groupChatDetailScreen:
        final group = settings.arguments as GroupEntity;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => GroupChatDetailScreen(group: group),
        );

      case Routes.groupViewScreen:
        final group = settings.arguments as GroupEntity;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => GroupViewScreen(group: group),
        );

      case Routes.groupInfoScreen:
        final group = settings.arguments as GroupEntity;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => GroupInfoScreen(group: group),
        );

      case Routes.groupMembersScreen:
        final group = settings.arguments as GroupEntity;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => GroupMembersScreen(group: group),
        );

      case Routes.joinGroupScreen:
        final args = settings.arguments as JoinGroupArgs?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => JoinGroupScreen(
            args: args ?? const JoinGroupArgs(),
          ),
        );

      case Routes.systemMessageScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SystemMessagesScreen(),
        );

      case Routes.officialMessageScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const OfficialMessageScreen(),
        );

      case Routes.notificationScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const NotificationScreen(),
        );

      case Routes.chatRequestPage:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ChatRequestPage(),
        );

      case Routes.activityMessagePage:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ActivityMessagePage(),
        );

    // ── Profile ──
      case Routes.profileScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ProfilePage(),
        );

      case Routes.userProfile:
        final userProfileParameter =
        settings.arguments as UserProfileParameter?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => Theme2VisitorProfilePage(
            userId: userProfileParameter?.userId,
            userData: userProfileParameter?.userData,
            comesFromRoom: userProfileParameter?.comesFromRoom ?? false,
          ),
        );

      case Routes.editProfile:
        final dataModel =
            (settings.arguments as MyDataModel?) ?? MyDataModel.getInstance();
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => EditProfileScreen(data: dataModel),
        );

      case Routes.editProfileNameOrBio:
        final parameter = settings.arguments as EditProfileParameter;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => EditInfoScreen(params: parameter),
        );

      case Routes.addMultiPicture:
        final param = settings.arguments as bool?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => AddMultiPicture(isInProfile: param),
        );

      case Routes.friendFollowing:
        final numberPage = settings.arguments as int;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => FFFScreen(index: numberPage),
        );

      case Routes.medalsScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
              create: (context) => di<UserBadgesBloc>(),
              child: const MedalsPage()),
        );

      case Routes.levelScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LevelPage(),
        );

      case Routes.roomLevelScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RoomLevelPage(),
        );

      case Routes.supportScreen:
        final parameter = settings.arguments as SupportScreenParam;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SupportScreen(param: parameter),
        );

    // ── VIP / Coins / Payment ──
      case Routes.vipScreen:
        final param = settings.arguments as NavigateVipParameter?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => VipScreen(parameter: param),
        );

      case Routes.coinsPage:
        return MaterialPageRoute(
          settings: settings,
          // Optional initial tab index (0 = My Coins, 1 = Diamond) -- e.g.
          // the Agency screen's Wallet button opens straight to Diamond.
          builder: (_) => CoinsScreen(index: settings.arguments as int?),
        );

      case Routes.billPage:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const BillPage(),
        );

      case Routes.coinSellerScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CoinSellerScreen(),
        );

      case Routes.exchangeDiamondPage:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ExchangeDiamondPage(),
        );

      case Routes.rechargeDiamondPage:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RechargeDiamondPage(),
        );

      case Routes.rechargeCoindPage:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RechargeCoinsdPage(),
        );

      case Routes.rechargeRecord:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RechargeRecord(),
        );

      case Routes.diamondRecord:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const DiamondRecord(),
        );

      case Routes.coinsRecord:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CoinsRecord(),
        );

    // ── Reels ──
      case Routes.reelsScreen:
        final reelId = settings.arguments as String?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ReelsScreen(reelId: reelId),
        );

      case Routes.myReelsView:
        final param = settings.arguments as PlayMyReelParam;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => PlayMyReelsView(
            param: param,
            getReelsBloc: param.getReelsBloc,
            reelViewerBloc: param.reelViewerBloc,
          ),
        );

      case Routes.addVideoScreen:
        final sendVideoMessageParam = settings.arguments as SendVideoParam;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => EditVideo(
            sendVideoMessageParam: sendVideoMessageParam,
          ),
        );

      case Routes.shareScreenInternal:
        final reelEntity = settings.arguments as ReelsEntity;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ShareReelInternalScreen(reelEntity: reelEntity),
        );

    // ── Games ──
      case Routes.gamesPage:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const GamesPage(),
        );

    // ── New v2 Exchange + Withdraw (Wallet Diamond tab / Profile) ──
      case Routes.exchangeV2Page:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ExchangeV2Page(),
        );

      case Routes.exchangeLogsPage:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ExchangeLogsPage(),
        );

      case Routes.walletWithdrawPage:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const WalletWithdrawPage(),
        );

      case Routes.rankScreen:
        final parameter = settings.arguments as int;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ConstantsManager.isOldRankingUI
              ? OldRankScreen(initialIndex: parameter)
              : RankScreen(initialIndex: parameter),
        );

    // ── Moment ──
      case Routes.momentContent:
        final param = settings.arguments as MomentContentParameter;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MomentContentScreen(
            currentMoment: param.currentMoment,
            type: param.type,
            momentBloc: param.momentBloc,
            currentMomentIndex: param.currentMomentIndex,
            momentId: param.momentId,
          ),
        );

      case Routes.giftRankScreen:
        final parameter = settings.arguments as GiftRankArguments;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => GiftRankScreen(args: parameter),
        );

    // ── Family ──
      case Routes.familyScreen:
        final id = settings.arguments as String;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => FamilyScreen(familyId: id),
        );

      case Routes.createFamilyScreen:
        final createFamilyScreenParam =
        settings.arguments as CreateFamilyParam?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ManagerFamilyPage(
            data: createFamilyScreenParam?.data,
          ),
        );

      case Routes.createFamilyIntro:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CreateFamilyIntro(),
        );

      case Routes.familyRankPage:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const FamilyRankPage(),
        );

      case Routes.familyRequests:
        final id = settings.arguments as String;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => FamilyRequestsPage(id: id),
        );

      case Routes.familyMembers:
        final param = settings.arguments as MemberFamilyParam;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => FamilyMemberPage(param: param),
        );

      case Routes.deleteScreen:
        final familyId = settings.arguments as String;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SafeArea(
            child: DeleteScreen(familyId: familyId),
          ),
        );

    // ── CP ──
      case Routes.cpPage:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CpPage(),
        );

      case Routes.cpStorePage:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CpStorePage(),
        );

      case Routes.cpRank:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CpRank(),
        );

    // ── Daily tasks ──
    // Routes.taskPage existed as a constant and was already linked from Mine,
    // but had no case here, so tapping Task landed on "Route not found".
      case Routes.taskPage:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const TasksPage(),
        );

    // ── Mall / Bag ──
      case Routes.mallScreen:
        final index = (settings.arguments ?? 0) as int;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MallPage(index: index),
        );

      case Routes.bagScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const BagPage(),
        );

    // ── Settings ──
      case Routes.settingsScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SettingsScreen(),
        );

      case Routes.languageScreen:
        final isAfterSplash = settings.arguments as bool;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => LanguageScreen(isAfterSplash: isAfterSplash),
        );

      case Routes.privacyScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PrivacyScreen(),
        );

      case Routes.privacy:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PrivacyPolicyPage(),
        );

      case Routes.accountSettingPage:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => di<SendCodeBloc>(),
            child: AccountSettingPage(),
          ),
        );

      case Routes.deleteAccountPage:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const DeleteAccountPage(),
        );

      case Routes.problemReportsScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ProblemReportsScreen(),
        );

      case Routes.aboutUsPage:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AboutUsPage(),
        );

      case Routes.appSettingsScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AppSettingsScreen(),
        );

      case Routes.blockListScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: di<GetBlockListBloc>()),
              BlocProvider.value(value: di<AddOrRemoveBlock>()),
            ],
            child: const BlockListScreen(),
          ),
        );

      case Routes.inviteScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const InviteScreenDetails(),
        );

      case Routes.inviteBonus:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const InviteBonusScreen(),
        );

      case Routes.inviteUser:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ParentUsersScreen(),
        );

    // ── Agency ──
      case Routes.agencySearch:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AgencySearch(),
        );

      case Routes.newAgencyScreen:
        final agencyId = settings.arguments as String?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => AgencyManagerScreen(agencyId: agencyId),
        );

      case Routes.searchForAgencyScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SearchForAgencyScreen(),
        );

      case Routes.identitySetting:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const IdentitySetting(),
        );

      case Routes.withDrawScreen:
        final isMySalary = settings.arguments as bool;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => WithdrawScreen(isMySalary: isMySalary),
        );

      case Routes.successTransferScreen:
        final param = settings.arguments as SuccessTransferScreenParam;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SuccessTransferScreen(param: param),
        );

      case Routes.infoChargeAgencyScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const InfoChargeAgencyScreen(),
        );

      case Routes.detailsChargeAgency:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const DetailsChargeAgency(),
        );

      case Routes.joinRequestsScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const JoinRequestsScreen(),
        );

      case Routes.shippingAgentRequestsDetails:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ShippingAgentRequestsDetails(),
        );

      case Routes.withdrawalRequestScreen:
        final data = settings.arguments as ShippingAgentsFullDataEntity;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => WithdrawalRequestScreen(
            shippingAgentsFullDataModel: data,
          ),
        );

      case Routes.shippingAgentWithdrawel:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ShippingAgentWithdrawalRequestScreen(),
        );

      case Routes.chargeAgencyScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ChargeAgencyScreen(),
        );

      case Routes.hostWithdrawel:
        final param = settings.arguments as CoinsScreenParam;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => HostWithdrawelScreen(param: param),
        );

      case Routes.updateHostAgencyScreen:
        final parameter = settings.arguments as InformationAgencyEntity;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => UpdateHostAgencyScreen(data: parameter),
        );

      case Routes.agencySettingScreen:
        final initialIndex = settings.arguments as int?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => AgencySettingScreen(initialIndex: initialIndex),
        );

      case Routes.agencyMemberChargesHistoryScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AgencyMemberChargesHistoryScreen(),
        );

      case Routes.agencyMembersHistoryScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AgencyMembersHistoryScreen(),
        );

      case Routes.hostsAgencyDollarsRecordsScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HostsAgencyDollarsRecordsScreen(),
        );

      case Routes.herosScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HerosScreen(),
        );

      case Routes.starsScreen:
        final agencyId = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => StarsScreen(agencyId: agencyId),
        );

      case Routes.adminsScreen:
        final agencyId = settings.arguments as String;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => AdminsScreen(agencyId: agencyId),
        );

      case Routes.rechargeCoinsScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RechargeCoinsScreen(),
        );

      case Routes.recordsScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RecordsScreen(),
        );

    // ── WebView ──
      case Routes.webViewEvents:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => WebViewEvents(
            url: args['url'] as String,
            type: args['type'] as String,
            needLoading: args['needLoading'] ?? true,
            preloadedController:
            args['preloadedController'] as WebViewController?,
          ),
        );

    // ── Default ──
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: Center(
              child: Text('Route "${settings.name}" not found'),
            ),
          ),
        );
    }
  }
}