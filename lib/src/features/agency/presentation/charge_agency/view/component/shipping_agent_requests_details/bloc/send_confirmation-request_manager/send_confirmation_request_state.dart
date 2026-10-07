part of 'send_confirmation_request_bloc.dart';
// Base state class that holds the current request state
class SendConfirmationRequestState extends Equatable {
  final RequestState requestState; // Current state of the request
  final String? message; // Success message on success
  final String? error; // Error message on failure

  const SendConfirmationRequestState({
    this.requestState = RequestState.idle, // Default state is initial
    this.message,
    this.error,
  });

  // CopyWith method to allow state updates
  SendConfirmationRequestState copyWith({
    RequestState? requestState,
    String? message,
    String? error,
  }) {
    return SendConfirmationRequestState(
      requestState: requestState ?? this.requestState,
      message: message ?? this.message,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [requestState, message, error];
}
