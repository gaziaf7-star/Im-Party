part of 'delete_message_bloc.dart';

class DeleteMessageState extends Equatable {
  final String message;
  final RequestState reqState;

  const DeleteMessageState({
    this.message = '',
    this.reqState = RequestState.idle,
  });

  DeleteMessageState copyWith({
    String? message,
    RequestState? reqState,
  }) {
    return DeleteMessageState(
      message: message ?? this.message,
      reqState: reqState ?? this.reqState,
    );
  }

  @override
  List<Object?> get props => [message, reqState];
}
