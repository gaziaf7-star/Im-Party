part of 'send_code_bloc.dart';

class SendCodeState extends Equatable {
  final RequestState requestState;
  final String message;
  final String verificationId;

  const SendCodeState({
    this.requestState = RequestState.idle,
    this.message = '',
    this.verificationId = '',
  });

  SendCodeState copyWith({
    RequestState? requestState,
    String? message,
    String? verificationId,
  }) {
    return SendCodeState(
      requestState: requestState ?? this.requestState,
      message: message ?? this.message,
      verificationId: verificationId ?? this.verificationId,
    );
  }

  @override
  List<Object> get props => [requestState, message, verificationId];
}
