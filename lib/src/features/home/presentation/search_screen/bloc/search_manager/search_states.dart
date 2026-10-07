import '../../../../../../core/index.dart';
import '../../../../data/model/search_model.dart';



class SearchStates extends Equatable {
  final SearchModel? data;
  final String errorMsg;
  final RequestState reqState;

  final SearchModel? friendsList;
  final String errorMsgFriends;
  final RequestState reqStateFriends;
  final TextEditingController searchController;
  final int currentIndex;
   String? selectedUserId;
  final bool isVIPRequestSuccess;

  // [Pagination] general search (users + rooms share one request/cursor).
  final ScrollController usersScrollCtrl;
  final ScrollController roomsScrollCtrl;
  final int searchCurrentPage;
  final int searchLastPage;
  final bool isPaginatingSearch;

  // [Pagination] friends search.
  final ScrollController friendsScrollCtrl;
  final int friendsCurrentPage;
  final int friendsLastPage;
  final bool isPaginatingFriends;

   SearchStates({
     this.currentIndex = 0,
    this.friendsList,
    this.data,
    this.selectedUserId,
    this.isVIPRequestSuccess = false,
    required this.searchController,
    ScrollController? usersScrollCtrl,
    ScrollController? roomsScrollCtrl,
    ScrollController? friendsScrollCtrl,
    this.searchCurrentPage = 1,
    this.searchLastPage = -1,
    this.isPaginatingSearch = false,
    this.friendsCurrentPage = 1,
    this.friendsLastPage = -1,
    this.isPaginatingFriends = false,
    this.errorMsg = '',
    this.errorMsgFriends = '',
    this.reqState = RequestState.idle,
    this.reqStateFriends = RequestState.idle,
  })  : usersScrollCtrl = usersScrollCtrl ?? ScrollController(),
        roomsScrollCtrl = roomsScrollCtrl ?? ScrollController(),
        friendsScrollCtrl = friendsScrollCtrl ?? ScrollController();

  SearchStates copyWith({
    int? currentIndex,
    SearchModel? data,
    String? searchController,
    String? selectedUserId,
    bool? isVIPRequestSuccess,
    String? errorMsg,
    RequestState? reqState,
    SearchModel? friendsList,
    String? errorMsgFriends,
    RequestState? reqStateFriends,
    ScrollController? usersScrollCtrl,
    ScrollController? roomsScrollCtrl,
    ScrollController? friendsScrollCtrl,
    int? searchCurrentPage,
    int? searchLastPage,
    bool? isPaginatingSearch,
    int? friendsCurrentPage,
    int? friendsLastPage,
    bool? isPaginatingFriends,
  }) {
    var searchStates = SearchStates(
      currentIndex: currentIndex ?? this.currentIndex,
      data: data ?? this.data,
      friendsList: friendsList ?? this.friendsList,
      errorMsgFriends: errorMsgFriends ?? this.errorMsgFriends,
      reqStateFriends: reqStateFriends ?? this.reqStateFriends,
      selectedUserId: selectedUserId ?? this.selectedUserId,
      isVIPRequestSuccess: isVIPRequestSuccess ?? this.isVIPRequestSuccess,
      searchController: this.searchController.copyWith(text: searchController),
      usersScrollCtrl: usersScrollCtrl ?? this.usersScrollCtrl,
      roomsScrollCtrl: roomsScrollCtrl ?? this.roomsScrollCtrl,
      friendsScrollCtrl: friendsScrollCtrl ?? this.friendsScrollCtrl,
      searchCurrentPage: searchCurrentPage ?? this.searchCurrentPage,
      searchLastPage: searchLastPage ?? this.searchLastPage,
      isPaginatingSearch: isPaginatingSearch ?? this.isPaginatingSearch,
      friendsCurrentPage: friendsCurrentPage ?? this.friendsCurrentPage,
      friendsLastPage: friendsLastPage ?? this.friendsLastPage,
      isPaginatingFriends: isPaginatingFriends ?? this.isPaginatingFriends,
      errorMsg: errorMsg ?? this.errorMsg,
      reqState: reqState ?? this.reqState,
    );
    return searchStates;
  }

  @override
  List<Object?> get props => [
    data,
    errorMsg,
    reqState,
    searchController,
    reqStateFriends,
    friendsList,
    errorMsgFriends,
    currentIndex,
    searchCurrentPage,
    searchLastPage,
    isPaginatingSearch,
    friendsCurrentPage,
    friendsLastPage,
    isPaginatingFriends,
  ];
}