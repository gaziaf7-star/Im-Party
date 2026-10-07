import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/data/model/user_model.dart';

class GetFollowerOrFollowingState extends Equatable {
  final List<UserModel> getFriends;
  final RequestState getFriendsRequest;
  final String getFriendsMessage;

  final List<UserModel> getFollowers;
  final RequestState getFollowersRequest;
  final String getFollowersMessage;

  final List<UserModel> dataFriendsRequest;
  final RequestState friendsRequestState;
  final String errorFriendsRequest;

  final List<UserModel> getFollowing;
  final RequestState getFollowingRequest;
  final String getFollowingMessage;

  final List<UserModel> getVisitors;
  final RequestState getVisitorsRequest;
  final String getVisitorsMessage;
  final RelationType currentRelationType;

  final bool isPaginatingFollowing,
      isPaginatingFollowers,
      isPaginatingFriends,
      isPaginatingVisitors,
      isPaginatingFriendsRequest;

  final int currentPageVisitor,
      lastPageVisitor,currentPageFollowing,
      lastPageFollowing,currentPageFollowers,
      lastPageFriendsRequest,currentPageFriendsRequest,
      lastPageFollowers,currentPageFriends,
      lastPageFriends;
  final ScrollController scrollControllerFriendsRequest,scrollControllerVisitor,scrollControllerFollowing,scrollControllerFollowers,scrollControllerFriends;
  final String appBarTitle;
  final List<UserModel> localSearch;
final TextEditingController controller;
  const GetFollowerOrFollowingState({
    this.getFriends = const [],
    this.getFriendsRequest = RequestState.loading,
    this.errorFriendsRequest = "",
    this.dataFriendsRequest = const [],
    this.friendsRequestState = RequestState.loading,
    this.getFriendsMessage = "",
    this.getFollowers = const [],
    this.getFollowersRequest = RequestState.loading,
    this.getFollowersMessage = "",
    this.getFollowing = const [],
    this.getFollowingRequest = RequestState.loading,
    this.getFollowingMessage = "",
    this.getVisitors = const [],
    this.getVisitorsRequest = RequestState.loading,
    this.getVisitorsMessage = "",
    this.appBarTitle = "",
    this.lastPageVisitor = -1,
    this.lastPageFollowing = -1,
    this.lastPageFollowers = -1,
    this.lastPageFriends = -1,
    this.lastPageFriendsRequest = -1,
    this.currentPageVisitor = 1,
    this.currentPageFollowing = 1,
    this.currentPageFollowers = 1,
    this.currentPageFriends = 1,
    this.currentPageFriendsRequest= 1,
    this.localSearch = const [],
    required this.scrollControllerVisitor,
    required this.scrollControllerFriends,
    required this.scrollControllerFollowers,
    required this.scrollControllerFollowing,
    required this.scrollControllerFriendsRequest,
   required this.controller  ,
    this.currentRelationType = RelationType.followers,
    this.isPaginatingFollowing = false,
    this.isPaginatingFollowers = false,
    this.isPaginatingFriends = false,
    this.isPaginatingVisitors = false,
    this.isPaginatingFriendsRequest = false,
  });

  GetFollowerOrFollowingState copyWith({
    List<UserModel>? getFriends,
    RequestState? getFriendsRequest,
    String? getFriendsMessage,
    List<UserModel>? dataFriendsRequest,
    RequestState? friendsRequestState,
    String? errorFriendsRequest,
    List<UserModel>? getFollowers,
    RequestState? getFollowersRequest,
    String? getFollowersMessage,
    List<UserModel>? getFollowing,
    RequestState? getFollowingRequest,
    String? getFollowingMessage,
    List<UserModel>? getVisitors,
    RequestState? getVisitorsRequest,
    String? getVisitorsMessage,
    String? appBarTitle,
    List<UserModel>? localSearch,
    String? controller,
    int? currentPageVisitor,
    int? currentPageFollowing,
    int? currentPageFollowers,
    int? currentPageFriends,
    int? currentPageFriendsRequest,
    int? lastPageVisitor,
    int? lastPageFollowing,
    int? lastPageFollowers,
    int? lastPageFriends,
    int? lastPageFriendsRequest,
    ScrollController? scrollControllerVisitor,
    ScrollController? scrollControllerFollowing,
    ScrollController? scrollControllerFollowers,
    ScrollController? scrollControllerFriends,
    ScrollController? scrollControllerFriendsRequest,
    RelationType? currentRelationType,
    bool? isPaginatingFollowing,
    bool? isPaginatingFollowers,
    bool? isPaginatingFriends,
    bool? isPaginatingVisitors,
    bool? isPaginatingFriendsRequest,
  }) {
    return GetFollowerOrFollowingState(
      dataFriendsRequest: dataFriendsRequest ?? this.dataFriendsRequest,
      friendsRequestState: friendsRequestState ?? this.friendsRequestState,
      errorFriendsRequest: errorFriendsRequest ?? this.errorFriendsRequest,
      getFriends: getFriends ?? this.getFriends,
      getFriendsRequest: getFriendsRequest ?? this.getFriendsRequest,
      getFriendsMessage: getFriendsMessage ?? this.getFriendsMessage,
      getFollowers: getFollowers ?? this.getFollowers,
      getFollowersRequest: getFollowersRequest ?? this.getFollowersRequest,
      getFollowersMessage: getFollowersMessage ?? this.getFollowersMessage,
      getFollowing: getFollowing ?? this.getFollowing,
      getFollowingRequest: getFollowingRequest ?? this.getFollowingRequest,
      getFollowingMessage: getFollowingMessage ?? this.getFollowingMessage,
      getVisitors: getVisitors ?? this.getVisitors,
      getVisitorsRequest: getVisitorsRequest ?? this.getVisitorsRequest,
      getVisitorsMessage: getVisitorsMessage ?? this.getVisitorsMessage,
      appBarTitle: appBarTitle ?? this.appBarTitle,
      localSearch: localSearch ?? this.localSearch,
      lastPageVisitor: lastPageVisitor ?? this.lastPageVisitor,
      lastPageFriends: lastPageFriends ?? this.lastPageFriends,
      lastPageFollowers: lastPageFollowers ?? this.lastPageFollowers,
      lastPageFollowing: lastPageFollowing ?? this.lastPageFollowing,
      lastPageFriendsRequest: lastPageFriendsRequest ?? this.lastPageFriendsRequest,
      currentPageVisitor: currentPageVisitor ?? this.currentPageVisitor,
      currentPageFollowing: currentPageFollowing ?? this.currentPageFollowing,
      currentPageFriends: currentPageFriends ?? this.currentPageFriends,
      currentPageFollowers: currentPageFollowers ?? this.currentPageFollowers,
      currentPageFriendsRequest: currentPageFriendsRequest ?? this.currentPageFriendsRequest,
      scrollControllerVisitor: scrollControllerVisitor ?? this.scrollControllerVisitor,
      scrollControllerFriends: scrollControllerFriends ?? this.scrollControllerFriends,
      scrollControllerFollowers: scrollControllerFollowers ?? this.scrollControllerFollowers,
      scrollControllerFollowing: scrollControllerFollowing ?? this.scrollControllerFollowing,
      scrollControllerFriendsRequest: scrollControllerFriendsRequest ?? this.scrollControllerFriendsRequest,
      currentRelationType: currentRelationType ?? this.currentRelationType,
      isPaginatingFollowing: isPaginatingFollowing ?? this.isPaginatingFollowing,
      isPaginatingFollowers: isPaginatingFollowers ?? this.isPaginatingFollowers,
      isPaginatingFriends: isPaginatingFriends ?? this.isPaginatingFriends,
      isPaginatingVisitors: isPaginatingVisitors ?? this.isPaginatingVisitors,
      isPaginatingFriendsRequest: isPaginatingFriendsRequest ?? this.isPaginatingFriendsRequest,

      controller: this.controller.copyWith(
        text: controller
      ),

    );
  }

  @override
  List<Object?> get props => [
    getFriends,
    getFriendsMessage,
    getFriendsRequest,
        getFollowersMessage,
        getFollowersRequest,
        getFollowers,
        getFollowing,
        getFollowingRequest,
        getFollowingMessage,
        getVisitors,
        getVisitorsRequest,
        getVisitorsMessage,
        appBarTitle,
        localSearch,
    controller,
    dataFriendsRequest,
    friendsRequestState,
    errorFriendsRequest,
    currentPageFriends,
    lastPageFriends,
    lastPageFriendsRequest,
    scrollControllerFriends,
    currentPageFollowers,
    currentPageFriendsRequest,
    lastPageFollowers,
    scrollControllerFollowers,
    currentPageFollowing,
    lastPageFollowing,
    scrollControllerFollowing,
    scrollControllerFriendsRequest,
    currentPageVisitor,
    lastPageVisitor,
    scrollControllerVisitor,
    currentRelationType,
    isPaginatingFollowing,
    isPaginatingFollowers,
    isPaginatingFriends,
    isPaginatingVisitors,
    isPaginatingFriendsRequest,
      ];
}
