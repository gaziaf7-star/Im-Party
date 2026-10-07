import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/cache/svga_movie_cache.dart';
import 'package:general/src/core/utils/app_lifecycle_signal.dart';
import 'package:general/src/core/services/connectivity_service.dart';
import 'package:general/src/core/widgets/body_theme_background.dart';
import 'package:general/src/features/room/presentation/component/games/banners/normal_games_banner.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/banners_bloc/banners_bloc.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/banners_bloc/banners_state.dart';
import 'package:general/src/features/room/presentation/gifts/view/component/gift_banners/new_lucky_gift_winner_banner.dart';
import 'package:general/src/features/room/presentation/lucky_box/widgets/show_lucky_banner_widget.dart';
import 'package:general/src/features/room/presentation/super_bomb/view/widgets/super_boom_banner.dart';
import 'package:general/src/features/room/presentation/yallow_banner/controller/controller.dart';
import 'package:general/src/features/room/presentation/yallow_banner/view/yallow_banner_widget.dart';
import 'package:general/src/features/room/room.dart';
import 'package:general/src/features/live_room/presentation/live_room_data.dart';
import 'package:utd_live_room_kit/utd_live_room_kit.dart' as live;
import 'widgets/on_multiable_tab.dart';

class TempApp extends StatefulWidget {
  const TempApp._internal();

  static const TempApp _instance = TempApp._internal();

  factory TempApp() => _instance;

  @override
  State<TempApp> createState() => _TempAppState();
}

class _TempAppState extends State<TempApp> with WidgetsBindingObserver {
  final ConnectivityService _connectivityService = ConnectivityService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _connectivityService.init();
    Methods.identifyUserForCrashlytics();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivityService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    AppLifecycleSignal.update(state);
  }

  @override
  void didHaveMemoryPressure() {
    SvgaMovieCache.instance.clear();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(400, 900),
      minTextAdapt: true,
      splitScreenMode: true,
      ensureScreenSize: true,
      useInheritedMediaQuery: true,
      enableScaleText: () => true,
      builder: (context, _) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
                statusBarColor: ColorManager.transparent,
                // Flutter's two brightness flags mean opposite things: on iOS
                // `statusBarBrightness` describes the BACKGROUND, on Android
                // `statusBarIconBrightness` describes the ICONS. This app is
                // light, so iOS is told the background is light and Android
                // draws dark icons. Both were `dark`, which on iOS asked for
                // light icons on a white bar -- invisible.
                statusBarBrightness: Brightness.light,
                statusBarIconBrightness: Brightness.dark,
                //
                systemNavigationBarDividerColor: ColorManager.transparent,
                systemNavigationBarIconBrightness: Brightness.dark,
                systemStatusBarContrastEnforced: false,
                systemNavigationBarContrastEnforced: false,
              ),
        // Rebuild the MaterialApp when admin/panel colors change so the theme
        // is re-read from the now-current ColorManager values in ONE launch and
        // live mid-session. The same const navKey + navigatorObserver instances
        // are reused in place, so the GlobalKey'd Navigator's route stack and
        // current route survive the theme swap untouched.
        child: ValueListenableBuilder<int>(
          valueListenable: ConstantsManager.colorsNotifier,
          builder: (_, __, ___) => MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorKey: navKey,
            navigatorObservers: [
              navigatorObserver,
            ],
            localizationsDelegates: context.localizationDelegates
              ..addAll([...PhoneFieldLocalization.delegates]),
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: LightTheme.theme,
            themeMode: ThemeMode.light,
            initialRoute: Routes.splash,
            onGenerateRoute: Routes.onGenerateRoute,
            scrollBehavior:
                const MaterialScrollBehavior().copyWith(overscroll: false),
            builder: (_, child) => UTDMiniPopScope(
              child: Overlay(
                initialEntries: [
                  OverlayEntry(
                    builder: (_) => _MainLayout(child: child),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MainLayout extends StatelessWidget {
  final Widget? child;

  const _MainLayout({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: !Platform.isIOS,
      top: false,
      child: ListenableBuilder(
        listenable: Listenable.merge([
          ConstantsManager.bodyThemeNotifier,
          ConstantsManager.colorsNotifier,
        ]),
        builder: (context, _) {
          final isBodyThemeEnabled = HiveManager().getData<bool>(
                KeysManager.USER_BOX,
                KeysManager.IS_BODY_THEME_ENABLED_KEY,
              ) ??
              false;

          Widget content = _buildMainContent(context);

          if (isBodyThemeEnabled) {
            // Panel-driven text color. ColorManager.textPrimary already falls
            // back to the adaptive white(dark)/black(light) default when no
            // panel override is set, so the look is preserved while a panel
            // override now wins (was hardcoded black/white, ignoring the panel).
            final textColor = ColorManager.textPrimary;
            final currentTheme = Theme.of(context);

            content = Theme(
              data: currentTheme.copyWith(
                scaffoldBackgroundColor: ColorManager.transparent,
                appBarTheme: const AppBarTheme(
                  backgroundColor: ColorManager.transparent,
                  surfaceTintColor: ColorManager.transparent,
                ),
                textTheme: currentTheme.textTheme.apply(
                  bodyColor: textColor,
                  displayColor: textColor,
                ),
              ),
              child: Stack(
                children: [
                  const Positioned.fill(child: BodyThemeBackground()),
                  content,
                ],
              ),
            );
          }

          return content;
        },
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(0, 0, 0, 0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              Expanded(
                child: ListenableBuilder(
                  listenable: Listenable.merge([
                    di<RoomStateManager>().stateNotifier,
                    UTDMiniOverlayMachine.instance.stateNotifier,
                    NavObserver.currentRoute,
                  ]),
                  builder: (context, _) {
                    final isMinimized =
                        UTDMiniOverlayMachine.instance.isMinimizing;
                    // Gate this on the room screen actually being the
                    // VISIBLE route, not just "still connected to a room" --
                    // isInAudioRoom stays true while the room is docked in
                    // the background (e.g. after navigating to a profile
                    // from inside it without minimizing/exiting), and this
                    // removePadding wraps the WHOLE app's Navigator here, so
                    // without this check every page pushed on top of the
                    // room inherited zeroed top/bottom padding and rendered
                    // its AppBar under the status bar -- and kept doing so
                    // for every further page pushed from there too, since
                    // they all sit under the same stripped MediaQuery.
                    final isRoomScreenVisible =
                        NavObserver.currentRoute.value == Routes.roomScreen ||
                            NavObserver.currentRoute.value ==
                                Routes.liveRoomScreen;
                    final isAudioRoomVisible = di<RoomStateManager>()
                            .isInAudioRoom &&
                        !isMinimized &&
                        isRoomScreenVisible;
                    final stack = _StackWithOutBanner(child: child);
                    return isAudioRoomVisible
                        ? MediaQuery.removePadding(
                            context: context,
                            removeTop: true,
                            removeBottom: true,
                            child: stack,
                          )
                        : stack;
                  },
                ),
              ),
            ],
          ),
          ValueListenableBuilder<UTDMiniOverlayState>(
            valueListenable: UTDMiniOverlayMachine.instance.stateNotifier,
            builder: (_, state, __) {
              if (state != UTDMiniOverlayState.minimizing) {
                return const SizedBox.shrink();
              }
              final controller = RoomData.instance.utdController;
              if (controller == null) return const SizedBox.shrink();
              // The kit starts the overlay at a hardcoded x=100 -- the LEFT of
              // the screen. Fuvio docks its capsule bottom-RIGHT, just above
              // the navigation bar, which is also where a thumb expects it and
              // where it covers the least content. Still draggable from there.
              const size = Size(76, 108);
              final screen = MediaQuery.sizeOf(context);
              final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
              return UTDMiniOverlayPage(
                controller: controller,
                size: size,
                topLeft: Offset(
                  screen.width - size.width - 12,
                  screen.height - bottomInset - 96 - size.height,
                ),
              );
            },
          ),
          // Live (video) mini-window: the live kit owns its OWN minimize state
          // machine (separate singleton from the audio kit above). When a live
          // room is minimized, render the live kit's floating PiP overlay driven
          // by the live controller — host video, draggable, tap to restore.
          ValueListenableBuilder<live.UTDMiniOverlayState>(
            valueListenable: live.UTDMiniOverlayMachine.instance.stateNotifier,
            builder: (_, state, __) {
              if (state != live.UTDMiniOverlayState.minimizing) {
                return const SizedBox.shrink();
              }
              final controller = LiveRoomData.instance.liveController;
              if (controller == null) return const SizedBox.shrink();
              return live.UTDMiniOverlayPage(controller: controller);
            },
          ),
          const _ConnectivityOverlay(),
        ],
      ),
    );
  }
}

class _StackWithOutBanner extends StatelessWidget {
  final Widget? child;

  const _StackWithOutBanner({this.child});

  static bool _shouldShowBanner(LayoutState layoutState) {
    // Tabs 1/2 (Reels/Chats) suppress banners over their full-screen feeds —
    // but ONLY while the layout itself is the visible route. Once a room/live
    // (or anything else) is pushed on top, the tab underneath is irrelevant;
    // gating on it hid EVERY banner inside rooms/lives entered from those tabs
    // (owner report 2026-06-11: special-message banner missing in live).
    final tabSuppressed = (layoutState.currentIndex == 1 ||
            layoutState.currentIndex == 2) &&
        NavObserver.currentRoute.value == Routes.layout;
    return !tabSuppressed &&
        NavObserver.currentRoute.value != Routes.coinsPage &&
        NavObserver.currentRoute.value != Routes.languageScreen &&
        NavObserver.currentRoute.value != "/" &&
        !isInPip.value;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child ?? const SizedBox.shrink(),
        //! Normal Gift Banner
        BlocBuilder<ShowBannersBloc, ShowBannersState>(
          bloc: di<ShowBannersBloc>(),
          buildWhen: (prev, curr) => prev != curr,
          builder: (_, state) {
            final data = state.bannerData?["gift"];
            if (data != null &&
                data.isNotEmpty &&
                state.bannerData?['bannerType'] == 'normal' &&
                !isInPip.value) {
              return PositionedDirectional(
                start: 20.w,
                end: 20.w,
                top: 45.h,
                child: MultiTapCard(
                  onTap: () => _giftTap(data),
                  // Unique key per enqueued banner: forces a fresh State (and a
                  // fresh animation + whenComplete cycle) for each banner so two
                  // rapid gifts never reuse one State and collapse into a single
                  // visible banner. _seq is stamped per enqueue in GiftController.
                  child: GiftBannerWidgetNew(
                    key: ValueKey('gift_${data['_seq'] ?? data['_ts']}'),
                    giftPrice: data['num_gift'].toString(),
                    sendDataUser: RoomVisitorModel(image: data['s_image']),
                    receiverDataUser: RoomVisitorModel(image: data['r_image']),
                    giftImage: data['gift_img'] ?? '',
                    isPassword: data['is_password'] ?? false,
                    speed: data['speed'] ?? "normal",
                  ),
                ),
              );
            } else {
              return const SizedBox();
            }
          },
        ),
        //! Banner Overlay (lucky, game, special, lucky box, boom)
        // NOT const: a const instance is skipped as an identical subtree on
        // every parent rebuild — the reactive gate inside must re-evaluate.
        // ignore: prefer_const_constructors
        _BannerOverlay(),
      ],
    );
  }
}

void _giftTap(Map<String, dynamic> data) async {
  if (ConstantsManager.isOptionalUpdate == true) {
    final roomId = int.parse(data['room_id'].toString());
    final ownerId = data['room_owner_id'];
    final isPassword = data['is_password'] ?? false;
    final isLive = data["room_type"].toString() == "live";

    final context = SafeNavigator.context;
    if (context == null) return;

    if (di<RoomStateManager>().isInRoom &&
        roomId.toString() == RoomData.instance.room.id.toString()) {
      // User is already in this room - check if minimized
      final utdCtrl = RoomData.instance.utdController;
      if (!isLive && (utdCtrl?.minimize.isMinimizing ?? false)) {
        utdCtrl?.minimize.restoreWithNavigator();
        return;
      }
      // Live room minimized — restore via the live kit's minimize machine.
      final liveCtrl = LiveRoomData.instance.liveController;
      if (isLive && (liveCtrl?.minimize.isMinimizing ?? false)) {
        liveCtrl?.minimize.restoreWithNavigator();
        return;
      }
    } else {
      await showBannerDestinationDialog(
        context: context,
        destinationName: data['room_name']?.toString(),
        isLive: isLive,
        onConfirm: () {
          di<RoomStateManager>().navigateToRoom(
            RoomEntryRequest(
              context: context,
              isLive: isLive,
              roomData: RoomEntity(
                id: roomId,
                passwordStatus: isPassword,
                giftPrice: data['gift_price'].toString(),
                ownerId: ownerId,
                name: data['room_name'],
                cover: data['room_cover'],
                roomBackground: data['room_background'],
                mode: data['room_mode'].toString(),
                uuidOwnerRoom: data['room_uuid'].toString(),
              ),
            ),
          );
        },
      );
    }
  }
}

class _BannerOverlay extends StatelessWidget {
  const _BannerOverlay();

  @override
  Widget build(BuildContext context) {
    // The gate must re-evaluate REACTIVELY on every route change and PiP flip,
    // not only on bottom-tab emissions — a frozen first evaluation (splash on
    // top at cold start) suppressed every banner for the whole session.
    return ListenableBuilder(
      listenable: Listenable.merge([NavObserver.currentRoute, isInPip]),
      builder: (context, _) {
        return BlocBuilder<LayoutBloc, LayoutState>(
          bloc: di<LayoutBloc>(),
          buildWhen: (prev, curr) => prev != curr,
          builder: (context, layoutState) {
            if (!_StackWithOutBanner._shouldShowBanner(layoutState)) {
              // Suppression HIDES only — never drop the queued lucky-box
              // banners; they show once the gate reopens.
              return const SizedBox.shrink();
            }
            return BlocBuilder<ShowBannersBloc, ShowBannersState>(
              bloc: di<ShowBannersBloc>(),
              buildWhen: (prev, curr) => prev != curr,
              builder: (_, fetchState) {
                return Stack(
                  children: [
                    _buildBannerFromData(fetchState.bannerData),
                    _buildSpecialBanner(),
                    _buildLuckyBoxBanners(),
                    _buildBoomBanner(),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildBannerFromData(Map<String, dynamic>? bannerData) {
    if (bannerData == null || bannerData.isEmpty) return const SizedBox();

    final bannerType = bannerData['bannerType'];

    if (bannerType == 'lucky') {
      return Positioned(
        top: 20.h,
        left: 0.w,
        right: 0.w,
        child: MultiTapCard(
          onTap: () => _giftTap(bannerData),
          // Unique key per enqueued banner so each win gets its own State +
          // animation + whenComplete cycle. Without it the keyless host reused
          // one State on the second rapid win — the in-room banner starved to
          // nothing and two outside wins collapsed into one.
          child: NewLuckyGiftWinnerBanner(
            // Prefer the backend per-win id (authoritative, identical across the
            // inside + outside copies), else the local enqueue sequence.
            key: ValueKey(
              'lucky_${bannerData['win_id'] ?? bannerData['_seq'] ?? bannerData['_ts']}',
            ),
            data: bannerData,
          ),
        ),
      );
    }

    if (bannerType == 'game') {
      // The game-service `game.win.event` payload can ship an empty
      // `user_image` (confirmed from a live capture -- name/coins/game_image
      // were all present and correct, only this field was ""). When the win
      // is the current user's own, fall back to their own known profile
      // picture instead of leaving the banner's avatar slot blank; for
      // someone else's win with no avatar there is no local data to fall
      // back to, so it stays empty (a backend/game-service gap, not
      // something the client can synthesize).
      final rawUserImage = bannerData["user_image"]?.toString() ?? "";
      final myId = MyDataModel.getInstance().id;
      final eventUserId = int.tryParse('${bannerData["user_id"] ?? ""}');
      final isMe = myId != null && eventUserId != null && myId == eventUserId;
      final userImage = rawUserImage.isNotEmpty
          ? rawUserImage
          : (isMe ? (MyDataModel.getInstance().profile?.image ?? "") : "");

      return Positioned(
        top: 20.h,
        left: 0.w,
        right: 0.w,
        child: NormalGamesBanner(
          key: ValueKey('game_${bannerData['_seq'] ?? bannerData['_ts']}'),
          // Fixed to the actual `game.win.event` payload's field names (was
          // uName/uImage/gImage/coins, a legacy/unused shape from the dead
          // showGameBanner() in room_controller.dart) -- the real backend
          // event ships user_name/user_image/game_image/win_coins, so every
          // one of these always read null and rendered blank.
          username: bannerData["user_name"]?.toString() ?? "",
          // win_coins arrives as a raw int (e.g. 250), not a string.
          coins: bannerData["win_coins"]?.toString() ?? "",
          userImage: userImage,
          gameImage: bannerData["game_image"]?.toString() ?? "",
          speed: bannerData["speed"] ?? "normal",
        ),
      );
    }

    return const SizedBox();
  }

  Widget _buildSpecialBanner() {
    return ValueListenableBuilder<bool>(
      valueListenable: YallowBannerController().isShowYallowBanner,
      builder: (context, isShow, _) {
        return isShow
            ? Positioned(
                // Moved down from the top -- sits a bit above the vertical
                // middle of the screen now, on request. `left` must stay
                // set alongside `right` -- a Positioned with only `right`
                // gives its child unbounded width, which crashed the
                // marquee text (TextScroll) inside with a null-check error.
                top: MediaQuery.sizeOf(context).height * 0.42,
                left: 0,
                right: 30.w,
                child: ShowYallowBannerWidget(
                  senderYallowBanner: YallowBannerController().senderData,
                ),
              )
            : const SizedBox();
      },
    );
  }

  Widget _buildLuckyBoxBanners() {
    return ValueListenableBuilder(
      valueListenable: LuckyBoxVariables.activeBannersNotifier,
      builder: (_, __, ___) {
        final banners = LuckyBoxVariables.activeBanners;
        const double bannerHeight = 80.0;
        const double spacing = 20.0;
        const double startTop = 180.0;
        return Stack(
          children: [
            for (final banner in banners)
              if (LuckyBoxVariables.bannerIndexMap
                  .containsKey('${banner['ownerBoxUId']}'))
                AnimatedPositionedDirectional(
                  key: ValueKey('${banner['ownerBoxUId']}'),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  top: startTop +
                      LuckyBoxVariables
                              .bannerIndexMap['${banner['ownerBoxUId']}']! *
                          (bannerHeight + spacing),
                  start: 0,
                  end: 0,
                  child: ShowLuckyBannerWidget(
                    bannerLuckyBoxModel: banner,
                  ),
                )
          ],
        );
      },
    );
  }

  Widget _buildBoomBanner() {
    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: SuperBoomController.currentBomb,
      builder: (context, bomb, _) {
        if (bomb == null || !ConstantsManager.isShowRoomBoom) {
          return const SizedBox();
        }
        return Positioned(
          top: 100.0,
          child: MultiTapCard(
            onTap: () => _giftTap(bomb),
            child: SuperBoomBanner(bomb: bomb),
          ),
        );
      },
    );
  }
}

class _ConnectivityOverlay extends StatelessWidget {
  const _ConnectivityOverlay();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: ConnectivityService().connectionStream,
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? true;
        if (!isConnected) return const _NoConnectionBody();
        return const SizedBox.shrink();
      },
    );
  }
}

class _NoConnectionBody extends StatelessWidget {
  const _NoConnectionBody();

  @override
  Widget build(BuildContext context) {
    // A small, non-blocking top banner (NOT a full-screen barrier) so the user
    // keeps using the app from the local cache while offline. IgnorePointer lets
    // taps fall through to the screen below.
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: SafeArea(
          bottom: false,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: ColorManager.red,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.wifi_slash,
                  size: 16.w,
                  color: ColorManager.white,
                ),
                8.horizontalSpace,
                Flexible(
                  child: Text(
                    'No internet connection',
                    textAlign: TextAlign.center,
                    style: context.bodyMedium.copyWith(
                      fontSize: 13.sp,
                      color: ColorManager.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NavObserver extends RouteObserver<ModalRoute<dynamic>> {
  /// The visible route's name as a [ValueNotifier] so listeners (the banner
  /// gate) re-evaluate on every navigation. Seeded with the initial route —
  /// before the first didPush the splash IS the visible route, not `null`.
  static final ValueNotifier<String?> currentRoute =
      ValueNotifier<String?>(Routes.splash);
  bool isDialogShowing = false;

  @override
  void didPush(Route route, Route? previousRoute) {
    currentRoute.value = route.settings.name;
    if (route is PopupRoute) isDialogShowing = true;
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    currentRoute.value = previousRoute?.settings.name;
    if (route is PopupRoute) isDialogShowing = false;
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    currentRoute.value = newRoute?.settings.name;
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    // Only when the VISIBLE route is removed does the one below become
    // current — pushNamedAndRemoveUntil removes covered routes after the new
    // top is pushed, and those must not clobber it.
    if (currentRoute.value == route.settings.name) {
      currentRoute.value = previousRoute?.settings.name;
    }
    super.didRemove(route, previousRoute);
  }
}
