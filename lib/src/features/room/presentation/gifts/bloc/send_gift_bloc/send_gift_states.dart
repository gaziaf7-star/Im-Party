part of 'send_gift_bloc.dart';

abstract class SendGiftStates extends Equatable {
  const SendGiftStates();
    @override
  List<Object?> get props => [];
}

class IntialSendGiftStates extends SendGiftStates {
  const IntialSendGiftStates();
  @override
  List<Object?> get props => [];
}

class LoadingSendGiftStates extends SendGiftStates {
  const LoadingSendGiftStates();
  
}

class SuccessSendGiftStates extends SendGiftStates {
  final String message;
  const SuccessSendGiftStates({required this.message});

  @override
  List<Object?> get props => [message];
}

class ErrorSendGiftStates extends SendGiftStates {
  final String error;
  const ErrorSendGiftStates({required this.error});

  @override
  List<Object?> get props => [error];
}
