part of 'family_request_bloc.dart';

class FamilyRequestState extends Equatable {
  final List<FamilyRequestEntity>? data;
  final String? errorMsg;
  final RequestState reqState;

  const FamilyRequestState({
    this.data ,
    this.errorMsg ,
    this.reqState = RequestState.loading,
  });

  FamilyRequestState copyWith({
    List<FamilyRequestEntity>? data,
    String? errorMsg,
    RequestState? reqState,
  }) {
    return FamilyRequestState(
      data: data ?? this.data,
      errorMsg: errorMsg ?? this.errorMsg,
      reqState: reqState ?? this.reqState,
    );
  }






  @override
  List<Object?> get props => [
    data,
    errorMsg,
    reqState,
  ];
}