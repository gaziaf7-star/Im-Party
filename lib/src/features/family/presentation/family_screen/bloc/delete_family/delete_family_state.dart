part of 'delete_family_bloc.dart';

class DeleteFamilyState extends Equatable {
  final String? message ;
  final String? errorMsg;
  final RequestState reqState;

  const DeleteFamilyState({
    this.message ,
    this.errorMsg ,
    this.reqState = RequestState.idle,
  });

  DeleteFamilyState copyWith({
    String? message ,
    String? errorMsg,
    RequestState? reqState,
  }) {
    return DeleteFamilyState(
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