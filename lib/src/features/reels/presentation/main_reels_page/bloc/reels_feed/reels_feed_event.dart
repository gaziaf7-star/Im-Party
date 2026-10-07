part of 'reels_feed_bloc.dart';

sealed class ReelsFeedEvent extends Equatable {
  const ReelsFeedEvent();
}

class FetchFeedEvent extends ReelsFeedEvent {
  final bool isLoading;
  final bool onRefresh;
  final bool initializeControllers;
  final String userId;
  const FetchFeedEvent({
    this.isLoading = true,
    this.onRefresh = false,
    this.initializeControllers = false,
    this.userId = '',
  });
  @override
  List<Object?> get props => [isLoading, onRefresh, initializeControllers, userId];
}

class RefreshFeedEvent extends ReelsFeedEvent {
  const RefreshFeedEvent();
  @override
  List<Object?> get props => [];
}

class FeedPageChangedEvent extends ReelsFeedEvent {
  final int newIndex;
  const FeedPageChangedEvent(this.newIndex);
  @override
  List<Object?> get props => [newIndex];
}

class SeekFeedVideoEvent extends ReelsFeedEvent {
  final Duration position;
  const SeekFeedVideoEvent(this.position);
  @override
  List<Object?> get props => [position];
}

class DisposeFeedControllersEvent extends ReelsFeedEvent {
  const DisposeFeedControllersEvent();
  @override
  List<Object?> get props => [];
}

class InitializeFeedControllersEvent extends ReelsFeedEvent {
  const InitializeFeedControllersEvent();
  @override
  List<Object?> get props => [];
}

class LocalAddReelToFeedEvent extends ReelsFeedEvent {
  final ReelsEntity reel;
  const LocalAddReelToFeedEvent(this.reel);
  @override
  List<Object?> get props => [reel];
}

class PlayTappedFeedReelEvent extends ReelsFeedEvent {
  final int index;
  const PlayTappedFeedReelEvent(this.index);
  @override
  List<Object?> get props => [index];
}

class UpdateFeedReelEvent extends ReelsFeedEvent {
  final int index;
  final String description;
  const UpdateFeedReelEvent(this.index, this.description);
  @override
  List<Object?> get props => [index, description];
}

class DeleteFeedReelEvent extends ReelsFeedEvent {
  final int index;
  const DeleteFeedReelEvent(this.index);
  @override
  List<Object?> get props => [index];
}

class UpdateFeedReelsListEvent extends ReelsFeedEvent {
  final List<ReelsEntity> reels;
  const UpdateFeedReelsListEvent(this.reels);
  @override
  List<Object?> get props => [reels];
}

class FeedVideoProgressEvent extends ReelsFeedEvent {
  final Duration position;
  const FeedVideoProgressEvent(this.position);
  @override
  List<Object?> get props => [position];
}

class UpdateIsFeedSeekingEvent extends ReelsFeedEvent {
  final bool isSeeking;
  const UpdateIsFeedSeekingEvent(this.isSeeking);
  @override
  List<Object?> get props => [isSeeking];
}

class FilterChangedDisposeFeedEvent extends ReelsFeedEvent {
  const FilterChangedDisposeFeedEvent();
  @override
  List<Object?> get props => [];
}

class PauseFeedControllersEvent extends ReelsFeedEvent {
  const PauseFeedControllersEvent();
  @override
  List<Object?> get props => [];
}

class ResumeFeedControllerEvent extends ReelsFeedEvent {
  const ResumeFeedControllerEvent();
  @override
  List<Object?> get props => [];
}

class ResetFeedEvent extends ReelsFeedEvent {
  const ResetFeedEvent();
  @override
  List<Object?> get props => [];
}

/// Dispatched from the pool's `onError` callback so the failed index lands in
/// state on the bloc's event loop (callbacks fire off-loop). UI/retry is WF3.
class FeedReelErroredEvent extends ReelsFeedEvent {
  final int index;
  const FeedReelErroredEvent(this.index);
  @override
  List<Object?> get props => [index];
}

/// Dispatched after [ReelsFeedBloc.retryReel] re-inits a controller so the
/// error flag is cleared and the controllers map refreshed on the event loop.
class RetryFeedReelDoneEvent extends ReelsFeedEvent {
  final int index;
  const RetryFeedReelDoneEvent(this.index);
  @override
  List<Object?> get props => [index];
}
