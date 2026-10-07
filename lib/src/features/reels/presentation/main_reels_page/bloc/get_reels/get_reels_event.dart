part of 'get_reels_bloc.dart';

sealed class BaseGetReelsEvent extends Equatable {
  const BaseGetReelsEvent();
}

class GetReelsEvent extends BaseGetReelsEvent {
  final bool isLoading;
  final bool onRefresh;
  final bool initializeControllers;
  const GetReelsEvent(
      {this.isLoading = true,
      this.onRefresh = false,
      this.initializeControllers = false});

  @override
  List<Object?> get props => [isLoading];
}

class GetFollowingReelsEvent extends BaseGetReelsEvent {
  final bool isLoading;
  final bool onRefresh;
  const GetFollowingReelsEvent({this.isLoading = true, this.onRefresh = false});

  @override
  List<Object?> get props => [isLoading];
}

class GetOneReelEvent extends BaseGetReelsEvent {
  final ReelParam param;

  const GetOneReelEvent(this.param);

  @override
  List<Object?> get props => [param];
}

final class GetMoreReelsEvent extends BaseGetReelsEvent {
  final ReelsType filter;
  final String userId;
  const GetMoreReelsEvent(this.filter, {this.userId = ''});

  @override
  List<Object?> get props => [filter, userId];
}

final class DisposeControllersEvent extends BaseGetReelsEvent {
  const DisposeControllersEvent();
  @override
  List<Object?> get props => [];
}

final class InitializeControllersEvent extends BaseGetReelsEvent {
  const InitializeControllersEvent();
  @override
  List<Object?> get props => [];
}

class LocalMakeCommentsEvent extends BaseGetReelsEvent {
  final ReelParam param;
  final ReelsType filter;

  const LocalMakeCommentsEvent(this.param, this.filter);

  @override
  List<Object?> get props => [param, filter];
}

class LocalAddReelEvent extends BaseGetReelsEvent {
  final ReelsEntity newReel;

  const LocalAddReelEvent(this.newReel);

  @override
  List<Object?> get props => [newReel];
}

class LoadReelsEvent extends BaseGetReelsEvent {
  const LoadReelsEvent();

  @override
  List<Object?> get props => [];
}

class AddListenerMyReelsWithoutControllerEvent extends BaseGetReelsEvent {
  final String userID;

  const AddListenerMyReelsWithoutControllerEvent({required this.userID});
  @override
  List<Object?> get props => [userID];
}

class PageChangedEvent extends BaseGetReelsEvent {
  final int newIndex;
  final ReelsType filter;
  final bool isFilterChanged;
  final String userId;

  const PageChangedEvent(this.newIndex, this.filter, this.isFilterChanged,
      {this.userId = ''});
  @override
  List<Object?> get props => [newIndex, filter, isFilterChanged, userId];
}

class ToggleLikeEvent extends BaseGetReelsEvent {
  final int index;
  final ReelsType filter;

  const ToggleLikeEvent(this.index, this.filter);
  @override
  List<Object?> get props => [index, filter];
}

class PlayTappedReelEvent extends BaseGetReelsEvent {
  final int index;
  final ReelsType filter;

  const PlayTappedReelEvent(this.index, this.filter);
  @override
  List<Object?> get props => [index, filter];
}

class ToggleFollowEvent extends BaseGetReelsEvent {
  final int index;
  final ReelsType filter;

  const ToggleFollowEvent(this.index, this.filter);
  @override
  List<Object?> get props => [index, filter];
}

class CurrentReelCommentsViewedEvent extends BaseGetReelsEvent {
  final ReelsEntity reel;
  const CurrentReelCommentsViewedEvent({required this.reel});
  @override
  List<Object?> get props => [reel];
}

class ToggleReadMoreEvent extends BaseGetReelsEvent {
  const ToggleReadMoreEvent();

  @override
  List<Object?> get props => [];
}

class AnimateLikeEvent extends BaseGetReelsEvent {
  final int index;
  final ReelsType filter;
  const AnimateLikeEvent(this.index, this.filter);
  @override
  List<Object?> get props => [index, filter];
}

class ReplayReelEvent extends BaseGetReelsEvent {
  final int reelId;
  const ReplayReelEvent(this.reelId);
  @override
  List<Object?> get props => [reelId];
}

class RevertLikeEvent extends BaseGetReelsEvent {
  final int reelId;
  const RevertLikeEvent(this.reelId);
  @override
  List<Object?> get props => [reelId];
}

class RevertFollowEvent extends BaseGetReelsEvent {
  final int userId;
  final bool intendedFollow;
  const RevertFollowEvent(this.userId, this.intendedFollow);
  @override
  List<Object?> get props => [userId, intendedFollow];
}

class SeekVideoEvent extends BaseGetReelsEvent {
  final Duration position;
  final ReelsType filter;
  const SeekVideoEvent(this.position, this.filter);
  @override
  List<Object?> get props => [position, filter];
}

class UpdateIsSeekEvent extends BaseGetReelsEvent {
  final bool isSeeking;
  const UpdateIsSeekEvent(this.isSeeking);
  @override
  List<Object?> get props => [isSeeking];
}

final class OnRefreshReelsEvent extends BaseGetReelsEvent {
  const OnRefreshReelsEvent({required this.filter});
  final ReelsType filter;

  @override
  List<Object?> get props => [filter];
}

class VideoProgressUpdatedEvent extends BaseGetReelsEvent {
  final Duration position;
  final ReelsType filter;
  const VideoProgressUpdatedEvent(this.position, this.filter);
  @override
  List<Object?> get props => [position, filter];
}

class UpdateBottomPaddingEvent extends BaseGetReelsEvent {
  final double padding;
  const UpdateBottomPaddingEvent({required this.padding});
  @override
  List<Object?> get props => [padding];
}

class DeleteReelEvent extends BaseGetReelsEvent {
  final int index;
  final String reelId;

  const DeleteReelEvent(this.index, this.reelId);
  @override
  List<Object?> get props => [index, reelId];
}

class UpdateReelEvent extends BaseGetReelsEvent {
  final int index;
  final String description;
  final String reelId;
  const UpdateReelEvent(this.index, this.description, this.reelId);
  @override
  List<Object?> get props => [index, description, reelId];
}

class GetMyReels extends BaseGetReelsEvent {
  final bool isLoading;
  final String userId;
  const GetMyReels({this.isLoading = true, required this.userId});

  @override
  List<Object?> get props => [isLoading, userId];
}

class RemoveListenerEvent extends BaseGetReelsEvent {
  final String userId;

  const RemoveListenerEvent({required this.userId});
  @override
  List<Object?> get props => [userId];
}

class AddListenerEvent extends BaseGetReelsEvent {
  final String userId;

  const AddListenerEvent({required this.userId});
  @override
  List<Object?> get props => [userId];
}

class PauseAllControllersEvent extends BaseGetReelsEvent {
  const PauseAllControllersEvent();
  @override
  List<Object?> get props => [];
}

class ResetMyReelsEvent extends BaseGetReelsEvent {
  const ResetMyReelsEvent();
  @override
  List<Object?> get props => [];
}

class ResumeCurrentControllerEvent extends BaseGetReelsEvent {
  const ResumeCurrentControllerEvent();
  @override
  List<Object?> get props => [];
}
