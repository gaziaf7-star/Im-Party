part of 'groups_list_bloc.dart';

class GroupsListState extends Equatable {
  final List<GroupEntity> groups;
  final RequestState reqState;
  final NetworkExceptions? error;
  final int currentPage;
  final int lastPage;
  final bool isLoadingMore;

  const GroupsListState({
    this.groups = const [],
    this.reqState = RequestState.idle,
    this.error,
    this.currentPage = 1,
    this.lastPage = 1,
    this.isLoadingMore = false,
  });

  GroupsListState copyWith({
    List<GroupEntity>? groups,
    RequestState? reqState,
    NetworkExceptions? error,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore,
  }) {
    return GroupsListState(
      groups: groups ?? this.groups,
      reqState: reqState ?? this.reqState,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props =>
      [groups, reqState, error, currentPage, lastPage, isLoadingMore];
}
