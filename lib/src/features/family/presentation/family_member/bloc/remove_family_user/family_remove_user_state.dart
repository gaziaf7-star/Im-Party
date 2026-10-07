part of'family_remove_user_bloc.dart';


class RemoveUserStates extends Equatable {
  final String message ;
  final RequestState reqState;

  const RemoveUserStates({
    this.message='' ,
    this.reqState = RequestState.idle,
  });

  RemoveUserStates copyWith({
    String? message ,
    RequestState? reqState,
  }) {
    return RemoveUserStates(
      message: message ?? this.message,
      reqState: reqState ?? this.reqState,
    );
  }

  @override
  List<Object?> get props => [
    message,
    reqState,
  ];
}