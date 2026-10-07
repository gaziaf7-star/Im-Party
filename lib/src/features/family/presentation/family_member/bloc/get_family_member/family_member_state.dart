part of 'family_member_bloc.dart';


class FamilyMemberState extends Equatable {
  final AllFamilyMemberEntity? data;
  final String? errorMsg;
  final RequestState reqState;

  const FamilyMemberState({
    this.data ,
    this.errorMsg ,
    this.reqState = RequestState.idle,
  });

  FamilyMemberState copyWith({
    AllFamilyMemberEntity? data,
    String? errorMsg,
    RequestState? reqState,
  }) {
    return FamilyMemberState(
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