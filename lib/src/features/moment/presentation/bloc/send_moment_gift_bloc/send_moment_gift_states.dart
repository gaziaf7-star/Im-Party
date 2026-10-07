part of 'send_moment_gift_bloc.dart';



abstract class SendMomentGiftStates extends Equatable {
  const SendMomentGiftStates();
    @override
  List<Object?> get props => [];
}

class IntialSendGiftMomentStates extends SendMomentGiftStates {
  const IntialSendGiftMomentStates();
  @override
  List<Object?> get props => [];
}

class LoadingSendGiftMomentStates extends SendMomentGiftStates {
  const LoadingSendGiftMomentStates();
  
}

class SuccessSendGiftMomentStates extends SendMomentGiftStates {
  final String message;
  const SuccessSendGiftMomentStates({required this.message});

  @override
  List<Object?> get props => [message];
}

class ErrorSendGiftMomentStates extends SendMomentGiftStates {
  final String error;
  const ErrorSendGiftMomentStates({required this.error});

  @override
  List<Object?> get props => [error];
}
