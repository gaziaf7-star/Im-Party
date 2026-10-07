part of 'group_detail_bloc.dart';

/// Discrete signal of which mutating action just completed, so a [BlocListener]
/// can react once (navigate back, sync the list) instead of inferring from
/// loosely-typed flags.
enum GroupAction {
  none,
  updated,
  deleted,
  left,
  ownershipTransferred,
}

class GroupDetailState extends Equatable {
  final GroupEntity? group;
  final RequestState reqState;
  final RequestState actionState;
  final GroupAction lastAction;
  final String message;

  const GroupDetailState({
    this.group,
    this.reqState = RequestState.idle,
    this.actionState = RequestState.idle,
    this.lastAction = GroupAction.none,
    this.message = '',
  });

  GroupDetailState copyWith({
    GroupEntity? group,
    RequestState? reqState,
    RequestState? actionState,
    GroupAction? lastAction,
    String? message,
  }) {
    return GroupDetailState(
      group: group ?? this.group,
      reqState: reqState ?? this.reqState,
      actionState: actionState ?? this.actionState,
      lastAction: lastAction ?? this.lastAction,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props =>
      [group, reqState, actionState, lastAction, message];
}
