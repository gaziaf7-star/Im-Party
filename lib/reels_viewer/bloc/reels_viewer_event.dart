import 'package:general/src/core/index.dart';

abstract class ReelViewerEvent extends Equatable {
  const ReelViewerEvent();

  @override
  List<Object> get props => [];
}

class PlayReelEvent extends ReelViewerEvent {
  // final CachedVideoPlayerController controller;

  // PlayReelEvent(this.controller);
}

class PauseReelEvent extends ReelViewerEvent {
  // final CachedVideoPlayerController controller;

  // PauseReelEvent(this.controller);
}

class PauseAllReelEvent extends ReelViewerEvent {}

class FetchReelsEvent extends ReelViewerEvent {}

class LikeReelEvent extends ReelViewerEvent {
  final int reelIndex;

  const LikeReelEvent(this.reelIndex);
}

class UnlikeReelEvent extends ReelViewerEvent {
  final int reelIndex;

  const UnlikeReelEvent(this.reelIndex);
}

class FollowUserEvent extends ReelViewerEvent {
  final int userId;

  const FollowUserEvent(this.userId);
}

class ChangeActiveReelEvent extends ReelViewerEvent {
  final int index;
  final ReelsType reelsType;
  const ChangeActiveReelEvent(this.index, this.reelsType);
}

class UnfollowUserEvent extends ReelViewerEvent {
  final int userId;

  const UnfollowUserEvent(this.userId);
}

class FetchMoreReelsEvent extends ReelViewerEvent {}

class MuteToggleEvent extends ReelViewerEvent {}
