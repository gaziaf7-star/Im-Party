part of 'get_my_data_bloc.dart';

class FetchUserDataState extends Equatable {
  final MyDataEntity? userEntity;
  final RequestState reqState, reqStateUser;
  final String message;
  final UserEntity? otherUserEntity;
  final int? statusError;
  final bool showTitle;
  final int currentIndex;
  final int lengthIndicator;
  final List<UserEntity>? users;

  const FetchUserDataState({
    this.userEntity,
    this.message = '',
    this.reqState = RequestState.loading,
    this.reqStateUser = RequestState.loading,
    this.otherUserEntity,
    this.statusError,
    this.showTitle = false,
    this.currentIndex = 0,
    this.lengthIndicator = 0,
    this.users = const [],
  });

  FetchUserDataState copyWith({
    MyDataEntity? userEntity,
    RequestState? reqState,
    RequestState? reqStateUser,
    String? message,
    UserEntity? otherUserEntity,
    int? statusError,
    bool? showTitle,
    int? currentIndex,
    int? lengthIndicator,
    List<UserEntity>? users,
  }) {
    return FetchUserDataState(
      userEntity: userEntity ?? this.userEntity,
      reqState: reqState ?? this.reqState,
      reqStateUser: reqStateUser ?? this.reqStateUser,
      message: message ?? this.message,
      otherUserEntity: otherUserEntity ?? this.otherUserEntity,
      statusError: statusError ?? this.statusError,
      showTitle: showTitle ?? this.showTitle,
      currentIndex: currentIndex ?? this.currentIndex,
      lengthIndicator: lengthIndicator ?? this.lengthIndicator,
      users: users ?? this.users,
    );
  }

  @override
  List<Object?> get props => [
        userEntity,
        reqState,
        reqStateUser,
        otherUserEntity,
        message,
        statusError,
        showTitle,
        currentIndex,
        lengthIndicator,
        users,
      ];
}
