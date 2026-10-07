part of 'get_my_data_bloc.dart';

abstract class BaseGetMyDataEvent extends Equatable {
  const BaseGetMyDataEvent();

  @override
  List<Object?> get props => [];
}

class FetchMyDataEvent extends BaseGetMyDataEvent {
  final bool isLoading;
  // Retained for caller compatibility (layout pages still pass it). Now inert:
  // realtime is Centrifugo-only and wired on every my-data load, so there is no
  // separate legacy realtime init to trigger.
  final bool initRealtime;
  const FetchMyDataEvent({this.isLoading = true, this.initRealtime = false});

  @override
  List<Object?> get props => [isLoading, initRealtime];
}

class FetchUserEvent extends BaseGetMyDataEvent {
  final String userId;
  final bool? isVisit;
  final bool isLoading;

  const FetchUserEvent(
      {required this.userId, this.isVisit, this.isLoading = true});

  @override
  List<Object?> get props => [userId, isVisit, isLoading];
}

class UpdateLocalDataEvent extends BaseGetMyDataEvent {
  final MyDataModel userEntity;

  const UpdateLocalDataEvent({required this.userEntity});

  @override
  List<Object?> get props => [userEntity];
}

class UnreadCounterIndividualEvent extends BaseGetMyDataEvent {
  const UnreadCounterIndividualEvent();
}

class UnReadCounterFriendsEvent extends BaseGetMyDataEvent {
  const UnReadCounterFriendsEvent();
}

class UpdatePlayGameEvent extends BaseGetMyDataEvent {
  final bool canPlay;
  final bool showInviteCode;

  const UpdatePlayGameEvent(
      {required this.canPlay, required this.showInviteCode});

  @override
  List<Object?> get props => [canPlay, showInviteCode];
}

class UnReadCounterFollowingsEvent extends BaseGetMyDataEvent {
  const UnReadCounterFollowingsEvent();
}

class UnReadCounterFollowersEvent extends BaseGetMyDataEvent {
  const UnReadCounterFollowersEvent();
}

class UnReadCounterVistorsEvent extends BaseGetMyDataEvent {
  const UnReadCounterVistorsEvent();
}

class UnReadCounterMyBagEvent extends BaseGetMyDataEvent {
  const UnReadCounterMyBagEvent();
}

class UnReadCounterMallEvent extends BaseGetMyDataEvent {
  const UnReadCounterMallEvent();
}

class UnReadCounterSystemMessagesEvent extends BaseGetMyDataEvent {
  const UnReadCounterSystemMessagesEvent();
}

class UnReadCounterOfficialMessagesEvent extends BaseGetMyDataEvent {
  const UnReadCounterOfficialMessagesEvent();
}

class ReadCounterFriendsEvent extends BaseGetMyDataEvent {
  const ReadCounterFriendsEvent();
}

class ReadCounterFollowingsEvent extends BaseGetMyDataEvent {
  const ReadCounterFollowingsEvent();
}

class ReadCounterFollowersEvent extends BaseGetMyDataEvent {
  const ReadCounterFollowersEvent();
}

class ReadCounterVistorsEvent extends BaseGetMyDataEvent {
  const ReadCounterVistorsEvent();
}

class ReadCounterMyBagEvent extends BaseGetMyDataEvent {
  const ReadCounterMyBagEvent();
}

class ReadCounterMallEvent extends BaseGetMyDataEvent {
  const ReadCounterMallEvent();
}

class ReadCounterSystemMessagesEvent extends BaseGetMyDataEvent {
  const ReadCounterSystemMessagesEvent();
}

class ReadCounterOfficialMessagesEvent extends BaseGetMyDataEvent {
  const ReadCounterOfficialMessagesEvent();
}

class ReadCounterChatsMessagesEvent extends BaseGetMyDataEvent {
  final int count;
  const ReadCounterChatsMessagesEvent({required this.count});
}

class UnReadCounterChatsMessagesEvent extends BaseGetMyDataEvent {
  final int count;
  const UnReadCounterChatsMessagesEvent({required this.count});
}

class ScrollOffsetChangedEvent extends BaseGetMyDataEvent {
  final double offset;

  const ScrollOffsetChangedEvent(this.offset);
}

class ResetShowTitleEvent extends BaseGetMyDataEvent {}

class ShowTitleEvent extends BaseGetMyDataEvent {
  final bool show;

  const ShowTitleEvent(this.show);
}

class UpdateCurrentIndexEvent extends BaseGetMyDataEvent {
  final int newIndex;
  const UpdateCurrentIndexEvent(this.newIndex);

  @override
  List<Object?> get props => [newIndex];
}

class UpdateLengthIndicatorEvent extends BaseGetMyDataEvent {
  final int length;
  const UpdateLengthIndicatorEvent(this.length);

  @override
  List<Object?> get props => [length];
}

class UpdateDataEvent extends BaseGetMyDataEvent {
  final String type;
  const UpdateDataEvent(this.type);

  @override
  List<Object?> get props => [type];
}

class FetchUsersDataEvent extends BaseGetMyDataEvent {
  final List<String> userIds;
  const FetchUsersDataEvent({required this.userIds});

  @override
  List<Object?> get props => [userIds];
}
