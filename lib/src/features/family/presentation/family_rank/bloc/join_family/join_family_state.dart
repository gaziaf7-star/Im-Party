part of 'join_family_bloc.dart';

class BaseJoinFamilyState extends Equatable {
  final String? message ;
  final String? errorMsg;
  final RequestState reqState;

  const BaseJoinFamilyState({
    this.message ,
    this.errorMsg ,
    this.reqState = RequestState.idle,
  });

  BaseJoinFamilyState copyWith({
    String? message ,
    String? errorMsg,
    RequestState? reqState,
  }) {
    return BaseJoinFamilyState(
      message: message ?? this.message,
      errorMsg: errorMsg ?? this.errorMsg,
      reqState: reqState ?? this.reqState,
    );
  }

  @override
  List<Object?> get props => [
    message,
    errorMsg,
    reqState,
  ];
}