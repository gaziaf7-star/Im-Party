import 'dart:async';

import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:general/reels_viewer/reels_viewer.dart';
import 'package:general/src/features/auth/domain/entities/profile_room_entity.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_make_follow_unfollow/follow_bloc.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_make_follow_unfollow/follow_event.dart';
import 'package:general/src/features/reels/presentation/main_reels_page/bloc/make_like/make_like_bloc.dart';
import 'package:general/src/features/reels/presentation/main_reels_page/utils/reels_audio_session.dart';
import 'package:general/src/features/reels/presentation/main_reels_page/view/components/comments_screen/comments_screen.dart';
import '../../../../../../reels_viewer/src/widgets/share_dialog.dart';
import '../../../../auth/domain/entities/user_entity.dart';

class PlayMyReelsView extends StatefulWidget {
  const PlayMyReelsView({
    super.key,
    required this.param,
    required this.getReelsBloc,
    required this.reelViewerBloc,
  });
  final PlayMyReelParam param;
  final GetReelsBloc getReelsBloc;
  final ReelViewerBloc reelViewerBloc;

  @override
  PlayMyReelsViewState createState() => PlayMyReelsViewState();
}

class PlayMyReelsViewState extends State<PlayMyReelsView>
    with TickerProviderStateMixin, WidgetsBindingObserver, RouteAware {
  // ── Centralized playback lifecycle gates (ONE-master), mirroring
  //    ReelsScreen. This is a standalone pushed route, so it owns its own
  //    RouteAware + app-lifecycle observer (it is never on screen at the same
  //    time as ReelsScreen). desiredPlaying = _routeIsTop && _appResumed
  //    && !_overlayOpen && _userIntendsPlaying.
  bool _routeIsTop = true;
  bool _appResumed = true;
  bool _overlayOpen = false;
  final bool _userIntendsPlaying = true;

  /// Safety net: if the active controller hasn't appeared shortly after init
  /// (e.g. the page-change event was lost in a queue race), re-fire it once so
  /// the standalone player never gets stuck on a static thumbnail.
  Timer? _initWatchdog;
  int _initRetries = 0;

  // Keep the screen awake while a reel is playing (the standalone player had no
  // wakelock, so the screen dimmed/locked mid-video).
  bool _wakeLockHeld = false;
  Timer? _wakeLockTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _freeMemoryAndInit();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    navigatorObserver.subscribe(this, ModalRoute.of(context)!);
  }

  // ── RouteAware: a route pushed OVER this player (profile/room) and pop ──
  @override
  void didPushNext() {
    _routeIsTop = false;
    _recomputeDesiredPlayback();
    // Release the audio route immediately so the pushed screen (room/bluetooth)
    // regains output and reels audio stops bleeding in.
    ReelsAudioSession.instance.deactivate();
  }

  @override
  void didPopNext() {
    _routeIsTop = true;
    // Back on top → nothing is layered above us anymore.
    _overlayOpen = false;
    _recomputeDesiredPlayback();
  }

  // ── App lifecycle ──
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
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
        break;
    }
  }

  /// SINGLE dispatcher → drives Play/Pause through the ONE master
  /// (ReelViewerBloc) and keeps the layout-driven controller events flowing.
  void _recomputeDesiredPlayback() {
    final desiredPlaying =
        _routeIsTop && _appResumed && !_overlayOpen && _userIntendsPlaying;
    if (desiredPlaying) {
      widget.reelViewerBloc.add(PlayReelEvent());
      widget.getReelsBloc.add(const ResumeCurrentControllerEvent());
      _applyWakeLock(true);
    } else {
      widget.reelViewerBloc.add(PauseReelEvent());
      widget.getReelsBloc.add(const PauseAllControllersEvent());
      _applyWakeLock(false);
    }
  }

  /// Keep the screen awake while a reel plays. Re-asserts every time (idempotent)
  /// because another screen may have cleared the global wakelock.
  void _applyWakeLock(bool playing) {
    if (playing) {
      _wakeLockTimer?.cancel();
      WakelockPlus.enable();
      _wakeLockHeld = true;
    } else {
      _wakeLockTimer?.cancel();
      _wakeLockTimer = Timer(const Duration(seconds: 12), () {
        if (_wakeLockHeld) {
          WakelockPlus.disable();
          _wakeLockHeld = false;
        }
      });
    }
  }

  void _enterOverlay() {
    _overlayOpen = true;
    _recomputeDesiredPlayback();
  }

  void _exitOverlay() {
    _overlayOpen = false;
    _recomputeDesiredPlayback();
  }

  /// VIEW-04: a reel without a server id can't be liked/commented meaningfully —
  /// firing the API with a bogus -1 would hit the wrong row. Surface a localized
  /// error toast and treat it as a no-op instead.
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

  Future<void> _freeMemoryAndInit() async {
    final reelsBloc = widget.getReelsBloc;

    // Await disposal so native ExoPlayer memory is fully released
    await Future.wait([
      reelsBloc.forYouFeed.pool.disposeAll(),
      reelsBloc.followingFeed.pool.disposeAll(),
      reelsBloc.myReelsFeed.pool.disposeAll(),
    ]);
    reelsBloc.forYouFeed.add(const DisposeFeedControllersEvent());
    reelsBloc.followingFeed.add(const DisposeFeedControllersEvent());

    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    if (!mounted) return;

    widget.reelViewerBloc
        .add(ChangeActiveReelEvent(widget.param.index, ReelsType.myReels));
    reelsBloc.myReelsFeed.add(const InitializeFeedControllersEvent());
    reelsBloc
        .add(PageChangedEvent(widget.param.index, ReelsType.myReels, false));

    // ChangeActiveReelEvent no longer forces play; drive playback explicitly so
    // the tapped reel starts as soon as its controller is ready.
    _recomputeDesiredPlayback();

    _armInitWatchdog();
  }

  /// Re-fires the page-change once if the active controller never materialized.
  void _armInitWatchdog() {
    _initWatchdog?.cancel();
    _initWatchdog = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted || _initRetries >= 1) return;
      final feed = widget.getReelsBloc.myReelsFeed;
      final hasActive = feed.pool.activeController != null;
      if (!hasActive) {
        _initRetries++;
        feed.add(FeedPageChangedEvent(widget.param.index));
        _armInitWatchdog();
      }
    });
  }

  @override
  void dispose() {
    _initWatchdog?.cancel();
    _wakeLockTimer?.cancel();
    if (_wakeLockHeld) {
      WakelockPlus.disable();
      _wakeLockHeld = false;
    }
    navigatorObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    widget.getReelsBloc.myReelsFeed
        .add(const DisposeFeedControllersEvent());
    ReelsAudioSession.instance.deactivate();
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
          bloc: widget.getReelsBloc,
          buildWhen: (prev, curr) => prev.bottomPadding != curr.bottomPadding || prev.requestMyReelsState != curr.requestMyReelsState || prev.myReelsList != curr.myReelsList,
          builder: (context, state) {
            return Material(
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: state.bottomPadding == 0
                        ? ScreenUtil().screenHeight
                        : ScreenUtil().screenHeight - state.bottomPadding,
                    child: Scaffold(
                      backgroundColor: ColorManager.black,
                      body: Stack(
                        children: [
                          HandlingDataWidget(
                            title: StringManager.noReals.tr(),
                            reqState: state.requestMyReelsState,
                            subTitle: StringManager.noRealsSubTitle.tr(),
                            titleStyle: context.bodyMedium
                                .colorExt(ColorManager.white),
                            subTitleStyle: context.bodyMedium
                                .colorExt(ColorManager.white),
                            onTap: () {
                              widget.getReelsBloc
                                  .add(GetMyReels(userId: widget.param.userId));
                            },
                            child: ReelsViewer(
                              getReelsBloc: widget.getReelsBloc,
                              reelsViewerBloc: widget.reelViewerBloc,
                              filter: ReelsType.myReels,
                              isSharedReel: false,
                              reelList: state.myReelsList,
                              onClickCommentIcon: (reelData) {
                                final reelId = _reelIdOrNull(reelData);
                                if (reelId == null) return;
                                // PLAYER-10: pause the video while comments open.
                                _enterOverlay();
                                widget.getReelsBloc.add(
                                    UpdateBottomPaddingEvent(
                                        padding:
                                            ScreenUtil().screenHeight * 0.46));

                                showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                  ),
                                  backgroundColor: ColorManager.scaffoldBg,
                                  barrierColor: ColorManager.transparent,
                                  elevation: 0,
                                  isScrollControlled: true,
                                  enableDrag: false,
                                  constraints: BoxConstraints(
                                    maxHeight: ScreenUtil().screenHeight * 0.65,
                                    minHeight: 0,
                                  ),
                                  builder: (BuildContext context) {
                                    return CommentsScreen(
                                      currentReel: reelData,
                                      getReelsBloc: widget.getReelsBloc,
                                      reelId: reelId.toString(),
                                      filter: ReelsType.myReels,
                                    );
                                  },
                                ).whenComplete(() {
                                  widget.getReelsBloc.add(
                                      const UpdateBottomPaddingEvent(
                                          padding: 0.0));
                                  _exitOverlay();
                                });
                              },
                              onClickShareIcon: (reelData) async {
                                _enterOverlay();
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) => ShareDialog(
                                    reelEntity: reelData,
                                  ),
                                ).whenComplete(() => _exitOverlay());
                              },
                              onLike: (reelData) {
                                final reelId = _reelIdOrNull(reelData);
                                if (reelId == null) return;
                                di<MakeLikeBloc>()
                                    .add(MakeLikeEvent(reelId.toString()));
                              },
                              onUnLike: (reelData) {
                                final reelId = _reelIdOrNull(reelData);
                                if (reelId == null) return;
                                di<MakeLikeBloc>()
                                    .add(MakeLikeEvent(reelId.toString()));
                              },
                              onClickUserImage: (reelData) {
                                final userId = _userIdOrNull(reelData);
                                if (userId == null) return;
                                // Pause immediately; RouteAware (didPushNext/
                                // didPopNext) handles the pushed profile route
                                // and resumes on return.
                                _enterOverlay();
                                Methods().userProfileNavigator(
                                    userId: userId.toString(),
                                    context: context);
                              },
                              onFollow: (reelData) {
                                final userId = _userIdOrNull(reelData);
                                if (userId == null) return;
                                di<FollowBloc>().add(
                                  FollowEvent(
                                    userEntity: UserEntity(
                                      name: reelData.user?.userName ?? '',
                                      id: userId,
                                      profile: ProfileRoomEntity(
                                        image: reelData.user?.profileUrl ?? '',
                                      ),
                                    ),
                                    relationType: RelationType.reels,
                                  ),
                                );
                              },
                              onUnFollow: (reelData) {
                                final userId = _userIdOrNull(reelData);
                                if (userId == null) return;
                                di<FollowBloc>().add(
                                  UnFollowEvent(
                                    userId: userId.toString(),
                                    relationType: RelationType.reels,
                                  ),
                                );
                              },
                              onDelete: (reelData) {
                                final reelId = _reelIdOrNull(reelData);
                                if (reelId == null) return;
                                final list = widget
                                    .getReelsBloc.state.myReelsList;
                                final idx = list.indexWhere(
                                    (r) => r.id == reelData.id);
                                if (idx < 0) return;
                                widget.getReelsBloc.add(
                                    DeleteReelEvent(idx, reelId.toString()));
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
    );
  }
}
