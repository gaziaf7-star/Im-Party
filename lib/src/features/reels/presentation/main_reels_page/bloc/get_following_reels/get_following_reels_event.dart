part of 'get_following_reels_bloc.dart';


sealed class BaseGetFollowingReelsEvent extends Equatable {
  const BaseGetFollowingReelsEvent();

  @override
  List<Object?> get props => [];
}

class GetFollowingReelsEvent extends BaseGetFollowingReelsEvent {
  final ReelParam param;

  const GetFollowingReelsEvent(this.param);

  @override
  List<Object?> get props => [param];
}