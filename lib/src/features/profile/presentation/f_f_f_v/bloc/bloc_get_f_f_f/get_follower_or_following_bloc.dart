import 'dart:async';

import 'package:collection/collection.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/data/model/user_model.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_get_f_f_f/get_follower_or_following_event.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_get_f_f_f/get_follower_or_following_state.dart';

import '../../../../domain/profile_use_case/get_friends_or_followers_use_case.dart';
import '../../../../domain/profile_use_case/get_vistors_usecase.dart';

class GetFollowerOrFollowingBloc
    extends Bloc<BaseGetFollowerOrFollowingEvent, GetFollowerOrFollowingState> {
  final GetFriendsOrFollowersUseCase getFriendsOrFollowersUseCase;
  final GetVisitorsUc getVisitorsUc;

  GetFollowerOrFollowingBloc({
    required this.getFriendsOrFollowersUseCase,
    required this.getVisitorsUc,
  }) : super(GetFollowerOrFollowingState(
            controller: TextEditingController(),
            scrollControllerVisitor: ScrollController(),
            scrollControllerFriendsRequest: ScrollController(),
            scrollControllerFriends: ScrollController(),
            scrollControllerFollowers: ScrollController(),
            scrollControllerFollowing: ScrollController())) {
    on<GetFriendsEvent>(_getFriendsEvent);
    on<GetFollowersEvent>(_getFollowersEvent);
    on<GetFollowersThemEvent>(_getFollowersThemEvent);
    on<GetVisitorsEvent>(_getVisitors);
    on<GetFriendsRequestEvent>(_getFriendsRequest);

    on<AddListenerFriendsRequestEvent>(_addEventListenerFriendsRequest);
    on<AddListenerVisitorsEvent>(_addEventListenerVisitors);
    on<AddListenerFriendsEvent>(_addEventListenerFriends);
    on<AddListenerFollowersEvent>(_addEventListenerFollowers);
    on<AddListenerFollowingEvent>(_addEventListenerFollowing);

    on<RemoveListenerFriendsRequestEvent>(_removeEventListenerFriendsRequest);
    on<RemoveListenerVisitorsEvent>(_removeEventListenerVisitors);
    on<RemoveListenerFriendsEvent>(_removeEventListenerFriends);
    on<RemoveListenerFollowersEvent>(_removeEventListenerFollowers);
    on<RemoveListenerFollowingEvent>(_removeEventListenerFollowing);

    on<MakeFollowLocallyEvent>(makeFollowLocally);
    on<MakeUnfollowLocallyEvent>(makeUnfollowLocally);

    on<ChangeAppBarTitleEvent>(changeAppBarTitle);
    // on<SearchLocalEvent>(searchLocal);
    // on<ClearSearchLocalEvent>(clearSearchLocal);
    on<RemoveUserEvent>(_removeUser);
  }

  FutureOr<void> changeAppBarTitle(ChangeAppBarTitleEvent event,
      Emitter<GetFollowerOrFollowingState> emit) async {
    emit(state.copyWith(appBarTitle: event.title));
  }

  FutureOr<void> _getFriendsRequest(
    GetFriendsRequestEvent event,
    Emitter<GetFollowerOrFollowingState> emit,
  ) async {
    if (state.dataFriendsRequest.isNotEmpty && state.currentPageFriendsRequest > 1) {
      emit(state.copyWith(isPaginatingFriendsRequest: true));
    }
    final result = await getFriendsOrFollowersUseCase.call(FFFParameter(
        type: '6',
        page: state.currentPageFriendsRequest,
        keyWord: event.keyWord));
    result.fold(
        (left) => emit(state.copyWith(
            friendsRequestState: handleErrorResponse(left),
            isPaginatingFriendsRequest: false,
            errorFriendsRequest: NetworkExceptions.getErrorMessage(left))),
        (right) {
      emit(state.copyWith(
        lastPageFriendsRequest: right.paginates?.lastPage,
        friendsRequestState: handleLoadedResponse<List<UserModel>>(right.data),
        isPaginatingFriendsRequest: false,
        dataFriendsRequest: handlePaginationResponse<UserModel>(
          result: right.data,
          currentList: state.dataFriendsRequest,
          currentPage: state.currentPageFriendsRequest,
        ),
      ));
    });
  }

  FutureOr<void> _getFriendsEvent(
    GetFriendsEvent event,
    Emitter<GetFollowerOrFollowingState> emit,
  ) async {
    if (state.getFriends.isNotEmpty && state.currentPageFriends > 1) {
      emit(state.copyWith(isPaginatingFriends: true));
    }
    final result = await getFriendsOrFollowersUseCase.call(FFFParameter(
        type: '3', page: state.currentPageFriends, keyWord: event.keyWord));
    result.fold(
        (left) => emit(state.copyWith(
            getFriendsRequest: handleErrorResponse(left),
            isPaginatingFriends: false,
            getFriendsMessage: NetworkExceptions.getErrorMessage(left))),
        (right) {
      emit(state.copyWith(
        lastPageFriends: right.paginates?.lastPage,
        getFriendsRequest: handleLoadedResponse<List<UserModel>>(right.data),
        isPaginatingFriends: false,
        getFriends: handlePaginationResponse<UserModel>(
          result: right.data,
          currentList: state.getFriends,
          currentPage: state.currentPageFriends,
        ),
      ));
    });
  }

  FutureOr<void> _getFollowersEvent(GetFollowersEvent event,
      Emitter<GetFollowerOrFollowingState> emit) async {
    if (state.getFollowers.isNotEmpty && state.currentPageFollowers > 1) {
      emit(state.copyWith(isPaginatingFollowers: true));
    }
    final result = await getFriendsOrFollowersUseCase.call(FFFParameter(
        type: '2', page: state.currentPageFollowers, keyWord: event.keyWord));
    result.fold(
        (l) => emit(state.copyWith(
            getFollowersRequest: handleErrorResponse(l),
            isPaginatingFollowers: false,
            getFollowersMessage: NetworkExceptions.getErrorMessage(l))), (r) {
      emit(state.copyWith(
        lastPageFollowers: r.paginates?.lastPage,
        getFollowersRequest: handleLoadedResponse<List<UserModel>>(r.data),
        isPaginatingFollowers: false,
        getFollowers: handlePaginationResponse<UserModel>(
          result: r.data,
          currentList: state.getFollowers,
          currentPage: state.currentPageFollowers,
        ),
      ));
    });
  }

  FutureOr<void> _getFollowersThemEvent(GetFollowersThemEvent event,
      Emitter<GetFollowerOrFollowingState> emit) async {
    if (state.getFollowing.isNotEmpty && state.currentPageFollowing > 1) {
      emit(state.copyWith(isPaginatingFollowing: true));
    }
    final result = await getFriendsOrFollowersUseCase.call(FFFParameter(
        type: '1', page: state.currentPageFollowing, keyWord: event.keyWord));
    result.fold(
      (left) => emit(
        state.copyWith(
          getFollowingRequest: handleErrorResponse(left),
          isPaginatingFollowing: false,
          getFollowingMessage: NetworkExceptions.getErrorMessage(left),
        ),
      ),
      (right) {
        emit(
          state.copyWith(
            lastPageFollowing: right.paginates?.lastPage,
            getFollowingRequest:
                handleLoadedResponse<List<UserModel>>(right.data),
            isPaginatingFollowing: false,
            getFollowing: handlePaginationResponse<UserModel>(
              result: right.data,
              currentList: state.getFollowing,
              currentPage: state.currentPageFollowing,
            ),
          ),
        );
      },
    );
  }

  FutureOr<void> _getVisitors(
      GetVisitorsEvent event, Emitter<GetFollowerOrFollowingState> emit) async {
    if (event.loading) {
      emit(state.copyWith(getVisitorsRequest: RequestState.loading));
    } else if (state.getVisitors.isNotEmpty && state.currentPageVisitor > 1) {
      emit(state.copyWith(isPaginatingVisitors: true));
    }

    final result = await getVisitorsUc.call(FFFParameter(
        type: '1', page: state.currentPageVisitor, keyWord: event.keyWord));

    result.fold(
      (failure) {
        emit(state.copyWith(
          getVisitorsRequest: handleErrorResponse(failure),
          isPaginatingVisitors: false,
          getVisitorsMessage: NetworkExceptions.getErrorMessage(failure),
        ));
      },
      (visitorsResponse) {
        emit(state.copyWith(
          lastPageVisitor: visitorsResponse.paginates?.lastPage,
          getVisitorsRequest:
              handleLoadedResponse<List<UserModel>>(visitorsResponse.data),
          isPaginatingVisitors: false,
          getVisitors: handlePaginationResponse<UserModel>(
            result: visitorsResponse.data,
            currentList: state.getVisitors,
            currentPage: state.currentPageVisitor,
          ),
        ));
      },
    );
  }

  void _removeEventListenerVisitors(
    RemoveListenerVisitorsEvent event,
    Emitter<GetFollowerOrFollowingState> emit,
  ) {
    final visitorsScroll = state.scrollControllerVisitor
      ..removeListener(_listenerVisitorRooms);
    emit(state.copyWith(scrollControllerVisitor: visitorsScroll));
  }

  void _removeEventListenerFriends(
    RemoveListenerFriendsEvent event,
    Emitter<GetFollowerOrFollowingState> emit,
  ) {
    final friendsScroll = state.scrollControllerFriends
      ..removeListener(_listenerFriendsRooms);
    emit(state.copyWith(scrollControllerFriends: friendsScroll));
  }

  void _removeEventListenerFollowers(
    RemoveListenerFollowersEvent event,
    Emitter<GetFollowerOrFollowingState> emit,
  ) {
    final followersScroll = state.scrollControllerFollowers
      ..removeListener(_listenerFollowersRooms);
    emit(state.copyWith(scrollControllerFollowers: followersScroll));
  }

  void _removeEventListenerFollowing(
    RemoveListenerFollowingEvent event,
    Emitter<GetFollowerOrFollowingState> emit,
  ) {
    final scroll = state.scrollControllerFollowing
      ..removeListener(_listenerFollowingRooms);
    emit(state.copyWith(scrollControllerFollowing: scroll));
  }

  void _removeEventListenerFriendsRequest(
    RemoveListenerFriendsRequestEvent event,
    Emitter<GetFollowerOrFollowingState> emit,
  ) {
    final scroll = state.scrollControllerFriendsRequest
      ..removeListener(_listenerFriendsRequestRooms);
    emit(state.copyWith(scrollControllerFriendsRequest: scroll));
  }

  ///ListenerVisitors============>
  void _addEventListenerVisitors(
    AddListenerVisitorsEvent event,
    Emitter<GetFollowerOrFollowingState> emit,
  ) {
    final visitScrollCtrl = state.scrollControllerVisitor
      ..addListener(_listenerVisitorRooms);
    emit(state.copyWith(scrollControllerVisitor: visitScrollCtrl));
  }

  void _listenerVisitorRooms() {
    handleScrollListener(
      controller: state.scrollControllerVisitor,
      currentPage: state.currentPageVisitor,
      lastPage: state.lastPageVisitor,
      fun: () {
        final int currentPage = state.currentPageVisitor + 1;
        emit(state.copyWith(currentPageVisitor: currentPage));
        add(const GetVisitorsEvent());
      },
    );
  }

  ///ListenerFriendsRequest============>
  void _addEventListenerFriendsRequest(
    AddListenerFriendsRequestEvent event,
    Emitter<GetFollowerOrFollowingState> emit,
  ) {
    final visitScrollCtrl = state.scrollControllerFriendsRequest
      ..addListener(_listenerFriendsRequestRooms);
    emit(state.copyWith(scrollControllerFriendsRequest: visitScrollCtrl));
  }

  void _listenerFriendsRequestRooms() {
    handleScrollListener(
      controller: state.scrollControllerFriendsRequest,
      currentPage: state.currentPageFriendsRequest,
      lastPage: state.lastPageFriendsRequest,
      fun: () {
        final int currentPage = state.currentPageFriendsRequest + 1;
        emit(state.copyWith(currentPageFriendsRequest: currentPage));
        add(const GetFriendsRequestEvent());
      },
    );
  }

  ///ListenerFriends============>
  void _addEventListenerFriends(
    AddListenerFriendsEvent event,
    Emitter<GetFollowerOrFollowingState> emit,
  ) {
    final friendsScrollCtrl = state.scrollControllerFriends
      ..addListener(_listenerFriendsRooms);
    emit(state.copyWith(scrollControllerFriends: friendsScrollCtrl));
  }

  void _listenerFriendsRooms() {
    handleScrollListener(
      controller: state.scrollControllerFriends,
      currentPage: state.currentPageFriends,
      lastPage: state.lastPageFriends,
      fun: () {
        final int currentPage = state.currentPageFriends + 1;
        emit(state.copyWith(currentPageFriends: currentPage));
        add(const GetFriendsEvent());
      },
    );
  }

  ///ListenerFollowers============>
  void _addEventListenerFollowers(
    AddListenerFollowersEvent event,
    Emitter<GetFollowerOrFollowingState> emit,
  ) {
    final visitScrollCtrl = state.scrollControllerFollowers
      ..addListener(_listenerFollowersRooms);
    emit(state.copyWith(scrollControllerFollowers: visitScrollCtrl));
  }

  void _listenerFollowersRooms() {
    handleScrollListener(
      controller: state.scrollControllerFollowers,
      currentPage: state.currentPageFollowers,
      lastPage: state.lastPageFollowers,
      fun: () {
        final int currentPage = state.currentPageFollowers + 1;
        emit(state.copyWith(currentPageFollowers: currentPage));
        add(const GetFollowersEvent());
      },
    );
  }

  ///ListenerFollowing============>
  void _addEventListenerFollowing(
    AddListenerFollowingEvent event,
    Emitter<GetFollowerOrFollowingState> emit,
  ) {
    final visitScrollCtrl = state.scrollControllerFollowing
      ..addListener(_listenerFollowingRooms);
    emit(state.copyWith(scrollControllerFollowing: visitScrollCtrl));
  }

  void _listenerFollowingRooms() {
    handleScrollListener(
      controller: state.scrollControllerFollowing,
      currentPage: state.currentPageFollowing,
      lastPage: state.lastPageFollowing,
      fun: () {
        final int currentPage = state.currentPageFollowing + 1;
        emit(state.copyWith(currentPageFollowing: currentPage));
        add(const GetFollowersThemEvent());
      },
    );
  }

  FutureOr<void> makeFollowLocally(MakeFollowLocallyEvent event,
      Emitter<GetFollowerOrFollowingState> emit) async {
    final UserModel user;

    switch (event.relationType) {
      case RelationType.followers:
        {
// Block 1 - Handling followers
          final foundUser = state.getFollowers.firstWhereOrNull(
              (element) => element.id.toString() == event.userId);
          if (foundUser == null) {
            break;
          }
          user = foundUser;
// Update the follow status of the user
          final updatedUser = user.copyWith(isFriend: true, isFollow: true);

// Update global data model counts for follow action
          updateMyDataModelCounts(isFollowAction: true, isFriendIncrease: true);

// Update followers list with the modified user
          List<UserModel> updatedFollowers =
              updateFollowersList(updatedUser, state.getFollowers, true);

// Create updated friends and following lists
          List<UserModel> updatedFriends =
              addToList(updatedUser, state.getFriends);
          List<UserModel> updatedFollowing = updateFollowingsList(
              updatedUser, state.getFollowing, state.getVisitors);

// Emit the new state with updated lists
          emit(state.copyWith(
            getFollowers: updatedFollowers,
            getFriends: updatedFriends,
            getFollowing: updatedFollowing,
            getVisitors:
                state.getVisitors, // Assuming visitors remain unchanged
          ));
          break;
        }

      case RelationType.visitors:
        {
          // Find the user in the visitors list
          final user = state.getVisitors
              .firstWhereOrNull((element) => element.id.toString() == event.userId);
          if (user == null) {
            break;
          }

          // Update the user data
          final updatedUser = user.copyWith(isFriend: true, isFollow: true);

          // Update global data model
          MyDataModel.getInstance().copyWith(
            numberOfFollowings:
                (MyDataModel.getInstance().numberOfFollowings ?? 0) + 1,
            numberOfFriends:
                (MyDataModel.getInstance().numberOfFriends ?? 0) + 1,
          );

          // Update visitors list with the modified user
          final updatedVisitors = state.getVisitors.map((visitor) {
            return visitor.id == updatedUser.id ? updatedUser : visitor;
          }).toList();

          // Add the updated user to friends and following lists
          final updatedFriends = List.of(state.getFriends)
            ..insert(0, updatedUser);
          final updatedFollowing = List.of(state.getFollowing)
            ..insert(0, updatedUser);

          // Emit the updated state
          emit(state.copyWith(
            getVisitors: updatedVisitors,
            getFriends: updatedFriends,
            getFollowing: updatedFollowing,
          ));
          break;
        }
      case RelationType.friendsRequest:
        {
          // Find the user in the visitors list
          final user = state.dataFriendsRequest
              .firstWhereOrNull((element) => element.id.toString() == event.userId);
          if (user == null) {
            break;
          }

          int followerIndex = state.dataFriendsRequest
              .indexWhere((friend) => friend.id == user.id);
          if (followerIndex == -1) {
            break;
          }
          // Update the user data
          //final updatedUser = user.copyWith(isFriend: true, isFollow: true);

          // Update global data model
          MyDataModel.getInstance().copyWith(
            numberOfFollowings:
                (MyDataModel.getInstance().numberOfFollowings ?? 0) + 1,
            numberOfFriends:
                (MyDataModel.getInstance().numberOfFriends ?? 0) + 1,
          );

          // Add the updated user to friends and following lists
          final updatedFriends = List.of(state.dataFriendsRequest)
            ..insert(0, state.dataFriendsRequest[followerIndex]);
          // Update visitors list with the modified user
          final updatedVisitors = List.of(state.dataFriendsRequest)
            ..removeAt(followerIndex);

          // Emit the updated state
          emit(state.copyWith(
            dataFriendsRequest: updatedVisitors,
            getFriends: updatedFriends,
          ));
          break;
        }

      case RelationType.reels:
        {
          final UserModel? user = event.userModel;
          if (user == null) {
            break;
          }

          final bool isFollower = state.getFollowing.any(
            (element) => element.id.toString() == (user.id ?? 0).toString(),
          );

          final updatedUser =
              user.copyWith(isFriend: isFollower, isFollow: true);

          final myData = MyDataModel.getInstance();
          MyDataModel.getInstance().copyWith(
            numberOfFollowings: (myData.numberOfFollowings ?? 0) + 1,
            numberOfFriends: isFollower
                ? (myData.numberOfFriends ?? 0) + 1
                : (myData.numberOfFriends ?? 0),
          );

          // Update friends list if the user is a follower
          final List<UserModel> updatedFriends = isFollower
              ? (List.of(state.getFriends)..insert(0, updatedUser))
              : state.getFriends;

          final updatedFollowing = List.of(state.getFollowing);
          if (!updatedFollowing.any((f) => f.id == updatedUser.id)) {
            updatedFollowing.insert(0, updatedUser);
          }

          emit(state.copyWith(
            getFriends: updatedFriends,
            getFollowing: updatedFollowing,
          ));
          break;
        }

      default:
        break;
    }
  }

  FutureOr<void> makeUnfollowLocally(MakeUnfollowLocallyEvent event,
      Emitter<GetFollowerOrFollowingState> emit) async {
    switch (event.relationType) {
      case RelationType.friends:
        {
          final user = findUser(state.getFriends, event.userId);
          if (user == null) break;

          updateMyDataModelCounts(
              isFriendsDecrease: true, isUnfollowAction: true);

          List<UserModel> updatedFriends =
              removeFromList(user, state.getFriends);
          List<UserModel> updatedFollowing =
              removeFromList(user, state.getFollowing);
          List<UserModel> updatedFollowers =
              updateFollowersList(user, state.getFollowers, false);
          List<UserModel> updatedVisitors =
              updateFollowersList(user, state.getVisitors, false);

          // Emit the new state
          emit(state.copyWith(
            getFriends: updatedFriends,
            getFollowers: updatedFollowers,
            getFollowing: updatedFollowing,
            getVisitors: updatedVisitors,
          ));
          break;
        }
      case RelationType.following:
        {
          final user = findUser(state.getFollowing, event.userId);
          if (user == null) break;

          // Update counts
          updateMyDataModelCounts(
              isFriendsDecrease: user.isFollowingMe == true,
              isUnfollowAction: true);

          // Update lists
          List<UserModel> updatedFriends =
              removeFromList(user, state.getFriends);
          List<UserModel> updatedFollowing =
              removeFromList(user, state.getFollowing);
          List<UserModel> updatedFollowers =
              updateFollowersList(user, state.getFollowers, false);
          List<UserModel> updatedVisitors =
              updateFollowersList(user, state.getVisitors, false);

          // Emit the new state
          emit(state.copyWith(
            getFriends: updatedFriends,
            getFollowers: updatedFollowers,
            getFollowing: updatedFollowing,
            getVisitors: updatedVisitors,
          ));
          break;
        }
      case RelationType.followers:
        {
          final user = findUser(state.getFollowers, event.userId);
          if (user == null) break;

          // Update counts
          updateMyDataModelCounts(
            isFriendsDecrease: user.isFollowingMe == true,
          );

          // Update lists
          List<UserModel> updatedFriends =
              removeFromList(user, state.getFriends);
          List<UserModel> updatedFollowing =
              removeFromList(user, state.getFollowing);
          List<UserModel> updatedFollowers =
              updateFollowersList(user, state.getFollowers, false);
          List<UserModel> updatedVisitors =
              updateFollowersList(user, state.getVisitors, false);

          // Emit the new state
          emit(state.copyWith(
            getFriends: updatedFriends,
            getFollowers: updatedFollowers,
            getFollowing: updatedFollowing,
            getVisitors: updatedVisitors,
          ));
          break;
        }
      case RelationType.visitors:
        {
          final user = findUser(state.getVisitors, event.userId);
          if (user == null) break;

          // Update counts
          updateMyDataModelCounts(
            isUnfollowAction: true,
            isFriendsDecrease: user.isFollowingMe == true,
          );

          // Update lists
          List<UserModel> updatedFriends =
              removeFromList(user, state.getFriends);
          List<UserModel> updatedFollowing =
              removeFromList(user, state.getFollowing);
          List<UserModel> updatedFollowers =
              updateFollowersList(user, state.getFollowers, false);
          List<UserModel> updatedVisitors =
              updateFollowersList(user, state.getVisitors, false);

          // Emit the new state
          emit(state.copyWith(
            getFriends: updatedFriends,
            getFollowers: updatedFollowers,
            getFollowing: updatedFollowing,
            getVisitors: updatedVisitors,
          ));
          break;
        }
      case RelationType.profile:
        break;
      case RelationType.friendsRequest:
        {
          final user = findUser(state.dataFriendsRequest, event.userId);
          if (user == null) break;

          // Update counts
          updateMyDataModelCounts(
            isFriendsDecrease: user.isFollowingMe == true,
          );

          // Update lists
          List<UserModel> updatedFriends =
              removeFromList(user, state.dataFriendsRequest);

          // Emit the new state
          emit(state.copyWith(
            dataFriendsRequest: updatedFriends,
          ));
          break;
        }
      case RelationType.reels:
    }
  }

//handle my data model counts in follow and unfollow action
  void updateMyDataModelCounts({
    bool isFriendsDecrease =
        false, // Whether this follow action cuts a friendship
    bool isUnfollowAction = false, // Whether the current action is a unfollow
    bool isFollowAction = false, // Whether the current action is a follow
    bool isFriendIncrease =
        false, // Whether this follow action creates a friendship
  }) {
    // Handle following counts for both unfollow and follow actions
    int numberOfFollowings =
        (MyDataModel.getInstance().numberOfFollowings ?? 0) +
            (isFollowAction ? 1 : 0) -
            (isUnfollowAction ? 1 : 0);

    // Handle friends counts for both unfollow and follow actions
    int numberOfFriends = (MyDataModel.getInstance().numberOfFriends ?? 0) +
        (isFriendIncrease ? 1 : 0) -
        (isFriendsDecrease ? 1 : 0);

    // Update the data model with the new counts
    MyDataModel.getInstance().copyWith(
      numberOfFollowings: numberOfFollowings,
      numberOfFriends: numberOfFriends,
    );
  }

  // Find the user in the specified list (friends, following, or followers)
  UserModel? findUser(List<UserModel> list, String userId) {
    return list.firstWhereOrNull((element) => element.id.toString() == userId);
  }

  // Update the followers list based on the user's status
  List<UserModel> updateFriendsRequestList(
      UserModel user, List<UserModel> friendsRequest, bool isFollow) {
    List<UserModel> updatedFriendRequest = List.of(friendsRequest);
    int followerIndex =
        updatedFriendRequest.indexWhere((friend) => friend.id == user.id);
    if (followerIndex != -1) {
      updatedFriendRequest[followerIndex] =
          updatedFriendRequest[followerIndex].copyWith(isFollow: isFollow);
    }
    updatedFriendRequest
        .remove(user); // Only remove if they are not following me
    return updatedFriendRequest;
  }

  // Update the followers list based on the user's status
  List<UserModel> updateFollowersList(
      UserModel user, List<UserModel> followers, bool isFollow) {
    List<UserModel> updatedFollowers = List.of(followers);
    int followerIndex =
        updatedFollowers.indexWhere((follower) => follower.id == user.id);
    if (followerIndex != -1) {
      updatedFollowers[followerIndex] =
          updatedFollowers[followerIndex].copyWith(isFollow: isFollow);
    }
    if (user.isFollowingMe != true) {
      updatedFollowers.remove(user); // Only remove if they are not following me
    }
    return updatedFollowers;
  }

  List<UserModel> updateFollowingsList(
    UserModel user,
    List<UserModel> followings, // The current list of followings
    List<UserModel> initialList,
    // The list from which the user is being followed (e.g., visitors or followers)
  ) {
    // Step 1: Update the initial list (the list user is coming from)
    List<UserModel> updatedInitial = List.of(initialList);
    int initialIndex = updatedInitial.indexWhere((item) => item.id == user.id);
    if (initialIndex != -1) {
      // Mark the user as followed in the initial list
      updatedInitial[initialIndex] =
          updatedInitial[initialIndex].copyWith(isFollow: true);
    }

    // Step 2: Add the user to the followings list
    List<UserModel> updatedFollowings = List.of(followings);
    updatedFollowings
        .add(user.copyWith(isFollow: true)); // Ensure isFollow is true

    return updatedFollowings;
  }

  // Handle the removal of user from lists
  List<UserModel> removeFromList(UserModel user, List<UserModel> list) {
    return List.of(list)..remove(user);
  }

  // Handle the addition of user to lists
  List<UserModel> addToList(UserModel user, List<UserModel> list) {
    return List.of(list)..add(user);
  }

  @override
  Future<void> close() {
    state.controller.dispose();
    return super.close();
  }

  FutureOr<void> _removeUser(
    RemoveUserEvent event,
    Emitter<GetFollowerOrFollowingState> emit,
  ) {
    final String id = event.userId;

    List<UserModel> updatedFollowList = List.from(state.getFollowing);
    List<UserModel> updatedFollowersList = List.from(state.getFollowers);
    List<UserModel> updatedVistorList = List.from(state.getVisitors);
    List<UserModel> updatedFriendsList = List.from(state.getFriends);
    List<UserModel> updatedLocal = List.from(state.localSearch);
    updatedFollowList.removeWhere((e) => e.id.toString() == id);
    updatedFollowersList.removeWhere((e) => e.id.toString() == id);
    updatedVistorList.removeWhere((e) => e.id.toString() == id);
    updatedFriendsList.removeWhere((e) => e.id.toString() == id);
    updatedLocal.removeWhere((e) => e.id.toString() == id);

    emit(state.copyWith(
      dataFriendsRequest: updatedFriendsList,
      getFollowers: updatedFollowersList,
      getFollowing: updatedFollowList,
      getVisitors: updatedVistorList,
      localSearch: updatedLocal,
    ));
  }
}
