part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  final bool isLastCreateLoading,
      isPopularLoading,
      isGlobalLoading,
      isFollowLoading,
      isLiveLoading,
      isFriendsLoading,
      isHostLevelsLoading;

  final int currentIndex, myRoomTabControllerIndex;
  final int popularIndex;
  final int globalIndex;
  final int followIndex;
  final int friendsIndex;
  final int streamIndex;

  final String stageId;

  const HomeEvent({
    this.isPopularLoading = true,
    this.isLiveLoading = true,
    this.isGlobalLoading = true,
    this.isFollowLoading = true,
    this.isFriendsLoading = true,
    this.isLastCreateLoading = true,
    this.currentIndex = 1,
    this.popularIndex = 0,
    this.globalIndex = 0,
    this.followIndex = 0,
    this.friendsIndex = 0,
    this.streamIndex = 0,
    this.myRoomTabControllerIndex = 0,
    this.stageId = '-1',
    this.isHostLevelsLoading = true,
  });
  @override
  List<Object?> get props => [
        isPopularLoading,
        isGlobalLoading,
        isFollowLoading,
        isLiveLoading,
        currentIndex,
        stageId,
        isHostLevelsLoading,
      ];
}

final class FetchPopularRoomsEvent extends HomeEvent {
  final bool? isFirstPage;
  final int? countryId;
  const FetchPopularRoomsEvent({
    super.isPopularLoading,
    this.countryId,
    this.isFirstPage,
  });
}

final class FilterPopularRoomsEvent extends HomeEvent {
  final int? countryId;
  final bool? isLoading;
  final bool isFirstPage;

  const FilterPopularRoomsEvent({
    this.countryId,
    this.isLoading,
    this.isFirstPage = false,
  });
}

final class FetchLiveRoomsEvent extends HomeEvent {
  final bool? isFirstPage;
  const FetchLiveRoomsEvent({super.isLiveLoading, this.isFirstPage});
}

final class FetchGlobalRoomsEvent extends HomeEvent {
  final int? globalCountryId;
  final bool? isFirstPage;
  const FetchGlobalRoomsEvent({
    super.isGlobalLoading,
    this.globalCountryId,
    this.isFirstPage,
  });
}

final class FetchFollowRoomsEvent extends HomeEvent {
  final bool isFirstPage;
  const FetchFollowRoomsEvent({
    super.isFollowLoading,
    this.isFirstPage = false,
  });
}

final class FetchLastCreateRoomsEvent extends HomeEvent {
  const FetchLastCreateRoomsEvent({super.isLastCreateLoading});
}

final class FetchFriendsRoomsEvent extends HomeEvent {
  final bool isFirstPage;
  const FetchFriendsRoomsEvent({
    super.isFriendsLoading,
    this.isFirstPage = false,
  });
}

final class PopularAddListenerEvent extends HomeEvent {
  const PopularAddListenerEvent();
}

final class GlobalAddListenerEvent extends HomeEvent {
  const GlobalAddListenerEvent();
}

final class FollowAddListenerEvent extends HomeEvent {
  const FollowAddListenerEvent();
}

final class LastCreateLAddListenerEvent extends HomeEvent {
  const LastCreateLAddListenerEvent();
}

final class FriendsAddListenerEvent extends HomeEvent {
  const FriendsAddListenerEvent();
}

final class FilterAddListenerEvent extends HomeEvent {
  const FilterAddListenerEvent();
}

final class PopularRemoveListenerEvent extends HomeEvent {
  const PopularRemoveListenerEvent();
}

final class GlobalRemoveListenerEvent extends HomeEvent {
  const GlobalRemoveListenerEvent();
}

final class FollowRemoveListenerEvent extends HomeEvent {
  const FollowRemoveListenerEvent();
}

final class LastCreateRemoveListenerEvent extends HomeEvent {
  const LastCreateRemoveListenerEvent();
}

final class FriendsRemoveListenerEvent extends HomeEvent {
  const FriendsRemoveListenerEvent();
}

final class FilterRemoveListenerEvent extends HomeEvent {
  const FilterRemoveListenerEvent();
}

final class ChangeCurrentIndexEvent extends HomeEvent {
  const ChangeCurrentIndexEvent({super.currentIndex});
}

final class LiveAddListenerEvent extends HomeEvent {
  const LiveAddListenerEvent();
}

final class LiveRemoveListenerEvent extends HomeEvent {
  const LiveRemoveListenerEvent();
}

final class FetchHostLevelsEvent extends HomeEvent {
  const FetchHostLevelsEvent({super.isHostLevelsLoading});
}

final class PickBoxEvent extends HomeEvent {
  final BuildContext context;

  const PickBoxEvent({required this.context, required super.stageId});

  @override
  List<Object?> get props => [context];
}
