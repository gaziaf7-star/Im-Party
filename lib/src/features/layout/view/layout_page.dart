import 'dart:math' as math;
import 'dart:async';
import 'package:general/src/core/widgets/on_multiable_tab.dart';
import 'package:general/src/features/home/presentation/home/bloc/fetch_my_room_data_manager/fetch_my_room_data_bloc.dart';
import 'package:general/src/features/home/presentation/home/bloc/fetch_my_room_data_manager/fetch_my_room_data_state.dart';
import 'package:general/src/features/room/presentation/room_controller.dart';
import 'package:general/src/features/live_room/presentation/go_live_flow.dart';
import 'dart:io';
import 'package:general/src/core/realtime/realtime_bootstrap.dart';
import 'package:general/src/features/agency/presentation/charge_agency/view/component/host_withdrawel_screen/bloc/get_setting_manager/get_setting_bloc.dart';
import 'package:general/src/features/agency/presentation/charge_agency/view/component/host_withdrawel_screen/bloc/host_requests_manager/host_requests_bloc.dart';
import 'package:general/src/features/auth/presentation/splash/config_app/config_app_bloc.dart';
import 'package:general/src/features/chats/chats.dart';
import 'package:general/src/features/chats/presentation/chats/view/chats_page.dart';
import 'package:general/src/features/games/presentation/games/view/games_page.dart';
import 'package:general/src/features/moment/presentation/bloc/moment_bloc/moment_bloc.dart';
import 'package:general/src/features/moment/presentation/bloc/moment_bloc/moment_event.dart';
import 'package:general/src/features/moment/presentation/view/moments_hub_page.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_badge/user_badges_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_user_badges/get_user_badges_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_user_badges/get_user_badges_event.dart';
import 'package:general/src/features/profile/presentation/profile/view/profile_screen.dart';
import 'package:general/reels_viewer/reels_viewer.dart';
import 'package:general/src/features/reels/presentation/main_reels_page/view/main_reels_screen.dart';
import 'package:general/src/features/layout/view/layout_shell_mixin.dart';

class LayoutPage extends StatefulWidget {
  const LayoutPage({super.key});

  @override
  State<LayoutPage> createState() => _LayoutPageState();
}

class _LayoutPageState extends State<LayoutPage>
    with WidgetsBindingObserver, LayoutShellMixin<LayoutPage> {
  final PageStorageBucket _bucket = PageStorageBucket();

  Widget _buildCurrentPage(int index) {
    switch (index) {
      case 0:
        return const HomePage();
      case 1:
        return ConstantsManager.isReelsVisible
            ? const GamesPage()
            : const GamesPage();
      case 2:
        return const ChatsPage();
      case 3:
      // Moments and Reels are one destination now — see MomentsHubPage.
        return ConstantsManager.isShowMoment
            ? const MomentsHubPage()
            : const ProfilePage();
      case 4:
        return const ProfilePage();
      default:
        return const HomePage();
    }
  }

  @override
  void initState() {
    // Draw behind the system navigation bar so the bottom bar's image
    // continues under the phone's back/home buttons.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (ConstantsManager.homeScreen == 'audio room' ||
        ConstantsManager.homeScreen == 'live') {
      di<LayoutBloc>().add(const ChangeIndexEvent(currentIdex: 0));
    } else if (ConstantsManager.homeScreen == 'chat') {
      di<LayoutBloc>().add(const ChangeIndexEvent(currentIdex: 2));
      if (di<FetchUsersChatBloc>().state.reqState.isIdle) {
        di<FetchUsersChatBloc>().add(const GetChatUsersEvent(userId: ''));
      }
      di<FetchUsersChatBloc>().add(
        const AddChatUsersListenerEvent(userId: ''),
      );
    } else if (ConstantsManager.homeScreen == 'moment' &&
        ConstantsManager.isShowMoment) {
      di<LayoutBloc>().add(const ChangeIndexEvent(currentIdex: 3));
      if (!di<MomentBloc>().state.reqState.isLoaded) {
        di<MomentBloc>().add(const FetchMomentData());
      }
    } else if (ConstantsManager.homeScreen == 'reels' &&
        ConstantsManager.isReelsVisible) {
      di<LayoutBloc>().add(const ChangeIndexEvent(currentIdex: 1));
    } else if (ConstantsManager.homeScreen == 'game' &&
        !ConstantsManager.isReelsVisible) {
      di<LayoutBloc>().add(const ChangeIndexEvent(currentIdex: 1));
    } else {
      di<LayoutBloc>().add(const ChangeIndexEvent(currentIdex: 0));
    }

    if (Platform.isAndroid) {
      ConstantsManager.devicePlatform = StringManager.android;
    } else if (Platform.isIOS) {
      ConstantsManager.devicePlatform = StringManager.ios;
    }

    // Phase 1: Critical data needed immediately
    if (!di<FetchUserDataBloc>().state.reqState.isLoaded) {
      di<FetchUserDataBloc>().add(
        const FetchMyDataEvent(isLoading: false, initRealtime: true),
      );
    }

    // Phase 2: Important but can wait for first frame
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

      // Stream token is now fetched on-demand when entering a room
      // via _ensureRoomCredentials in RoomStateManager.
      // No need to pre-fetch at layout init.

      // Gift categories and emoji categories moved OFF cold-start — the gift
      // sheet (live_gift_screen / gift_room_page) and the emoji widget self-load
      // them on first open.

      Methods.safeSubscribeToTopic();

      // Own admin badges + achievement medals -- warmed here unconditionally
      // (not gated to visiting the Mine tab) so they're already cached by
      // the time a chat message is sent from inside a room, even if the
      // user goes straight from login into a room without ever opening
      // their profile first.
      di<GetUserBadgesBloc>().add(
        GetUserBadgesData(id: MyDataModel.getInstance().id ?? 0),
      );
      if (di<UserBadgesBloc>().state.myStates != RequestState.loaded) {
        di<UserBadgesBloc>().add(const GetMyBadges());
      }

      // Realtime / offline-first chat bootstrap (Phase 7 part B). Started here
      // because LayoutPage mounts only after login + DI is complete. Guarded so
      // a not-yet-deployed Centrifugo server (Phase 8) can never break the app —
      // the drift local-first + REST-delta paths stand alone without it. The
      // 1:1 chat keeps running on legacy realtime untouched.
      startRealtimeBootstrap();
    });

    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  Future<bool> _onWillPop() async {
    final bloc = di<LayoutBloc>();
    if (bloc.state.currentIndex != 0) {
      bloc.add(const ChangeIndexEvent(currentIdex: 0));
      return false;
    } else {
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
                callback: () {
                  Navigator.of(context).pop(true);
                },
              );
            } else {
              Navigator.of(context).pop(true);
            }
          },
        ),
      );
      return shouldClose ?? false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConfigAppBloc, ConfigAppState>(
      bloc: di<ConfigAppBloc>(),
      listener: (context, state) {
        // A fresh app-check may carry a new UI variant selected from the
        // admin panel. The variant is consumed only at route-generation /
        // first-build time, so re-navigate to rebuild the correct shell.
        reactToVariantChange();
        checkForUpdate();
      },
      child: BlocListener<HostRequestsBloc, HostRequestsState>(
        bloc: di<HostRequestsBloc>(),
        listener: (context, state) =>
            handleHostRequestsState(state, context),
        child: BlocBuilder<LayoutBloc, LayoutState>(
          bloc: di<LayoutBloc>(),
          buildWhen: (prev, curr) => prev.currentIndex != curr.currentIndex,
          builder: (context, state) {
            return BlocBuilder<FetchUserDataBloc, FetchUserDataState>(
                bloc: di<FetchUserDataBloc>(),
                buildWhen: (prev, curr) =>
                prev.userEntity?.isGameAvailable !=
                    curr.userEntity?.isGameAvailable,
                builder: (context, userState) {
                  final isGameAvailable =
                      userState.userEntity?.isGameAvailable ?? false;
                  return PopScope(
                    canPop: false,
                    onPopInvokedWithResult: (didPop, result) async {
                      if (didPop) return;
                      bool isShouldPop = await _onWillPop();
                      if (isShouldPop) {
                        SystemNavigator.pop();
                      }
                    },
                    child: Scaffold(
                      // The bottomNavigationBar box below is taller than the
                      // visible white bar itself — the go-live button
                      // overhangs above the bar's top edge, and that overhang
                      // strip has nothing painted behind it except right
                      // where the circular button sits. Flutter falls back to
                      // the Scaffold's own backgroundColor for the rest of
                      // that strip, which defaults to the theme's near-black
                      // — that's the thin black bar spotted right above the
                      // nav, on every page (not just Home). White matches the
                      // bar itself so the overhang reads as one continuous
                      // white surface instead of a black sliver poking
                      // through.
                      backgroundColor: Colors.white,
                      body: PageStorage(
                        bucket: _bucket,
                        child: _buildCurrentPage(state.currentIndex),
                      ),
                      // Flat, single-level bar — the go-live button no
                      // longer breaks the top edge/overhangs above it; it now
                      // renders as a normal inline slot inside
                      // _BottomNavigationBar's own Row, at the same height as
                      // every other tab.
                      // Bottom bar background comes from the admin panel's
                      // nav region (`regions.nav`: color / gradient / image);
                      // white when the panel sends none.
                      // The bar's background also runs under the phone's
                      // system back/home buttons; only the icons stay above.
                      bottomNavigationBar: _SystemInsetBar(
                        child: _BottomNavigationBar(
                          index: state.currentIndex,
                          isGameAvailable: isGameAvailable,
                        ),
                      ),
                    ),
                  );
                });
          },
        ),
      ),
    );
  }
}

/// One entry in the bottom bar.
///
/// The bar used to build its items with a chain of `if` conditions and then
/// translate between "visible index" and "bloc index" using hand-rolled
/// arithmetic (`if (navIndex == 0) return 0; return navIndex + 1;`). That only
/// held while exactly one slot could be hidden — adding the centre go-live slot
/// breaks it. Describing the tabs as data and deriving both mappings from the
/// same list removes the arithmetic entirely.
/// Bar geometry, shared by the bar itself and the raised button so the two can
/// never disagree about where the top edge is.
// 68 was too short once combined with the bigger icon + label — it caused a
// "BOTTOM OVERFLOWED" render error (the tab's content taller than the bar).
// 72 is the smallest height that fits the current icon-slot/gap/label/padding
// stack below without overflowing, while still being shorter than the
// original 80.
const double _kBarHeightBase = 72;
// Shrunk from 58 to fit inline inside the bar's own height now that the
// button no longer overhangs above it.
const double _kGoLiveDiameter = 46;

double get _kBarHeight => _kBarHeightBase.h;

/// The nav's dedicated selected-state color — a fixed pink→purple gradient.
/// Shared by the tab-select circle/label AND the go-live button's own
/// background "card", so both read as the same brand accent.
const List<Color> _kNavSelectedGradient = [
  Color(0xFFA510FB),
  Color(0xFF5204C6),
];

/// The primary action of the app: start broadcasting.
///
/// Wears the panel's primary gradient (`app_primary_color_grad`) so it stays
/// brand-driven, with a ring in the bar's own colour so the button reads as
/// punched through the bar rather than floating over it.
class _GoLiveButton extends StatelessWidget {
  const _GoLiveButton({this.icon});

  /// Admin-panel icon replacing the default circle glyph.
  final NavIconUrls? icon;

  /// The go-live control, moved here from the home header.
  ///
  /// The BlocBuilder, the tap body and the loaded-state guard are the ORIGINAL
  /// ones, unchanged: only the glyph and the position are new. Two details make
  /// that verbatim copy necessary rather than a shared helper:
  ///
  ///  * GoLiveFlow.showStartDialog needs a context that still has a
  ///    Navigator/Scaffold above it to open its bottom sheet from — the
  ///    button's own context is the safe one to pass down through the tap
  ///    callback.
  ///  * The original only EXISTS once the room data is loaded, so it can never
  ///    be pressed too early. Keeping that means an unloaded state shows no
  ///    button instead of a dead one.
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchMyRoomDataBloc, FetchMyRoomDataState>(
      bloc: di<FetchMyRoomDataBloc>(),
      buildWhen: (prev, curr) => prev.requestState != curr.requestState,
      builder: (context, state) {
        if (state.requestState != RequestState.loaded) {
          return const SizedBox.shrink();
        }
        return MultiTapCard(
          onTap: () async {
            final utdCtrl = RoomData.instance.utdController;
            if (utdCtrl != null && utdCtrl.minimize.isMinimizing) {
              final navContext = SafeNavigator.context;
              if (navContext == null) return;
              await di<RoomStateManager>().exitRoom(navContext);
            }

            if (ConstantsManager.isShowLive) {
              if (di<RoomStateManager>().isInRoom) {
                final navContext = SafeNavigator.context;
                if (navContext == null) return;
                await di<RoomStateManager>().exitRoom(
                  navContext,
                  callback: () {
                    GoLiveFlow.showStartDialog(context, state.rooms);
                  },
                );
              } else {
                GoLiveFlow.showStartDialog(context, state.rooms);
              }
            } else {
              Methods.handleRoomEntry(context, state.rooms?.audio);
            }
          },
          child: icon != null ? _panelGlyph(icon!) : _circle(),
        );
      },
    );
  }

  /// Wears the nav's own pink->purple select gradient (matching the tab
  /// select-circle/label) with a ring in the bar's own colour. Was
  /// ColorManager.primaryDecoration (the panel's admin-driven brand
  /// gradient) — switched to the fixed [_kNavSelectedGradient] on request,
  /// so this card always matches the tab select color regardless of what
  /// the panel's primary color is set to. Sized to sit inline inside the
  /// bar's own row now (no longer a raised/overhanging button).
  Widget _panelGlyph(NavIconUrls icon) {
    final url = icon.active.isNotEmpty ? icon.active : icon.inactive;
    return ImageViewWidget(
      url: url,
      height: 60.h,
      width: 60.h,
      boxFit: BoxFit.contain,
    );
  }

  Widget _circle() {
    return Container(
      height: _kGoLiveDiameter.h,
      width: _kGoLiveDiameter.h,

      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ColorManager.bottomNavColor,
          border: Border.all(color: Colors.white,width: 2)
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _kNavSelectedGradient,
          ),
        ),
        child: Center(
          // Was AssetsManager.navGoLiveIcon ("hel_tab_live".svgIcon ->
          // assets/icons/hel_tab_live.svg) — that plain .svg never existed
          // (only the .svga animated version does, via streamIconActive),
          // which is why this button rendered as a blank circle. Fixed asset
          // pair for this button (static PNG here), same as the other four
          // tabs — shown as-is, no tint, since it already carries its own
          // finished color.
          child: ImageWidget(
            image: AssetsManager.streamIconUnActive,
            height: 22.h,
            width: 22.w,
          ),
        ),
      ),
    );
  }
}

class _NavTab {
  const _NavTab({
    required this.blocIndex,
    required this.activeAsset,
    required this.inactiveAsset,
    required this.label,
    this.panelIcon,
  });

  /// Icons from the admin panel (`nav_icons`); when set they replace the
  /// bundled assets below.
  final NavIconUrls? panelIcon;

  /// Index this tab selects in [LayoutBloc] — NOT its position in the bar.
  final int blocIndex;

  /// Bundled active icon of this tab.
  final String activeAsset;

  /// Plain PNG/WebP icon shown while this tab is NOT selected. Rendered
  /// as-is (no color tint) since these already carry their own design color.
  final String inactiveAsset;

  final String label;
}

/// Bloc index of the tab that carries the unread-message badge.
const int _kChatBlocIndex = 2;

class _BottomNavigationBar extends StatelessWidget {
  const _BottomNavigationBar({
    required this.index,
    required this.isGameAvailable,
  });

  final int index;
  final bool isGameAvailable;

  /// Position of the go-live slot: dead centre of the bar, which is where the
  /// raised button in [LayoutPage] is drawn.
  int _liveSlot(int tabCount) => tabCount ~/ 2;

  List<_NavTab> _tabs() {
    // Fixed order: Home · Moment · [go live] · Chat · Mine. The admin panel's
    // `nav_icons` are matched by BAR POSITION (slot 2 is the centre go-live
    // button, see [_centerPanelIcon]); a tab whose slot is empty keeps its
    // bundled icon.
    final tabs = _assetTabs();
    if (ColorManager.navIcons.isEmpty) return tabs;
    const slotForBlocIndex = {0: 0, 3: 1, _kChatBlocIndex: 3, 4: 4};
    return [
      for (final t in tabs)
        _NavTab(
          blocIndex: t.blocIndex,
          activeAsset: t.activeAsset,
          inactiveAsset: t.inactiveAsset,
          label: t.label,
          panelIcon: ColorManager.navIconAt(slotForBlocIndex[t.blocIndex] ?? -1),
        ),
    ];
  }

  /// Panel icon for the centre go-live button (`nav_icons` slot 2).
  static NavIconUrls? get _centerPanelIcon => ColorManager.navIconAt(2);

  List<_NavTab> _assetTabs() {

    return [
      _NavTab(
        blocIndex: 0,
        activeAsset: AssetsManager.homeIconActive,
        inactiveAsset: AssetsManager.homeIcon,
        label: StringManager.home.tr(),
      ),
      // Slot 1 belongs to nothing now. Reels moved inside the Moments hub, and
      // Games is reached from the home header — keeping a conditional tab here
      // meant that the moment the panel enabled game mode the bar silently grew
      // to six slots and pushed the go-live button off centre.
      //
      // The bar is fixed at Home / Moment / [go live] / Chat / Mine so the centre
      // is always the exact centre. blocIndex 1 still renders if something
      // navigates to it; it just has no tab of its own.
      // Order is Home · Moment · [go live] · Chat · Mine. Moment sits second and
      // Chat fourth per the owner's layout; blocIndex is unchanged, so every
      // route, page and panel nav-icon slot still maps to the same tab.
      if (ConstantsManager.isShowMoment)
        _NavTab(
          blocIndex: 3,
          activeAsset: AssetsManager.momentIconActive,
          inactiveAsset: AssetsManager.momentIcon,
          label: StringManager.moment.tr(),
        ),
      _NavTab(
        blocIndex: _kChatBlocIndex,
        activeAsset: AssetsManager.chatIconActive,
        inactiveAsset: AssetsManager.chatIcon,
        label: StringManager.chat.tr(),
      ),
      _NavTab(
        blocIndex: 4,
        activeAsset: AssetsManager.profileIconActive,
        inactiveAsset: AssetsManager.profileIcon,
        label: StringManager.mine.tr(),
      ),
    ];
  }

  void _onTabSelected(int blocIndex) {
    // Leaving reels: stop playback rather than letting it run behind another tab.
    if (index == 1 && blocIndex != 1 && ConstantsManager.isReelsVisible) {
      if (di.isRegistered<GetReelsBloc>()) {
        di<GetReelsBloc>().add(const PauseAllControllersEvent());
      }
    }

    if (blocIndex == 1 && ConstantsManager.isReelsVisible) {
      if (index != 1 && di.isRegistered<GetReelsBloc>()) {
        di<GetReelsBloc>().add(const ResumeCurrentControllerEvent());
      }
    }

    _primeTabData(blocIndex);

    di<LayoutBloc>().add(ChangeIndexEvent(currentIdex: blocIndex));
    HomePage.isFirstTime = false;
  }

  /// First-visit fetches for the tab being opened.
  void _primeTabData(int blocIndex) {
    if (blocIndex == _kChatBlocIndex) {
      if (di<FetchUsersChatBloc>().state.reqState.isIdle) {
        di<FetchUsersChatBloc>().add(const GetChatUsersEvent(userId: ''));
      }
      di<FetchUsersChatBloc>().add(
        const AddChatUsersListenerEvent(userId: ''),
      );
      return;
    }

    if (blocIndex == 3) {
      if (!di<MomentBloc>().state.reqState.isLoaded &&
          ConstantsManager.isShowMoment) {
        di<MomentBloc>().add(const FetchMomentData());
      }
      return;
    }

    if (blocIndex == 4) {
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
    final tabs = _tabs();
    final liveSlot =
    ConstantsManager.isAudioRoomsEnabled ? _liveSlot(tabs.length) : -1;

    // Bar position -> tab, so a tap resolves without any index arithmetic.
    final byPosition = <int, _NavTab>{};
    final rowChildren = <Widget>[];

    for (var i = 0; i < tabs.length; i++) {
      if (rowChildren.length == liveSlot) {
        // The go-live button now renders INLINE as its own slot (was a
        // reserved blank space under a raised button drawn separately above
        // the bar) — same Expanded flex as every other tab, so it sits
        // flush with them instead of floating above.
        rowChildren.add(Expanded(
            child: Center(child: _GoLiveButton(icon: _centerPanelIcon))));
      }
      final tab = tabs[i];
      byPosition[rowChildren.length] = tab;
      final bool isSelected = tab.blocIndex == index;
      rowChildren.add(
        Expanded(
          child: _NavTabItem(
            tab: tab,
            isSelected: isSelected,
            onTap: () => _onTabSelected(tab.blocIndex),
            badge: tab.blocIndex == _kChatBlocIndex
                ? const _UnreadMessageBadge()
                : null,
          ),
        ),
      );
    }

    return Row(children: rowChildren);
  }
}

/// A single bottom-bar destination: icon + label, animating between its
/// plain/inactive look and a colored "select" state.
///
/// Tapping a tab spins its icon once like a flipping coin (as in im_Chat).
/// Needs to be a StatefulWidget because the spin animation is real state
/// that must survive rebuilds; it restarts on every tap.
class _NavTabItem extends StatefulWidget {
  const _NavTabItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  final _NavTab tab;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? badge;

  @override
  State<_NavTabItem> createState() => _NavTabItemState();
}

class _NavTabItemState extends State<_NavTabItem>
    with SingleTickerProviderStateMixin {
  static const Duration _kDuration = Duration(milliseconds: 300);

  /// One-shot "coin flip" (as in im_Chat): the icon spins once around its
  /// vertical axis and swells while it turns. Plays on every tap.
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  Widget _spinning(Widget child) {
    return AnimatedBuilder(
      animation: _spin,
      child: child,
      builder: (context, child) {
        final double v = _spin.value;
        final double angle = Curves.easeInOutCubic.transform(v) * 2 * math.pi;
        final double swell = 1 + 0.25 * math.sin(v * math.pi);
        return Transform.scale(
          scale: swell,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012) // perspective
              ..rotateY(angle),
            child: child,
          ),
        );
      },
    );
  }

  /// Icon-only bar: every tab shows its active icon (admin panel's, or the
  /// bundled one) -- no separate inactive artwork, as in im_Chat. The
  /// selected one sits a little larger.
  Widget _iconOnly(_NavTab tab, bool isSelected) {
    final panel = tab.panelIcon;
    final activeUrl = panel == null
        ? ''
        : (panel.active.isNotEmpty ? panel.active : panel.inactive);
    final Widget icon = activeUrl.isNotEmpty
        ? ImageViewWidget(
            url: activeUrl,
            height: 46.h,
            width: 46.h,
            boxFit: BoxFit.contain,
          )
        : ImageWidget(image: tab.inactiveAsset, height: 40.h, width: 40.h);
    return AnimatedScale(
      duration: _kDuration,
      curve: Curves.easeOutBack,
      scale: isSelected ? 1.15 : 1.0,
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tab = widget.tab;
    final bool isSelected = widget.isSelected;
    // Admin-panel icon mode: big icons, no labels.
    final bool iconsOnly = ColorManager.navIcons.isNotEmpty;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // Every tap spins the icon (also re-tapping the selected tab).
        _spin.forward(from: 0);
        widget.onTap();
      },
      child: Padding(
        // Bottom padding > top padding — the whole icon+label block sits
        // centered inside this taller box, which nudges it upward within
        // the bar instead of sitting dead-center/low. Kept small on purpose:
        // icon slot (44h) + gap (2h) + label (~16h) + this padding must all
        // fit inside _kBarHeightBase (72h) or the bar overflows.
        padding: EdgeInsets.only(top: 2.h, bottom: 6.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fixed-size slot for the icon/circle, sized to the LARGEST the
            // circle ever gets. The circle inside still grows/shrinks with
            // t2, but that resizing is now purely internal to this fixed
            // box — the Column above it never sees a size change, so the
            // label below never shifts up/down as a tab is selected.
            SizedBox(
              height: iconsOnly ? 52.h : 44.h,
              width: iconsOnly ? 52.h : 44.h,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  if (iconsOnly)
                    _spinning(_iconOnly(tab, isSelected))
                  else
                  Builder(builder: (context) {
                    final Widget icon = _spinning(ImageWidget(
                      image: tab.inactiveAsset,
                      height: 28.h,
                      width: 28.h,
                    ));
                    // No background circle any more — on request, selecting a
                    // tab now only recolors the icon itself (and its label,
                    // below) to the pink->purple brand gradient, with no
                    // colored badge/shadow behind it.
                    if (!isSelected) return icon;
                    return ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) => const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _kNavSelectedGradient,
                      ).createShader(bounds),
                      child: icon,
                    );
                  }),
                  if (widget.badge != null)
                    Positioned(top: -2.h, right: 2.w, child: widget.badge!),
                ],
              ),
            ),
            if (!iconsOnly) ...[
            2.hBox,
            AnimatedDefaultTextStyle(
              duration: _kDuration,
              // Selected label uses the SAME gradient as the circle — the
              // TextStyle color below is just the ShaderMask's paint mask
              // (has to be opaque; the actual visible color comes from the
              // gradient shader), not the rendered color.
              style: (context.bodyMedium.size(11).colorExt(
                isSelected
                    ? Colors.white
                    : ColorManager.bottomNavInactiveColor,
              )).copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              child: isSelected
                  ? ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => const LinearGradient(
                  colors: _kNavSelectedGradient,
                ).createShader(bounds),
                child: Text(tab.label),
              )
                  : Text(tab.label),
            ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Small red unread-count pill for the Message tab, driven by the same live
/// unread total the Chats page itself uses — never a hand-typed number, so
/// it can never drift from the real inbox state.
class _UnreadMessageBadge extends StatelessWidget {
  const _UnreadMessageBadge();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchUsersChatBloc, GetUsersChatState>(
      bloc: di<FetchUsersChatBloc>(),
      buildWhen: (prev, curr) =>
      prev.totalUnreadFromDrift != curr.totalUnreadFromDrift,
      builder: (context, state) {
        final int count = state.totalUnreadFromDrift;
        if (count <= 0) return const SizedBox.shrink();
        final String text = count > 99 ? '99+' : '$count';
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
          constraints: BoxConstraints(minWidth: 16.h, minHeight: 16.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFF3B30),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: ColorManager.white, width: 1.4),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ColorManager.white,
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
        );
      },
    );
  }
}
/// Soft dark veil over an admin nav background IMAGE, so a bright picture
/// reads calmer and the icons stand out. Nothing for a color/gradient bar.
class _NavVeil extends StatelessWidget {
  const _NavVeil({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final region = ColorManager.navRegion;
    if (region == null || region.type != 'image' || !region.isRenderable) {
      return child;
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: Colors.black.withValues(alpha: 0.18)),
        child,
      ],
    );
  }
}

/// The bottom bar, with its background extended under the phone's system
/// navigation buttons.
///
/// The app shell (`_MainLayout` in app.dart) wraps every page in
/// `SafeArea(bottom: true)` on Android, so this page is laid out ABOVE the
/// system buttons and the strip behind them stayed black. Instead of removing
/// that SafeArea for every screen, the bar paints its background downward
/// past its own box by exactly the inset the ancestors consumed ([_hidden]),
/// while the icons keep their place above the buttons. Painting outside the
/// box is fine here: nothing above clips it and nothing else draws there.
class _SystemInsetBar extends StatelessWidget {
  const _SystemInsetBar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Inset still visible to this subtree (iOS: SafeArea is off there).
    final inTree = MediaQuery.viewPaddingOf(context).bottom;
    // Real system inset of the window, regardless of ancestor SafeAreas.
    final raw = MediaQueryData.fromView(View.of(context)).viewPadding.bottom;
    // The part an ancestor SafeArea already moved this page above.
    final hidden = (raw - inTree).clamp(0.0, double.infinity);

    return SizedBox(
      height: _kBarHeight + inTree,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: -hidden,
            child: ValueListenableBuilder<int>(
              valueListenable: ConstantsManager.colorsNotifier,
              builder: (context, _, __) => RegionBackground(
                descriptor: ColorManager.navRegion,
                fallback: (_) => const ColoredBox(color: ColorManager.white),
                // Fill the bar: the image variant stacks the child with
                // loose constraints.
                child: SizedBox.expand(
                  child: _NavVeil(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: inTree + hidden),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
