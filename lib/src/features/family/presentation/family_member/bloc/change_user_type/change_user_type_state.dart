
part of 'change_user_type_bloc.dart';

class ChangeUserTypeState extends Equatable {
  final String message;
  final RequestState reqState;

  const ChangeUserTypeState({
    this.message='' ,
    this.reqState = RequestState.idle,
  });

  ChangeUserTypeState copyWith({
    String? message ,
    RequestState? reqState,
  }) {
    return ChangeUserTypeState(
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