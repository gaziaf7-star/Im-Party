part of 'join_group_bloc.dart';

class JoinGroupState extends Equatable {
  final RequestState reqState;
  final GroupEntity? joinedGroup;
  final String message;

  const JoinGroupState({
    this.reqState = RequestState.idle,
    this.joinedGroup,
    this.message = '',
  });

  JoinGroupState copyWith({
    RequestState? reqState,
    GroupEntity? joinedGroup,
    String? message,
  }) {
    return JoinGroupState(
      reqState: reqState ?? this.reqState,
      joinedGroup: joinedGroup ?? this.joinedGroup,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [reqState, joinedGroup, message];
}
