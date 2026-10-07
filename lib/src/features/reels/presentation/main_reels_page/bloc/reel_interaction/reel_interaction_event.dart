part of 'reel_interaction_bloc.dart';

sealed class ReelInteractionEvent extends Equatable {
  const ReelInteractionEvent();
}

class InteractionToggleLikeEvent extends ReelInteractionEvent {
  final int index;
  final ReelsType filter;
  const InteractionToggleLikeEvent(this.index, this.filter);
  @override
  List<Object?> get props => [index, filter];
}

class InteractionToggleFollowEvent extends ReelInteractionEvent {
  final int index;
  final ReelsType filter;
  const InteractionToggleFollowEvent(this.index, this.filter);
  @override
  List<Object?> get props => [index, filter];
}

class InteractionAnimateLikeEvent extends ReelInteractionEvent {
  final int index;
  final ReelsType filter;
  const InteractionAnimateLikeEvent(this.index, this.filter);
  @override
  List<Object?> get props => [index, filter];
}

class InteractionMakeCommentEvent extends ReelInteractionEvent {
  final String reelId;
  const InteractionMakeCommentEvent(this.reelId);
  @override
  List<Object?> get props => [reelId];
}

class InteractionRevertLikeEvent extends ReelInteractionEvent {
  final int reelId;
  const InteractionRevertLikeEvent(this.reelId);
  @override
  List<Object?> get props => [reelId];
}

class InteractionRevertFollowEvent extends ReelInteractionEvent {
  final int userId;
  final bool intendedFollow;
  const InteractionRevertFollowEvent(this.userId, this.intendedFollow);
  @override
  List<Object?> get props => [userId, intendedFollow];
}

class InteractionToggleReadMoreEvent extends ReelInteractionEvent {
  const InteractionToggleReadMoreEvent();
  @override
  List<Object?> get props => [];
}

class InteractionUpdateBottomPaddingEvent extends ReelInteractionEvent {
  final double padding;
  const InteractionUpdateBottomPaddingEvent({required this.padding});
  @override
  List<Object?> get props => [padding];
}

class InteractionCurrentReelCommentsViewedEvent extends ReelInteractionEvent {
  final ReelsEntity reel;
  const InteractionCurrentReelCommentsViewedEvent({required this.reel});
  @override
  List<Object?> get props => [reel];
}
