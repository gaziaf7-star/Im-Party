part of 'online_users_bloc.dart';

class OnlineUsersStates extends Equatable {
  final List<UsersOnlineEntity> users;
  final RequestState reqState;
  final String message;
  final ScrollController scrollController;
  final int currentPage, lastPage;

  const OnlineUsersStates({
    this.users = const [],
    this.reqState = RequestState.loading,
    this.message = '',
    required this.scrollController,
    this.currentPage = 1,
    this.lastPage = -1,
  });

  OnlineUsersStates copyWith({
    String? message,
    List<UsersOnlineEntity>? users,
    RequestState? reqState,
    ScrollController? scrollController,
    int? currentPage,
    int? lastPage,
  }) {
    return OnlineUsersStates(
      message: message ?? this.message,
      users: users ?? this.users,
      reqState: reqState ?? this.reqState,
      scrollController: scrollController ?? this.scrollController,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
    );
  }

  @override
  List<Object?> get props => [
        users,
        reqState,
        message,
        scrollController,
        currentPage,
        lastPage,
      ];
}
