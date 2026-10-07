import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:general/src/core/services/room_state_manager.dart';
import 'package:general/src/features/reels/presentation/main_reels_page/reels_upload_request.dart';
import 'package:general/reels_viewer/reels_viewer.dart';
import 'package:general/reels_viewer/src/widgets/reels_types_tab_bar.dart';
import 'package:general/src/features/auth/domain/entities/profile_room_entity.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_make_follow_unfollow/follow_bloc.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_make_follow_unfollow/follow_event.dart';
import 'package:general/src/features/reels/presentation/main_reels_page/bloc/make_like/make_like_bloc.dart';
import 'package:general/src/features/reels/presentation/main_reels_page/utils/reels_audio_session.dart';
import 'package:general/src/features/theme2_app/home/presentation/view/theme2_lives_page.dart';
import 'package:general/src/features/reels/presentation/main_reels_page/view/components/comments_screen/comments_screen.dart';
import '../../../../../../reels_viewer/src/widgets/share_dialog.dart';
import '../../../../auth/domain/entities/user_entity.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key, this.reelId, this.showOwnTabBar = true});
  final String? reelId;

  /// Whether this screen draws its own Following/For-You tab bar.
  ///
  /// False when it is embedded in the Moments hub, which surfaces those two
  /// feeds as its OWN tabs — two stacked tab bars for the same two feeds would
  /// be the same control twice. The hub drives the feed through
  /// [ReelsScreenState.showFeed] instead of a second instance, because both
  /// feeds share one GetReelsBloc and a duplicate screen would fight it.
  final bool showOwnTabBar;

  static String currentReelId = '';

  @override
  ReelsScreenState createState() => ReelsScreenState();
}

class ReelsScreenState extends State<ReelsScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver, RouteAware {
  late final TabController tabController;
  late final List<ReelsType> tabs;

  /// Switch the visible feed. Used by the Moments hub, whose tabs stand in for
  /// this screen's own tab bar.
  void showFeed(ReelsType type) {
    final index = tabs.indexOf(type);
    if (index < 0 || index == tabController.index) return;
    tabController.animateTo(index);
  }
  StreamSubscription<LayoutState>? _layoutSub;

  // ── Centralized playback lifecycle gates (ONE-master) ──
  // desiredPlaying = _routeIsTop && _appResumed && ConstantsManager
  //   .isReelsTabActive && !_overlayOpen && _userIntendsPlaying
  bool _routeIsTop = true;
  bool _appResumed = true;
  bool _overlayOpen = false;
  bool _userIntendsPlaying = true;

  // Wake-lock: keep screen on while a video is playing; release 12s after
  // the last pause/navigation so the screen can dim normally (#85).
  Timer? _wakeLockTimer;
  bool _wakeLockHeld = false;

  // True while an owned modal/route/picker is the active foreground surface.
  // Used to suppress app-lifecycle pause that the OS file picker spuriously
  // fires (PLAYER-13 picker race): while our own modal is up we don't let
  // a paused/hidden event flip the desired playback state.
  bool _modalOwnedActive = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    // Bottom-nav "+" (the Reels item morphs into a plus while this tab is
    // active) → open the upload flow.
    reelsUploadRequest.addListener(_onUploadRequested);

    final reelsBloc = di<GetReelsBloc>();
    tabs = [ReelsType.following, ReelsType.forYou];
    reelsBloc.add(const InitializeControllersEvent());

    // Kept for the classic layout (which DOES drive LayoutBloc); the jo_live
    // layout never drives it, so playback gating reads ConstantsManager
    // .isReelsTabActive live in _recomputeDesiredPlayback instead.
    _layoutSub = di<LayoutBloc>().stream.listen((_) {
      _recomputeDesiredPlayback();
    });
    if (!reelsBloc.state.requestState.isLoaded) {
      reelsBloc.add(const GetReelsEvent(initializeControllers: true));
    }

    tabController =
        TabController(length: tabs.length, initialIndex: 1, vsync: this);
    tabController.addListener(_onTabChanged);

    // Sync viewer bloc so the widget knows which reel is active
    di<ReelViewerBloc>()
        .add(const ChangeActiveReelEvent(0, ReelsType.forYou));

    if (widget.reelId?.isNotEmpty == true) {
      ReelsScreen.currentReelId = widget.reelId ?? "";
      reelsBloc.add(GetOneReelEvent(ReelParam(reelId: widget.reelId!)));
    } else {
      reelsBloc.add(const PageChangedEvent(0, ReelsType.forYou, false));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    navigatorObserver.subscribe(this, ModalRoute.of(context)!);
  }

  // ── RouteAware: pushes OVER reels (room/agency/profile) and pops back ──
  @override
  void didPushNext() {
    // A route was pushed on top of reels → reels is no longer the top route.
    _routeIsTop = false;
    _recomputeDesiredPlayback();
    // Guarantee an immediate audio-route release so the room/other screen
    // regains output (e.g. bluetooth) and reels audio stops bleeding in.
    ReelsAudioSession.instance.deactivate();
  }

  @override
  void didPopNext() {
    // Back on reels.
    _routeIsTop = true;
    _recomputeDesiredPlayback();
  }

  // ── App lifecycle (single observer for the whole reels feature) ──
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // While an owned modal/picker is active, ignore lifecycle transitions so
    // the picker's spurious paused/resumed cycle can't fight our flags.
    if (_modalOwnedActive) return;

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _appResumed = false;
        _recomputeDesiredPlayback();
        ReelsAudioSession.instance.deactivate();
        break;
      case AppLifecycleState.resumed:
        _appResumed = true;
        _recomputeDesiredPlayback();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      // Intentionally ignored (inactive fires on control-center / picker
      // and would cause a playback hitch).
        break;
    }
  }

  void _applyWakeLock(bool playing) {
    if (playing) {
      _wakeLockTimer?.cancel();
      // Always re-assert while playing (idempotent). Relying on the cached
      // _wakeLockHeld flag let the screen sleep mid-video whenever another
      // screen (e.g. exiting a room) had cleared the global wakelock.
      WakelockPlus.enable();
      _wakeLockHeld = true;
    } else {
      _wakeLockTimer?.cancel();
      _wakeLockTimer = Timer(const Duration(seconds: 12), () {
        if (_wakeLockHeld) {
          // Don't release the global wakelock while a room is active — the room
          // needs the screen to stay awake the whole time the user is in it.
          if (!di<RoomStateManager>().isInRoom) {
            WakelockPlus.disable();
          }
          _wakeLockHeld = false;
        }
      });
    }
  }

  /// The SINGLE place that decides whether the active reel should play and
  /// dispatches Play/Pause to the ONE master (ReelViewerBloc), keeping the
  /// existing layout-driven controller events flowing.
  void _recomputeDesiredPlayback() {
    // The jo_live layout NEVER drives LayoutBloc (so _layoutSub never fires);
    // ConstantsManager.isReelsTabActive is the authoritative "on reels tab"
    // flag the layout sets directly. Reading it live here (not a cached field)
    // is what lets playback resume after returning from a pushed route / app
    // resume while the reels tab is foreground.
    final desiredPlaying = _routeIsTop &&
        _appResumed &&
        ConstantsManager.isReelsTabActive &&
        !_overlayOpen &&
        _userIntendsPlaying;

    final viewerBloc = di<ReelViewerBloc>();
    final reelsBloc = di<GetReelsBloc>();

    if (desiredPlaying) {
      viewerBloc.add(PlayReelEvent());
      reelsBloc.add(const ResumeCurrentControllerEvent());
      _applyWakeLock(true);
    } else {
      viewerBloc.add(PauseReelEvent());
      reelsBloc.add(const PauseAllControllersEvent());
      _applyWakeLock(false);
    }
  }

  void _onTabChanged() {
    final index = tabController.index;
    final reelsBloc = di<GetReelsBloc>();
    final viewerBloc = di<ReelViewerBloc>();

    // New reel surface → user intends to watch again.
    _userIntendsPlaying = true;

    if (index == 0) {
      final resumeIndex = reelsBloc.followingFeed.state.currentIndex;
      viewerBloc.add(ChangeActiveReelEvent(resumeIndex, ReelsType.following));
      reelsBloc.add(PageChangedEvent(resumeIndex, ReelsType.following, true));
      if (!reelsBloc.state.requestFollowingState.isLoaded) {
        reelsBloc.add(const GetFollowingReelsEvent());
      }
      // ChangeActiveReelEvent no longer forces play; drive playback explicitly.
      if (reelsBloc.state.followingReelsList.isEmpty) {
        viewerBloc.add(PauseReelEvent());
      } else {
        _recomputeDesiredPlayback();
      }
    } else {
      final resumeIndex = reelsBloc.forYouFeed.state.currentIndex;
      viewerBloc.add(ChangeActiveReelEvent(resumeIndex, ReelsType.forYou));
      reelsBloc.add(PageChangedEvent(resumeIndex, ReelsType.forYou, true));
      // ChangeActiveReelEvent no longer forces play; drive playback explicitly.
      if (reelsBloc.state.reelsList.isEmpty) {
        viewerBloc.add(PauseReelEvent());
      } else {
        _recomputeDesiredPlayback();
      }
    }
  }

  @override
  void dispose() {
    reelsUploadRequest.removeListener(_onUploadRequested);
    navigatorObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    _layoutSub?.cancel();
    _wakeLockTimer?.cancel();
    if (_wakeLockHeld) {
      if (!di<RoomStateManager>().isInRoom) {
        WakelockPlus.disable();
      }
      _wakeLockHeld = false;
    }
    di<GetReelsBloc>().add(const DisposeControllersEvent());
    ReelsAudioSession.instance.deactivate();
    ReelsScreen.currentReelId = "";
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarColor: ColorManager.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: BlocBuilder<GetReelsBloc, GetReelsState>(
        bloc: di<GetReelsBloc>(),
        buildWhen: (prev, curr) =>
        prev.reelsList.length != curr.reelsList.length ||
            prev.followingReelsList.length !=
                curr.followingReelsList.length ||
            prev.requestState != curr.requestState ||
            prev.requestFollowingState != curr.requestFollowingState,
        builder: (context, state) {
          return Material(
            child: Stack(
              children: [
                Scaffold(
                  backgroundColor: ColorManager.black,
                  body: Stack(
                    children: [
                      TabBarView(
                        controller: tabController,
                        children: tabs.map((type) {
                          final isForYou = type == ReelsType.forYou;
                          final reels = isForYou
                              ? state.reelsList
                              : state.followingReelsList;
                          final reqState = isForYou
                              ? state.requestState
                              : state.requestFollowingState;

                          return HandlingDataWidget(
                            // EMPTY-01: keep the immersive black shell + tab
                            // bar visible during load (the Scaffold/tab bar
                            // live in the outer Stack) and swap the bare
                            // centered spinner for a full-bleed shimmer
                            // placeholder reel. Loading is handled by [child]
                            // below; the error/offline/ban states stay
                            // immersive (see titleStyle/subTitleStyle), but
                            // the plain "no reels yet" empty state is now a
                            // normal white page with light-black text
                            // (via [childEmpty] below) — requested directly,
                            // since there is no video behind it to justify
                            // staying black.
                            isNeedLoadingWidget: false,
                            title: isForYou
                                ? StringManager.noReals.tr()
                                : StringManager.noReals.tr(),
                            subTitle: isForYou
                                ? StringManager.noRealsSubTitle.tr()
                                : StringManager.noFollowingRealsSubTitle.tr(),
                            reqState: reqState,
                            // Reels Scaffold is always black (immersive), so
                            // the error/offline/ban text must use a
                            // guaranteed light color instead of
                            // ColorManager.textPrimary (which defaults to
                            // black -> black-on-black).
                            titleStyle: context.bodyMedium
                                .colorExt(ColorManager.white),
                            subTitleStyle: context.bodySmall
                                .colorExt(ColorManager.white)
                                .copyWith(height: 1.6),
                            childEmpty: Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: ColorManager.white,
                              child: EmptyView(
                                title: isForYou
                                    ? StringManager.noReals.tr()
                                    : StringManager.noReals.tr(),
                                subTitle: isForYou
                                    ? StringManager.noRealsSubTitle.tr()
                                    : StringManager.noFollowingRealsSubTitle
                                    .tr(),
                                onTap: () {
                                  if (!isForYou) {
                                    di<LayoutBloc>().add(
                                        const ChangeIndexEvent(
                                            currentIdex: 0));
                                  } else {
                                    di<GetReelsBloc>()
                                        .add(const GetReelsEvent());
                                  }
                                },
                                titleStyle: context.bodyMedium.w600
                                    .colorExt(
                                    ColorManager.momentPostTextColor),
                                subTitleStyle: context.bodySmall
                                    .colorExt(
                                    ColorManager.momentPostTextColor)
                                    .copyWith(height: 1.6),
                              ),
                            ),
                            onTap: () {
                              if (!isForYou) {
                                di<LayoutBloc>().add(const ChangeIndexEvent(currentIdex: 0));
                              } else {
                                di<GetReelsBloc>().add(const GetReelsEvent());
                              }
                            },
                            child: reqState.isLoading
                                ? const _ReelsLoadingShimmer()
                                : RefreshIndicator(
                              onRefresh: () =>
                                  _refreshFeed(type),
                              child: ReelsViewer(
                                getReelsBloc: di<GetReelsBloc>(),
                                reelsViewerBloc: di<ReelViewerBloc>(),
                                filter: type,
                                isSharedReel: widget.reelId != null,
                                reelList: reels,
                                onClickCommentIcon: (reelData) =>
                                    _openComments(context, reelData, type),
                                onClickShareIcon: (reelData) =>
                                    _openShare(context, reelData),
                                onLike: (reelData) =>
                                    _handleLike(reelData),
                                onUnLike: (reelData) =>
                                    _handleLike(reelData),
                                onClickUserImage: (reelData) =>
                                    _openUserProfile(context, reelData),
                                onFollow: (reelData) =>
                                    _followUser(reelData),
                                onUnFollow: (reelData) =>
                                    _unfollowUser(reelData),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      PositionedDirectional(
                        top: 25.h,
                        end: 10.w,
                        child: SizedBox(
                          width: ScreenUtil().screenWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Live shortcut — mirrors the home page's Live
                              // tab; sits opposite the add-reel button on the
                              // same line as the For-you/Following tabs.
                              if (ConstantsManager.isShowLive)
                                Padding(
                                  // Pulled INTO the screen (was glued to the
                                  // edge) — mirrors the old "+" inset.
                                  padding:
                                  EdgeInsetsDirectional.only(start: 14.w),
                                  child: GestureDetector(
                                    onTap: () {
                                      _enterOverlay(ownsLifecycle: true);
                                      Navigator.of(context)
                                          .push(
                                        MaterialPageRoute(
                                          // Named so exiting a live pops
                                          // back HERE, not past it to
                                          // the reels tab.
                                          settings: const RouteSettings(
                                              name: Routes.livesPage),
                                          builder: (_) =>
                                          const Theme2LivesPage(),
                                        ),
                                      )
                                          .then((_) => _exitOverlay(
                                          ownsLifecycle: true));
                                    },
                                    child: SizedBox(
                                      width: 40.w,
                                      height: 40.h,
                                      // TikTok-style live icon (screen with
                                      // a play mark, thin outline).
                                      child: Icon(
                                        Icons.smart_display_outlined,
                                        color: ColorManager.white,
                                        size: 27.sp,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                40.wBox,
                              if (widget.showOwnTabBar)
                                ReelsTypesTabBar(controller: tabController)
                              else
                                const Spacer(),
                              // Upload moved to the bottom nav: the Reels
                              // item morphs into a "+" while this tab is
                              // active (TikTok style).
                              54.wBox,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Marks the start of an overlay/route owned by reels and pauses playback.
  /// [ownsLifecycle] true for OS-level surfaces (file picker / pushed route)
  /// that emit spurious app-lifecycle events we must ignore.
  void _enterOverlay({bool ownsLifecycle = false}) {
    _overlayOpen = true;
    if (ownsLifecycle) _modalOwnedActive = true;
    _recomputeDesiredPlayback();
  }

  /// Marks the end of an overlay/route owned by reels and recomputes playback.
  void _exitOverlay({bool ownsLifecycle = false}) {
    _overlayOpen = false;
    if (ownsLifecycle) _modalOwnedActive = false;
    _recomputeDesiredPlayback();
  }

  /// VIEW-03: drive the pull-to-refresh spinner off the REAL feed load.
  /// Dispatches the refresh, then awaits the mirrored feed [requestState]
  /// leaving `loading` (for the tapped [type]) so the spinner stays up for the
  /// actual fetch. A timeout guarantees the spinner is released even if the
  /// fetch stalls / the bloc closes.
  Future<void> _refreshFeed(ReelsType type) async {
    final reelsBloc = di<GetReelsBloc>();
    final isForYou = type == ReelsType.forYou;

    reelsBloc.add(OnRefreshReelsEvent(filter: type));

    bool stillLoading(GetReelsState s) =>
        (isForYou ? s.requestState : s.requestFollowingState).isLoading;

    try {
      await reelsBloc.stream
          .firstWhere((s) => !stillLoading(s))
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      // Timeout or stream closed: release the spinner regardless.
    }
  }

  /// VIEW-04: a reel without a server id can't be liked/commented/shared
  /// meaningfully — firing the API with a bogus -1 would hit the wrong row.
  /// Surface a localized error toast and treat it as a no-op instead.
  int? _reelIdOrNull(ReelsEntity reelData) {
    final id = reelData.id;
    if (id == null) {
      Methods.showToast(
        context,
        message: StringManager.someThingWentWrong.tr(),
        isError: true,
      );
    }
    return id;
  }

  /// VIEW-04: same guard for the reel's author id (profile / follow actions).
  int? _userIdOrNull(ReelsEntity reelData) {
    final id = reelData.user?.id;
    if (id == null) {
      Methods.showToast(
        context,
        message: StringManager.someThingWentWrong.tr(),
        isError: true,
      );
    }
    return id;
  }

  void _openShare(BuildContext context, ReelsEntity reelData) {
    _enterOverlay();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ShareDialog(reelEntity: reelData),
    ).whenComplete(() => _exitOverlay());
  }

  void _openUserProfile(BuildContext context, ReelsEntity reelData) {
    final userId = _userIdOrNull(reelData);
    if (userId == null) return;
    // The pushed profile route is covered by RouteAware (didPushNext), but we
    // also flag the overlay so playback pauses immediately on tap.
    _enterOverlay();
    Navigator.pushNamed(
      context,
      Routes.userProfile,
      arguments: UserProfileParameter(
        userId: userId.toString(),
      ),
    ).then((_) => _exitOverlay());
  }

  void _onUploadRequested() {
    if (!mounted) return;
    _pickAndEditVideo(context);
  }

  Future<void> _pickAndEditVideo(BuildContext context) async {
    // The OS file picker fires spurious app-lifecycle events; own the
    // lifecycle so those don't fight our playback state (PLAYER-13).
    _enterOverlay(ownsLifecycle: true);

    FilePickerResult? result;
    try {
      result = await FilePicker.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );
    } catch (_) {
      // VIEW-01: a thrown picker error is a real failure (permission / OS) —
      // surface it instead of failing silently. A user-cancel returns null
      // (handled below) and stays quiet.
      _exitOverlay(ownsLifecycle: true);
      if (mounted) {
        Methods.showToast(
          context,
          message: StringManager.someThingWentWrong.tr(),
          isError: true,
        );
      }
      return;
    }

    if (result == null ||
        result.files.isEmpty ||
        result.files.first.path == null) {
      _exitOverlay(ownsLifecycle: true);
      return;
    }

    final videoFile = File(result.files.first.path!);
    if (!mounted) {
      _modalOwnedActive = false;
      _overlayOpen = false;
      return;
    }

    await Navigator.pushNamed(
      context,
      Routes.addVideoScreen,
      arguments: SendVideoParam(video: videoFile, isReels: true),
    );

    if (!mounted) {
      _modalOwnedActive = false;
      _overlayOpen = false;
      return;
    }
    _exitOverlay(ownsLifecycle: true);
  }

  void _openComments(
      BuildContext context, ReelsEntity reelData, ReelsType type) {
    final reelId = _reelIdOrNull(reelData);
    if (reelId == null) return;
    // PLAYER-10: pause the video while comments are open.
    _enterOverlay();
    di<GetReelsBloc>().add(
        UpdateBottomPaddingEvent(padding: ScreenUtil().screenHeight * 0.46));
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: ColorManager.surfaceCardColor,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      elevation: 8,
      isScrollControlled: true,
      enableDrag: true,
      constraints: BoxConstraints(maxHeight: ScreenUtil().screenHeight * 0.65),
      builder: (_) => CommentsScreen(
        currentReel: reelData,
        getReelsBloc: di<GetReelsBloc>(),
        reelId: reelId.toString(),
        filter: type,
      ),
    ).whenComplete(() {
      di<GetReelsBloc>().add(const UpdateBottomPaddingEvent(padding: 0.0));
      _exitOverlay();
    });
  }

  void _handleLike(ReelsEntity reelData) {
    final reelId = _reelIdOrNull(reelData);
    if (reelId == null) return;
    di<MakeLikeBloc>().add(MakeLikeEvent(reelId.toString()));
  }

  void _followUser(ReelsEntity reelData) {
    final userId = _userIdOrNull(reelData);
    if (userId == null) return;
    di<FollowBloc>().add(FollowEvent(
      userEntity: UserEntity(
        name: reelData.user?.userName ?? '',
        id: userId,
        profile: ProfileRoomEntity(image: reelData.user?.profileUrl ?? ''),
      ),
      relationType: RelationType.reels,
    ));
  }

  void _unfollowUser(ReelsEntity reelData) {
    final userId = _userIdOrNull(reelData);
    if (userId == null) return;
    di<FollowBloc>().add(UnFollowEvent(
      userId: userId.toString(),
      relationType: RelationType.reels,
    ));
  }
}

/// EMPTY-01: immersive full-bleed loading placeholder that replaces the bare
/// centered spinner while reels load. Mirrors the TikTok-style reel layout
/// (full-screen media, right action rail, bottom caption) with a subtle dark
/// shimmer so the black immersive shell stays cohesive. [Shimmer] owns its own
/// animation controller internally, so there is nothing to dispose here.
class _ReelsLoadingShimmer extends StatelessWidget {
  const _ReelsLoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: ColorManager.greyTabBar,
      highlightColor: ColorManager.greyDark,
      child: Stack(
        children: [
          // Full-bleed media placeholder.
          const Positioned.fill(
            child: ColoredBox(color: ColorManager.greyTabBar),
          ),
          // Right action rail (like / comment / share / more / avatar).
          PositionedDirectional(
            end: 12.w,
            bottom: 90.h,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _railDot(),
                28.hBox,
                _railDot(),
                28.hBox,
                _railDot(),
                28.hBox,
                _railDot(),
              ],
            ),
          ),
          // Bottom-left caption block (avatar + username + caption lines).
          PositionedDirectional(
            start: 16.w,
            bottom: 40.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 38.w,
                      height: 38.w,
                      decoration: const BoxDecoration(
                        color: ColorManager.greyDark,
                        shape: BoxShape.circle,
                      ),
                    ),
                    10.wBox,
                    _line(width: 110.w, height: 12.h),
                  ],
                ),
                14.hBox,
                _line(width: 220.w, height: 11.h),
                8.hBox,
                _line(width: 160.w, height: 11.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _railDot() {
    return Container(
      width: 42.w,
      height: 42.w,
      decoration: const BoxDecoration(
        color: ColorManager.greyDark,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _line({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: ColorManager.greyDark,
        borderRadius: BorderRadius.circular(6.r),
      ),
    );
  }
}