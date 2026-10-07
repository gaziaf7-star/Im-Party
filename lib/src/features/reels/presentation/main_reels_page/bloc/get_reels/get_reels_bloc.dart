import 'dart:async';
import 'package:general/reels_viewer/reels_viewer.dart';
import 'package:general/src/features/reels/domain/use_case/delete_reel_use_case.dart';
import 'package:general/src/features/reels/domain/use_case/get_my_reels_use_case.dart';
import 'package:general/src/features/reels/domain/use_case/get_reels_use_case.dart';
import 'package:general/src/features/reels/domain/use_case/update_reel_description_use_case.dart';

part 'get_reels_event.dart';
part 'get_reels_state.dart';

/// Thin coordinator facade that delegates to [ReelsFeedBloc] and
/// [ReelInteractionBloc].  Keeps backward compatibility for all existing
/// consumer widgets — they still use `BlocBuilder<GetReelsBloc, GetReelsState>`.
class GetReelsBloc extends Bloc<BaseGetReelsEvent, GetReelsState> {
  final GetReelsUseCase useCase;
  final GetOneReelsUseCase getOneReelsUseCase;
  final GetMyReelsUseCase myReelsUseCase;
  final UpdateReelDescriptionUseCase updateReelDescriptionUseCase;
  final DeleteReelUseCase deleteReelUseCase;

  late final ReelsFeedBloc forYouFeed;
  late final ReelsFeedBloc followingFeed;
  late final ReelsFeedBloc myReelsFeed;
  late final ReelInteractionBloc interactionBloc;

  final List<StreamSubscription> _subs = [];
  VoidCallback? _myReelsScrollListener;
  ReelsType _activeFilter = ReelsType.forYou;

  GetReelsBloc(this.useCase, this.getOneReelsUseCase, this.myReelsUseCase,
      this.updateReelDescriptionUseCase, this.deleteReelUseCase)
      : super(GetReelsState(
          scrollCtrl: PageController(),
          followingScrollCtrl: PageController(),
          myReelsScrollCtrl: PageController(),
          myReelsGrideViewScrollController: ScrollController(),
          isMute: false,
          isSeeking: false,
          readMore: false,
          height: 20.0,
          videoControllers: const {},
          followingVideoControllers: const {},
          myReelsVideoControllers: const {},
        )) {
    // Create sub-blocs
    forYouFeed = ReelsFeedBloc(
      fetchReels: (page, {userId = ''}) => useCase(ReelParam(page: page)),
    );
    followingFeed = ReelsFeedBloc(
      fetchReels: (page, {userId = ''}) =>
          useCase(ReelParam(page: page, filter: "following")),
    );
    myReelsFeed = ReelsFeedBloc(
      fetchReels: (page, {userId = ''}) =>
          myReelsUseCase(ReelParam(page: page, userId: userId)),
    );
    interactionBloc = ReelInteractionBloc(
      forYouFeed: forYouFeed,
      followingFeed: followingFeed,
      myReelsFeed: myReelsFeed,
    );

    // Mirror sub-bloc states into GetReelsState
    _subs.add(forYouFeed.stream.listen((_) => _syncState()));
    _subs.add(followingFeed.stream.listen((_) => _syncState()));
    _subs.add(myReelsFeed.stream.listen((_) => _syncState()));
    _subs.add(interactionBloc.stream.listen((_) => _syncState()));

    // Register event handlers — all delegate to sub-blocs
    on<GetReelsEvent>(_onGetReels);
    on<GetFollowingReelsEvent>(_onGetFollowing);
    on<GetMyReels>(_onGetMyReels);
    on<OnRefreshReelsEvent>(_onRefresh);
    on<PageChangedEvent>(_onPageChanged);
    on<GetMoreReelsEvent>(_onGetMore);
    on<LocalAddReelEvent>(_onLocalAddReel);
    on<GetOneReelEvent>(_onGetOneReel);
    on<PlayTappedReelEvent>(_onPlayTapped);
    on<DisposeControllersEvent>(_onDispose);
    on<InitializeControllersEvent>(_onInitialize);
    on<ToggleLikeEvent>(_onToggleLike);
    on<ToggleFollowEvent>(_onToggleFollow);
    on<AnimateLikeEvent>(_onAnimateLike);
    on<LocalMakeCommentsEvent>(_onMakeComment);
    on<SeekVideoEvent>(_onSeek);
    on<VideoProgressUpdatedEvent>(_onVideoProgress);
    on<UpdateIsSeekEvent>(_onUpdateSeek);
    on<ToggleReadMoreEvent>(_onToggleReadMore);
    on<UpdateBottomPaddingEvent>(_onUpdatePadding);
    on<CurrentReelCommentsViewedEvent>(_onCommentsViewed);
    on<RevertLikeEvent>(_onRevertLike);
    on<RevertFollowEvent>(_onRevertFollow);
    on<DeleteReelEvent>(_onDeleteReel);
    on<UpdateReelEvent>(_onUpdateReel);
    on<AddListenerMyReelsWithoutControllerEvent>(_onMyReelsWithoutController);
    on<AddListenerEvent>(_onAddListener);
    on<RemoveListenerEvent>(_onRemoveListener);
    on<PauseAllControllersEvent>(_onPauseAll);
    on<ResumeCurrentControllerEvent>(_onResumeCurrent);
    on<ResetMyReelsEvent>(_onResetMyReels);
    on<_SyncStateEvent>(_onSyncStateEvent);
  }

  // ── State sync ──────────────────────────────────────────────────────

  bool _syncScheduled = false;

  void _syncState() {
    if (_syncScheduled || isClosed) return;
    _syncScheduled = true;
    scheduleMicrotask(() {
      _syncScheduled = false;
      if (!isClosed) add(const _SyncStateEvent());
    });
  }

  void _onSyncStateEvent(_SyncStateEvent event, Emitter<GetReelsState> emit) {
    final fy = forYouFeed.state;
    final fo = followingFeed.state;
    final my = myReelsFeed.state;
    final ix = interactionBloc.state;

    emit(state.copyWith(
      // forYou
      reelsList: fy.reels,
      currentIndex: fy.currentIndex,
      currentPagination: fy.currentPagination,
      lastPage: fy.lastPage,
      requestState: fy.requestState,
      message: fy.message,
      scrollCtrl: fy.scrollCtrl,
      videoControllers: fy.videoControllers,
      erroredIndices: fy.erroredIndices,
      // following
      followingReelsList: fo.reels,
      currentFollowingIndex: fo.currentIndex,
      currentFollowingPagination: fo.currentPagination,
      lastFollowingPage: fo.lastPage,
      requestFollowingState: fo.requestState,
      followingMessage: fo.message,
      followingScrollCtrl: fo.scrollCtrl,
      followingVideoControllers: fo.videoControllers,
      followingErroredIndices: fo.erroredIndices,
      // myReels
      myReelsList: my.reels,
      currentMyReelsIndex: my.currentIndex,
      currentMyReelsPagination: my.currentPagination,
      lastMyReelsPage: my.lastPage,
      requestMyReelsState: my.requestState,
      myReelMessage: my.message,
      myReelsScrollCtrl: my.scrollCtrl,
      myReelsVideoControllers: my.videoControllers,
      myReelsErroredIndices: my.erroredIndices,
      // seeking (use any feed that is seeking)
      isSeeking: fy.isSeeking || fo.isSeeking || my.isSeeking,
      isDisposed: fy.isDisposed && fo.isDisposed && my.isDisposed,
      // interaction
      readMore: ix.readMore,
      height: ix.height,
      bottomPadding: ix.bottomPadding,
      isCommentsOpened: ix.isCommentsOpened,
      currentReelCommentsViewed: ix.currentReelCommentsViewed,
    ));
  }

  // ── Feed helpers ────────────────────────────────────────────────────

  ReelsFeedBloc _feedFor(ReelsType filter) {
    switch (filter) {
      case ReelsType.forYou:
        return forYouFeed;
      case ReelsType.following:
        return followingFeed;
      case ReelsType.myReels:
        return myReelsFeed;
    }
  }

  // ── Event handlers (all delegate) ───────────────────────────────────

  Future<void> _onGetReels(
      GetReelsEvent event, Emitter<GetReelsState> emit) async {
    forYouFeed.add(FetchFeedEvent(
      isLoading: event.isLoading,
      onRefresh: event.onRefresh,
      initializeControllers: event.initializeControllers,
    ));
  }

  Future<void> _onGetFollowing(
      GetFollowingReelsEvent event, Emitter<GetReelsState> emit) async {
    followingFeed.add(FetchFeedEvent(
      isLoading: event.isLoading,
      onRefresh: event.onRefresh,
    ));
  }

  Future<void> _onGetMyReels(
      GetMyReels event, Emitter<GetReelsState> emit) async {
    // Visiting a new profile must NOT show the previous user's reels. The feed
    // merges pages by id, so without a reset the old user's reels survive into
    // the new fetch (stale state across profiles). Reset clears reels +
    // controllers + pagination, and we mirror an empty + loading list into
    // GetReelsState immediately so the grid never flashes the old user's reels.
    myReelsFeed.add(const ResetFeedEvent());
    emit(state.copyWith(
      myReelsList: const [],
      currentMyReelsIndex: 0,
      currentMyReelsPagination: 1,
      lastMyReelsPage: 1,
      requestMyReelsState: RequestState.loading,
      myReelsVideoControllers: const {},
    ));
    myReelsFeed.add(FetchFeedEvent(
      isLoading: event.isLoading,
      userId: event.userId,
    ));
  }

  Future<void> _onRefresh(
      OnRefreshReelsEvent event, Emitter<GetReelsState> emit) async {
    _feedFor(event.filter).add(const RefreshFeedEvent());
  }

  Future<void> _onPageChanged(
      PageChangedEvent event, Emitter<GetReelsState> emit) async {
    _activeFilter = event.filter;

    if (event.isFilterChanged) {
      // Dispose the OTHER feed's controllers when switching tabs
      if (event.filter == ReelsType.following) {
        forYouFeed.add(const FilterChangedDisposeFeedEvent());
      } else {
        followingFeed.add(const FilterChangedDisposeFeedEvent());
      }
    }

    final feed = _feedFor(event.filter);

    // Skip page-change events when the Reels tab is not active — but ONLY for the
    // main-tab feeds (forYou/following). The myReels feed is driven by the
    // standalone PlayMyReelsView, a full-screen route pushed from the PROFILE
    // tab where isReelsTabActive is false; gating it here swallowed its
    // PageChangedEvent → the pool never initialized → static thumbnail forever.
    // The standalone player owns its own lifecycle gates, so it is safe to let
    // its page-changes through unconditionally.
    if (event.filter != ReelsType.myReels &&
        !ConstantsManager.isReelsTabActive) {
      return;
    }

    feed.add(FeedPageChangedEvent(event.newIndex));
  }

  Future<void> _onGetMore(
      GetMoreReelsEvent event, Emitter<GetReelsState> emit) async {
    final feed = _feedFor(event.filter);
    if (feed.state.currentPagination < feed.state.lastPage) {
      feed.add(const FetchFeedEvent(isLoading: false));
    }
  }

  Future<void> _onLocalAddReel(
      LocalAddReelEvent event, Emitter<GetReelsState> emit) async {
    forYouFeed.add(LocalAddReelToFeedEvent(event.newReel));
  }

  Future<void> _onGetOneReel(
      GetOneReelEvent event, Emitter<GetReelsState> emit) async {
    emit(state.copyWith(requestState: RequestState.loading));
    final result = await getOneReelsUseCase(event.param);
    result.fold((failure) {
      emit(state.copyWith(
        message: NetworkExceptions.getErrorMessage(failure),
        requestState: handleErrorResponse(failure),
      ));
    }, (success) {
      final data = success.data;
      if (data == null) {
        emit(state.copyWith(requestState: RequestState.error));
        return;
      }
      add(LocalAddReelEvent(data));
      emit(state.copyWith(
        currentReel: data,
        requestState: handleLoadedResponse<ReelsEntity>(data),
      ));
    });
  }

  Future<void> _onPlayTapped(
      PlayTappedReelEvent event, Emitter<GetReelsState> emit) async {
    if (event.filter == ReelsType.myReels) {
      myReelsFeed.add(PlayTappedFeedReelEvent(event.index));
    }
  }

  Future<void> _onDispose(
      DisposeControllersEvent event, Emitter<GetReelsState> emit) async {
    forYouFeed.add(const DisposeFeedControllersEvent());
    followingFeed.add(const DisposeFeedControllersEvent());
    myReelsFeed.add(const DisposeFeedControllersEvent());
  }

  Future<void> _onInitialize(
      InitializeControllersEvent event, Emitter<GetReelsState> emit) async {
    forYouFeed.add(const InitializeFeedControllersEvent());
    followingFeed.add(const InitializeFeedControllersEvent());
    myReelsFeed.add(const InitializeFeedControllersEvent());
  }

  Future<void> _onToggleLike(
      ToggleLikeEvent event, Emitter<GetReelsState> emit) async {
    interactionBloc
        .add(InteractionToggleLikeEvent(event.index, event.filter));
  }

  Future<void> _onToggleFollow(
      ToggleFollowEvent event, Emitter<GetReelsState> emit) async {
    interactionBloc
        .add(InteractionToggleFollowEvent(event.index, event.filter));
  }

  Future<void> _onAnimateLike(
      AnimateLikeEvent event, Emitter<GetReelsState> emit) async {
    interactionBloc
        .add(InteractionAnimateLikeEvent(event.index, event.filter));
  }

  Future<void> _onRevertLike(
      RevertLikeEvent event, Emitter<GetReelsState> emit) async {
    interactionBloc.add(InteractionRevertLikeEvent(event.reelId));
  }

  Future<void> _onRevertFollow(
      RevertFollowEvent event, Emitter<GetReelsState> emit) async {
    interactionBloc
        .add(InteractionRevertFollowEvent(event.userId, event.intendedFollow));
  }

  Future<void> _onMakeComment(
      LocalMakeCommentsEvent event, Emitter<GetReelsState> emit) async {
    interactionBloc
        .add(InteractionMakeCommentEvent(event.param.reelId ?? ''));
  }

  Future<void> _onSeek(
      SeekVideoEvent event, Emitter<GetReelsState> emit) async {
    _feedFor(event.filter).add(SeekFeedVideoEvent(event.position));
  }

  Future<void> _onVideoProgress(
      VideoProgressUpdatedEvent event, Emitter<GetReelsState> emit) async {
    _feedFor(event.filter).add(FeedVideoProgressEvent(event.position));
  }

  Future<void> _onUpdateSeek(
      UpdateIsSeekEvent event, Emitter<GetReelsState> emit) async {
    // Update all feeds (only the active one matters, but this is safe)
    forYouFeed.add(UpdateIsFeedSeekingEvent(event.isSeeking));
    followingFeed.add(UpdateIsFeedSeekingEvent(event.isSeeking));
    myReelsFeed.add(UpdateIsFeedSeekingEvent(event.isSeeking));
  }

  Future<void> _onToggleReadMore(
      ToggleReadMoreEvent event, Emitter<GetReelsState> emit) async {
    interactionBloc.add(const InteractionToggleReadMoreEvent());
  }

  Future<void> _onUpdatePadding(
      UpdateBottomPaddingEvent event, Emitter<GetReelsState> emit) async {
    interactionBloc
        .add(InteractionUpdateBottomPaddingEvent(padding: event.padding));
  }

  Future<void> _onCommentsViewed(
      CurrentReelCommentsViewedEvent event, Emitter<GetReelsState> emit) async {
    interactionBloc
        .add(InteractionCurrentReelCommentsViewedEvent(reel: event.reel));
  }

  Future<void> _onDeleteReel(
      DeleteReelEvent event, Emitter<GetReelsState> emit) async {
    emit(state.copyWith(deleteReelsState: RequestState.loading));
    final result = await deleteReelUseCase(ReelParam(reelId: event.reelId));
    result.fold(
      (left) => emit(state.copyWith(
        deleteReelsState: handleErrorResponse(left),
        myReelMessage: NetworkExceptions.getErrorMessage(left),
      )),
      (right) {
        myReelsFeed.add(DeleteFeedReelEvent(event.index));
        emit(state.copyWith(
          deleteReelsState: handleLoadedResponse(right.data),
          myReelMessage: right.message,
        ));
        emit(state.copyWith(deleteReelsState: RequestState.idle));
      },
    );
  }

  Future<void> _onUpdateReel(
      UpdateReelEvent event, Emitter<GetReelsState> emit) async {
    emit(state.copyWith(updateReelsState: RequestState.loading));
    final result = await updateReelDescriptionUseCase(
        ReelParam(reelId: event.reelId, description: event.description));
    result.fold(
      (left) => emit(state.copyWith(
        updateReelsState: handleErrorResponse(left),
        myReelMessage: NetworkExceptions.getErrorMessage(left),
      )),
      (right) {
        myReelsFeed.add(UpdateFeedReelEvent(event.index, event.description));
        emit(state.copyWith(
          updateReelsState: handleLoadedResponse(right.data),
          myReelMessage: right.message,
        ));
        emit(state.copyWith(updateReelsState: RequestState.idle));
      },
    );
  }

  void _onMyReelsWithoutController(
    AddListenerMyReelsWithoutControllerEvent event,
    Emitter<GetReelsState> emit,
  ) {
    if (myReelsFeed.state.currentPagination < myReelsFeed.state.lastPage) {
      myReelsFeed.add(const FetchFeedEvent(isLoading: false));
    }
  }

  void _onAddListener(
      AddListenerEvent event, Emitter<GetReelsState> emit) {
    if (_myReelsScrollListener != null) {
      state.myReelsGrideViewScrollController.removeListener(_myReelsScrollListener!);
    }
    _myReelsScrollListener = () => _listenerReels(event.userId);
    final scrollCtrl = state.myReelsGrideViewScrollController
      ..addListener(_myReelsScrollListener!);
    emit(state.copyWith(myReelsGrideViewScrollController: scrollCtrl));
  }

  void _onRemoveListener(
      RemoveListenerEvent event, Emitter<GetReelsState> emit) {
    if (_myReelsScrollListener != null) {
      state.myReelsGrideViewScrollController.removeListener(_myReelsScrollListener!);
      _myReelsScrollListener = null;
    }
    emit(state.copyWith(myReelsGrideViewScrollController: state.myReelsGrideViewScrollController));
  }

  void _onResetMyReels(
    ResetMyReelsEvent event,
    Emitter<GetReelsState> emit,
  ) {
    myReelsFeed.add(const ResetFeedEvent());
  }

  Future<void> _onPauseAll(
      PauseAllControllersEvent event, Emitter<GetReelsState> emit) async {
    // ONE-master: the active _ReelsWidget plays/pauses off ReelViewerBloc.
    // External callers (the jo_live layout fires this on tab-leave; it never
    // drives LayoutBloc) must set the master's desired state, not just the
    // pool — otherwise leaving the reels tab wouldn't pause playback.
    di<ReelViewerBloc>().add(PauseReelEvent());
    forYouFeed.add(const PauseFeedControllersEvent());
    followingFeed.add(const PauseFeedControllersEvent());
    myReelsFeed.add(const PauseFeedControllersEvent());
  }

  Future<void> _onResumeCurrent(
      ResumeCurrentControllerEvent event, Emitter<GetReelsState> emit) async {
    // ONE-master: drive the master so the active widget resumes. The layout
    // fires this on reels-tab re-entry (it never drives LayoutBloc), so without
    // setting isPlaying=true the video would stay frozen on tab switch back.
    di<ReelViewerBloc>().add(PlayReelEvent());
    _feedFor(_activeFilter).add(const ResumeFeedControllerEvent());
  }

  void _listenerReels(String userId) {
    handleScrollListener(
      controller: state.myReelsGrideViewScrollController,
      currentPage: myReelsFeed.state.currentPagination,
      lastPage: myReelsFeed.state.lastPage,
      fun: () {
        myReelsFeed.add(const FetchFeedEvent(isLoading: false));
      },
    );
  }

  @override
  Future<void> close() {
    for (final sub in _subs) {
      sub.cancel();
    }
    state.myReelsGrideViewScrollController.dispose();
    forYouFeed.close();
    followingFeed.close();
    myReelsFeed.close();
    interactionBloc.close();
    return super.close();
  }
}

/// Internal event used to trigger state sync from sub-bloc streams.
class _SyncStateEvent extends BaseGetReelsEvent {
  const _SyncStateEvent();
  @override
  List<Object?> get props => [];
}
