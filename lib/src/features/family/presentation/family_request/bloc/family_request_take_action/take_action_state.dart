part of 'take_action_bloc.dart';

class TakeActionState extends Equatable {
  final String message;
  final RequestState reqState;
  final MemberFamilyEntity? userMember;

  const TakeActionState({
    this.message = '',
    this.userMember,
    this.reqState = RequestState.loading,
  });

  TakeActionState copyWith({
    String? message,
    RequestState? reqState,
    MemberFamilyEntity? userMember,
  }) {
    return TakeActionState(
      message: message ?? this.message,
      reqState: reqState ?? this.reqState,
      userMember: userMember ?? this.userMember,
    );
  }

  @override
  List<Object?> get props => [message, reqState, userMember];
}
