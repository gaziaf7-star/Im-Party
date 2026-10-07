part of 'make_like_bloc.dart';


abstract class BaseMakeLikeEvent extends Equatable {
  const BaseMakeLikeEvent();

  @override
  List<Object?> get props => [];
}

class MakeLikeEvent extends BaseMakeLikeEvent {
  final String reelId;

  const MakeLikeEvent(this.reelId);

  @override
  List<Object?> get props => [reelId];
}

/// Internal event fired when a reel's debounce window elapses, flushing the
/// coalesced toggles into (at most) one network call.
class _FlushLikeEvent extends BaseMakeLikeEvent {
  final String reelId;

  const _FlushLikeEvent(this.reelId);

  @override
  List<Object?> get props => [reelId];
}
