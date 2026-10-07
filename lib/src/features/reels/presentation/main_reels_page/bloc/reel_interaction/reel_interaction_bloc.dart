import 'package:general/reels_viewer/reels_viewer.dart';

part 'reel_interaction_event.dart';
part 'reel_interaction_state.dart';

class ReelInteractionBloc
    extends Bloc<ReelInteractionEvent, ReelInteractionState> {
  final ReelsFeedBloc forYouFeed;
  final ReelsFeedBloc followingFeed;
  final ReelsFeedBloc myReelsFeed;

  ReelInteractionBloc({
    required this.forYouFeed,
    required this.followingFeed,
    required this.myReelsFeed,
  }) : super(const ReelInteractionState()) {
    on<InteractionToggleLikeEvent>(_onToggleLike);
    on<InteractionToggleFollowEvent>(_onToggleFollow);
    on<InteractionAnimateLikeEvent>(_onAnimateLike);
    on<InteractionMakeCommentEvent>(_onMakeComment);
    on<InteractionRevertLikeEvent>(_onRevertLike);
    on<InteractionRevertFollowEvent>(_onRevertFollow);
    on<InteractionToggleReadMoreEvent>((event, emit) {
      emit(state.copyWith(
        readMore: !state.readMore,
        height: state.readMore ? 80.0 : null,
      ));
    });
    on<InteractionUpdateBottomPaddingEvent>((event, emit) {
      emit(state.copyWith(
        bottomPadding: event.padding,
        isCommentsOpened: event.padding != 0.0,
      ));
    });
    on<InteractionCurrentReelCommentsViewedEvent>((event, emit) {
      emit(state.copyWith(currentReelCommentsViewed: event.reel));
    });
  }

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

  List<ReelsFeedBloc> _otherFeeds(ReelsType filter) {
    switch (filter) {
      case ReelsType.forYou:
        return [followingFeed, myReelsFeed];
      case ReelsType.following:
        return [forYouFeed, myReelsFeed];
      case ReelsType.myReels:
        return [forYouFeed, followingFeed];
    }
  }

  /// O(1) cross-feed sync using each feed's ID→index map.
  void _syncReelUpdate(
    ReelsType sourceFilter,
    int sourceIndex,
    ReelsEntity Function(ReelsEntity reel) updater, {
    bool Function(ReelsEntity reel)? condition,
  }) {
    final sourceFeed = _feedFor(sourceFilter);
    if (sourceIndex < 0 || sourceIndex >= sourceFeed.state.reels.length) return;
    final reelId = sourceFeed.state.reels[sourceIndex].id;
    if (reelId == null) return;

    for (final otherFeed in _otherFeeds(sourceFilter)) {
      final idx = otherFeed.indexOfReelId(reelId);
      if (idx < 0) continue;
      final reel = otherFeed.state.reels[idx];
      if (condition != null && !condition(reel)) continue;
      final otherReels = List<ReelsEntity>.from(otherFeed.state.reels);
      otherReels[idx] = updater(reel);
      otherFeed.add(UpdateFeedReelsListEvent(otherReels));
    }
  }

  Future<void> _onToggleLike(
    InteractionToggleLikeEvent event,
    Emitter<ReelInteractionState> emit,
  ) async {
    final feed = _feedFor(event.filter);
    final reels = List<ReelsEntity>.from(feed.state.reels);
    if (event.index < 0 || event.index >= reels.length) return;

    final reel = reels[event.index];
    final wasLiked = reel.isLiked ?? false;
    reels[event.index] = reel.copyWith(
      isLiked: !wasLiked,
      likeCount: wasLiked
          ? ((reel.likeCount ?? 0) - 1)
          : ((reel.likeCount ?? 0) + 1),
    );
    feed.add(UpdateFeedReelsListEvent(reels));

    _syncReelUpdate(event.filter, event.index, (r) {
      final rWasLiked = r.isLiked ?? false;
      return r.copyWith(
        isLiked: !rWasLiked,
        likeCount: rWasLiked ? ((r.likeCount ?? 0) - 1) : ((r.likeCount ?? 0) + 1),
      );
    });
  }

  Future<void> _onToggleFollow(
    InteractionToggleFollowEvent event,
    Emitter<ReelInteractionState> emit,
  ) async {
    final feed = _feedFor(event.filter);
    if (event.index < 0 || event.index >= feed.state.reels.length) return;

    final targetUserId = feed.state.reels[event.index].user?.id;
    if (targetUserId == null) return;

    final newFollow = !(feed.state.reels[event.index].user?.isFollow ?? false);
    _setFollowAcrossFeeds(targetUserId, newFollow);
  }

  /// Sets `user.isFollow = value` for every reel authored by [userId] across all
  /// three feeds. Each feed only emits if at least one of its reels changed.
  void _setFollowAcrossFeeds(int userId, bool value) {
    for (final feed in [forYouFeed, followingFeed, myReelsFeed]) {
      var changed = false;
      final updatedReels = feed.state.reels.map((reel) {
        if (reel.user?.id == userId && (reel.user?.isFollow ?? false) != value) {
          changed = true;
          return reel.copyWith(user: reel.user?.copyWith(isFollow: value));
        }
        return reel;
      }).toList();
      if (changed) feed.add(UpdateFeedReelsListEvent(updatedReels));
    }
  }

  Future<void> _onAnimateLike(
    InteractionAnimateLikeEvent event,
    Emitter<ReelInteractionState> emit,
  ) async {
    final feed = _feedFor(event.filter);
    final reels = List<ReelsEntity>.from(feed.state.reels);
    if (event.index < 0 || event.index >= reels.length) return;

    if (reels[event.index].isLiked == false) {
      reels[event.index] = reels[event.index].copyWith(
        isLiked: true,
        likeCount: ((reels[event.index].likeCount ?? 0) + 1),
      );
      feed.add(UpdateFeedReelsListEvent(reels));

      _syncReelUpdate(
        event.filter,
        event.index,
        (r) => r.copyWith(isLiked: true, likeCount: ((r.likeCount ?? 0) + 1)),
        condition: (r) => r.isLiked == false,
      );
    }
  }

  Future<void> _onMakeComment(
    InteractionMakeCommentEvent event,
    Emitter<ReelInteractionState> emit,
  ) async {
    final reelId = int.tryParse(event.reelId);
    if (reelId == null) return;

    for (final feed in [forYouFeed, followingFeed, myReelsFeed]) {
      final idx = feed.indexOfReelId(reelId);
      if (idx < 0) continue;
      final reels = List<ReelsEntity>.from(feed.state.reels);
      reels[idx] = reels[idx].copyWith(
          commentCount: ((reels[idx].commentCount ?? 0) + 1));
      feed.add(UpdateFeedReelsListEvent(reels));
    }
  }

  /// Undoes an optimistic like by re-applying the INVERSE toggle for [reelId]
  /// across all three feeds. Only acts on feeds where the id exists, so it is
  /// idempotent-safe.
  Future<void> _onRevertLike(
    InteractionRevertLikeEvent event,
    Emitter<ReelInteractionState> emit,
  ) async {
    for (final feed in [forYouFeed, followingFeed, myReelsFeed]) {
      final idx = feed.indexOfReelId(event.reelId);
      if (idx < 0) continue;
      final reels = List<ReelsEntity>.from(feed.state.reels);
      final reel = reels[idx];
      final wasLiked = reel.isLiked ?? false;
      reels[idx] = reel.copyWith(
        isLiked: !wasLiked,
        likeCount: wasLiked
            ? ((reel.likeCount ?? 0) - 1)
            : ((reel.likeCount ?? 0) + 1),
      );
      feed.add(UpdateFeedReelsListEvent(reels));
    }
  }

  /// Undoes an optimistic follow by setting `user.isFollow = !intendedFollow`
  /// for every reel authored by [userId] across all three feeds.
  Future<void> _onRevertFollow(
    InteractionRevertFollowEvent event,
    Emitter<ReelInteractionState> emit,
  ) async {
    _setFollowAcrossFeeds(event.userId, !event.intendedFollow);
  }
}
