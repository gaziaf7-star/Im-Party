part of 'search_user_agency_bloc.dart';

class SearchUserAgencyStates extends Equatable {
  final List<Agency>? agencies;
  final List<User>? users;
  final String usersErrorMsg;
  final RequestState usersRequestState;
  final String agenciesErrorMsg;
  final String? amount;
  final RequestState agenciesRequestState;
  final TextEditingController searchController;

  SearchUserAgencyParam? param;
  final bool isVIPRequestSuccess;

  SearchUserAgencyStates({
    // this.data,
    this.agencies,
    this.users,
    this.param,
    this.amount,
    this.isVIPRequestSuccess = false,
    required this.searchController,
    this.usersErrorMsg = '',
    this.usersRequestState = RequestState.empty,
    this.agenciesErrorMsg = '',
    this.agenciesRequestState = RequestState.empty,
  });

  SearchUserAgencyStates copyWith({
    // MainResponseModel? data,
    String? searchController,
    String? amount,
    SearchUserAgencyParam? param,
    bool? isVIPRequestSuccess,
    String? usersErrorMsg,
    RequestState? usersRequestState,
    String? agenciesErrorMsg,
    RequestState? agenciesRequestState,
    List<Agency>? agencies,
    List<User>? users,
  }) {
    var searchStates = SearchUserAgencyStates(
      // data: data ?? this.data,
      param: param ?? this.param,
      amount: amount ?? this.amount,
      isVIPRequestSuccess: isVIPRequestSuccess ?? this.isVIPRequestSuccess,
      searchController: this.searchController.copyWith(text: searchController),
      usersErrorMsg: usersErrorMsg ?? this.usersErrorMsg,
      usersRequestState: usersRequestState ?? this.usersRequestState,
      agenciesErrorMsg: agenciesErrorMsg ?? this.agenciesErrorMsg,
      agenciesRequestState: agenciesRequestState ?? this.agenciesRequestState,
      agencies: agencies ?? this.agencies,
      users: users ?? this.users,
    );
    return searchStates;
  }

  @override
  List<Object?> get props => [
        usersErrorMsg,
        usersRequestState,
        searchController,
        agencies,
        users,
    amount,
        agenciesErrorMsg,
        agenciesRequestState
      ];
}
