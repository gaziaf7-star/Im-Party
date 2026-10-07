import 'dart:async';
import 'dart:io';
import 'package:general/src/core/realtime/realtime_bootstrap.dart';
import 'package:general/src/features/agency/presentation/charge_agency/view/component/host_withdrawel_screen/bloc/get_setting_manager/get_setting_bloc.dart';
import 'package:general/src/features/agency/presentation/charge_agency/view/component/host_withdrawel_screen/bloc/host_requests_manager/host_requests_bloc.dart';
import 'package:general/src/features/auth/presentation/splash/config_app/config_app_bloc.dart';
import 'package:general/src/features/chats/chats.dart';
import 'package:general/src/features/chats/presentation/chats/view/chats_page.dart';
import 'package:general/src/features/theme2_app/profile/presentation/screens/theme2_profile_page.dart';
import 'package:general/src/features/moment/presentation/bloc/moment_bloc/moment_bloc.dart';
import 'package:general/src/features/moment/presentation/bloc/moment_bloc/moment_event.dart';
import 'package:general/src/features/moment/presentation/view/moment_page.dart';
import 'package:general/src/features/theme2_app/home/presentation/view/theme2_home_page.dart';
import 'package:general/src/features/theme2_app/layout/presentation/widgets/theme2_bottom_nav_bar.dart';
import 'package:general/src/features/reels/presentation/main_reels_page/view/main_reels_screen.dart';
import 'package:general/src/features/reels/presentation/main_reels_page/bloc/get_reels/get_reels_bloc.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_badge/user_badges_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_user_badges/get_user_badges_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_user_badges/get_user_badges_event.dart';
import 'package:general/src/features/profile/presentation/profile/view/profile_screen.dart';
import 'package:general/src/features/layout/view/layout_shell_mixin.dart';

/// Theme2 Layout Page - Complete layout with Theme2 bottom nav bar.
/// Uses backend theme colors (ColorManager.primary, bottomNavColor, etc.)
class Theme2LayoutPage extends StatefulWidget {
  const Theme2LayoutPage({super.key});

  @override
  State<Theme2LayoutPage> createState() => _Theme2LayoutPageState();
}

class _Theme2LayoutPageState extends State<Theme2LayoutPage>
    with WidgetsBindingObserver, LayoutShellMixin<Theme2LayoutPage> {
  final PageStorageBucket _bucket = PageStorageBucket();
  int _currentIndex = 0;

  /// Indices that have been visited at least once. An [IndexedStack] keeps every
  /// child mounted; to avoid initializing tabs the user never opens (their
  /// `initState` network kicks / TabControllers), unvisited tabs render a
  /// placeholder and are built lazily on first visit, then stay alive.
  final Set<int> _loadedIndices = {0};

  /// The ordered page builders for the bottom-nav body. The order is built
  /// dynamically so the index→page mapping stays consistent with the nav bar
  /// order and the first-load dispatch across all flag combinations:
  ///   [Home, (Moment if isShowMoment), (Reels if isReelsVisible), Chat, Profile]
  /// Chat sits immediately AFTER Reels so that in RTL (first child = rightmost)
  /// Chat renders to the LEFT of Reels while Reels stays centered.
  List<Widget Function()> get _pageBuilders {
    return [
      () => const Theme2HomePage(),
      if (ConstantsManager.isShowMoment) () => const MomentPage(),
      if (ConstantsManager.isReelsVisible) () => const ReelsScreen(),
      () => const ChatsPage(),
      if (ConstantsManager.isShowMoment)
        () => const Theme2ProfilePage()
      else
        () => const ProfilePage(),
    ];
  }

  /// Computes the bottom-nav index of a logical page given the active flags.
  /// Kept in one place so the page list, nav bar, and first-load dispatch all
  /// agree. -1 means the page is not present.
  int get _momentIndex => ConstantsManager.isShowMoment ? 1 : -1;
  int get _reelsIndex {
    if (!ConstantsManager.isReelsVisible) return -1;
    return ConstantsManager.isShowMoment ? 2 : 1;
  }

  int get _chatIndex {
    var index = 1;
    if (ConstantsManager.isShowMoment) index++;
    if (ConstantsManager.isReelsVisible) index++;
    return index;
  }

  int get _profileIndex => _chatIndex + 1;

  /// Builds the IndexedStack children once. Visited tabs render their real page
  /// (kept alive between switches); unvisited tabs render an empty placeholder
  /// until first opened.
  List<Widget> _buildPages() {
    final builders = _pageBuilders;
    return List<Widget>.generate(
      builders.length,
      (index) =>
          _loadedIndices.contains(index) ? builders[index]() : const SizedBox.shrink(),
    );
  }

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      ConstantsManager.devicePlatform = StringManager.android;
    } else if (Platform.isIOS) {
      ConstantsManager.devicePlatform = StringManager.ios;
    }

    // Phase 1: Critical data
    if (!di<FetchUserDataBloc>().state.reqState.isLoaded) {
      di<FetchUserDataBloc>().add(
        const FetchMyDataEvent(isLoading: false, initRealtime: true),
      );
    }

    // Phase 2: After first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!di<ConfigAppBloc>().state.requestState.isLoaded) {
        di<ConfigAppBloc>().add(
          ConfigAppEvent(
            devicePLATFORM: ConstantsManager.devicePlatform,
            versionApp: ConstantsManager.appVersionCode.toString(),
          ),
        );
      } else {
        checkForUpdate();
      }

      // Gift categories and emoji categories moved OFF cold-start — the gift
      // sheet (live_gift_screen / gift_room_page) and the emoji widget self-load
      // them on first open.

      Methods.safeSubscribeToTopic();

      // Own admin badges + achievement medals -- warmed here unconditionally
      // (not gated to visiting the profile tab) so they're already cached by
      // the time a chat message is sent from inside a room, even if the
      // user goes straight from login into a room without ever opening
      // their profile first.
      di<GetUserBadgesBloc>().add(
        GetUserBadgesData(id: MyDataModel.getInstance().id ?? 0),
      );
      if (di<UserBadgesBloc>().state.myStates != RequestState.loaded) {
        di<UserBadgesBloc>().add(const GetMyBadges());
      }

      // Realtime / offline-first chat bootstrap (Centrifugo socket + outbox/
      // media drain). The main shell is the live layout for every user
      // (isTheme2 == true), so without this call the socket was never opened
      // and message retries never ran.
      startRealtimeBootstrap();
    });

    WidgetsBinding.instance.addObserver(this);
  }

  Future<bool> _onWillPop() async {
    if (_currentIndex != 0) {
      // Pause reels if we are leaving the reels tab via the back button.
      if (ConstantsManager.isReelsVisible &&
          _currentIndex == _reelsIndex &&
          di.isRegistered<GetReelsBloc>()) {
        di<GetReelsBloc>().add(const PauseAllControllersEvent());
      }
      ConstantsManager.isReelsTabActive = false;
      setState(() => _currentIndex = 0);
      return false;
    }
    final shouldClose = await showDialog<bool>(
      context: context,
      builder: (context) => AnimatedDialog(
        title: StringManager.note.tr(),
        description: StringManager.areYouSureExit.tr(),
        onTap: () async {
          if (di<RoomStateManager>().isInRoom) {
            final navContext = SafeNavigator.context;
            if (navContext == null) {
              Navigator.of(context).pop(true);
              return;
            }
            await di<RoomStateManager>().exitRoom(
              navContext,
              callback: () => Navigator.of(context).pop(true),
            );
          } else {
            Navigator.of(context).pop(true);
          }
        },
      ),
    );
    return shouldClose ?? false;
  }

  void _handleNavTap(int index) {
    final bool isFirstVisit = !_loadedIndices.contains(index);

    // Keep the reels' play/pause logic in sync with this layout (it can't read
    // LayoutBloc, which this layout never drives). Set BEFORE the resume below.
    ConstantsManager.isReelsTabActive = index == _reelsIndex;

    // Reels lives in an IndexedStack (kept alive once opened) and its own
    // auto-pause hook is wired to LayoutBloc, which this layout never drives.
    // So pause/resume the reels controllers here on tab change to stop the
    // video/audio playing in the background after leaving the reels tab.
    if (ConstantsManager.isReelsVisible &&
        di.isRegistered<GetReelsBloc>()) {
      if (_currentIndex == _reelsIndex && index != _reelsIndex) {
        di<GetReelsBloc>().add(const PauseAllControllersEvent());
        // Immediately snap each scroll controller to its current page so the
        // in-flight scroll animation doesn't continue firing PageChangedEvent
        // (which would resume video) after the Reels tab loses focus.
        final rs = di<GetReelsBloc>().state;
        for (final ctrl in [
          rs.scrollCtrl,
          rs.followingScrollCtrl,
          rs.myReelsScrollCtrl,
        ]) {
          // positions.length==1 (not hasClients): during a tab switch the same
          // controller can be attached to two live PageViews for a frame; both
          // ctrl.page and jumpToPage route through _positions.single and would
          // throw "Too many elements".
          if (ctrl.positions.length == 1) {
            ctrl.jumpToPage(ctrl.page?.round() ?? 0);
          }
        }
      } else if (index == _reelsIndex && _currentIndex != _reelsIndex) {
        di<GetReelsBloc>().add(const ResumeCurrentControllerEvent());
      }
    }

    // Switch first so the (now-mounted, kept-alive) target tab paints
    // immediately; defer the per-tab first-load network kicks to the next frame
    // so they never compete with the transition. With IndexedStack keeping tabs
    // alive, these first-loads fire once per tab (guarded by first-visit), not
    // on every tap.
    setState(() {
      _loadedIndices.add(index);
      _currentIndex = index;
    });
    HomePage.isFirstTime = false;

    if (isFirstVisit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _dispatchTabFirstLoad(index);
      });
    }
  }

  /// Fires the per-tab first-load bloc events. Called once per tab on first
  /// visit, after the switch has painted. WHICH data loads is unchanged from the
  /// original synchronous handler.
  void _dispatchTabFirstLoad(int index) {
    if (!mounted) return;

    final chatIndex = _chatIndex;
    final momentIndex = _momentIndex;
    final profileIndex = _profileIndex;

    if (index == chatIndex) {
      if (di<FetchUsersChatBloc>().state.reqState.isIdle) {
        di<FetchUsersChatBloc>().add(const GetChatUsersEvent(userId: ''));
      }
      di<FetchUsersChatBloc>()
          .add(const AddChatUsersListenerEvent(userId: ''));
    }

    if (index == momentIndex && ConstantsManager.isShowMoment) {
      if (!di<MomentBloc>().state.reqState.isLoaded) {
        di<MomentBloc>().add(const FetchMomentData());
      }
    }

    if (index == profileIndex) {
      di<GetUserBadgesBloc>().add(
        GetUserBadgesData(id: MyDataModel.getInstance().id ?? 0),
      );
      // Own achievement medals -- warmed here the same way the admin badges
      // above are, so they're already cached by the time a chat message is
      // sent (comment badge row reads UserBadgesBloc.state.myBadge).
      if (di<UserBadgesBloc>().state.myStates != RequestState.loaded) {
        di<UserBadgesBloc>().add(const GetMyBadges());
      }
      if (!di<MyStoreBloc>().state.reqState.isLoaded) {
        di<MyStoreBloc>().add(const GetMyStoreEvent(isLoading: false));
      }
      if (!di<GetSettingBloc>().state.state.isLoaded) {
        di<GetSettingBloc>().add(const GetSettingsEvent());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConfigAppBloc, ConfigAppState>(
      bloc: di<ConfigAppBloc>(),
      listener: (context, state) {
        // A fresh app-check may switch the UI variant away from jo_live; the
        // variant is consumed only at route-generation time, so re-navigate to
        // rebuild the correct shell instead of staying on this one.
        reactToVariantChange();
        checkForUpdate();
      },
        child: BlocListener<HostRequestsBloc, HostRequestsState>(
            bloc: di<HostRequestsBloc>(),
            listener: (context, state) =>
                handleHostRequestsState(state, context),
            child: PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) async {
                if (didPop) return;
                if (await _onWillPop()) SystemNavigator.pop();
              },
              child: Scaffold(
                body: PageStorage(
                  bucket: _bucket,
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _buildPages(),
                  ),
                ),
                bottomNavigationBar: Theme2BottomNavBar(
                  currentIndex: _currentIndex,
                  onTap: _handleNavTap,
                ),
              ),
            ),
          ),
    );
  }
}
