part of 'create_group_bloc.dart';

class CreateGroupState extends Equatable {
  final RequestState reqState;
  final GroupEntity? createdGroup;
  final String message;

  const CreateGroupState({
    this.reqState = RequestState.idle,
    this.createdGroup,
    this.message = '',
  });

  CreateGroupState copyWith({
    RequestState? reqState,
    GroupEntity? createdGroup,
    String? message,
  }) {
    return CreateGroupState(
      reqState: reqState ?? this.reqState,
      createdGroup: createdGroup ?? this.createdGroup,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [reqState, createdGroup, message];
}
