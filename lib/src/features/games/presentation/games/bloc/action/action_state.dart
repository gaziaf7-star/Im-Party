part of 'action_bloc.dart';

class ActionState extends Equatable {
  final String messageIgnore, messageLike;
  final RequestState reqStateIgnore, reqStateLike;

  const ActionState({
    this.messageIgnore = '',
    this.reqStateIgnore = RequestState.idle,
    this.messageLike = '',
    this.reqStateLike = RequestState.idle,
  });

  ActionState copyWith({
    String? messageIgnore,
    RequestState? reqStateIgnore,
    String? messageLike,
    RequestState? reqStateLike,
  }) {
    return ActionState(
      messageIgnore: messageIgnore ?? this.messageIgnore,
      reqStateIgnore: reqStateIgnore ?? this.reqStateIgnore,
      messageLike: messageLike ?? this.messageLike,
      reqStateLike: reqStateLike ?? this.reqStateLike,
    );
  }

  @override
  List<Object?> get props => [
        messageIgnore,
        reqStateIgnore,
        messageLike,
        reqStateLike,
      ];
}
