part of 'send_confirmation_request_bloc.dart';

abstract class BaseSendConfirmationRequestEvents extends Equatable {
  const BaseSendConfirmationRequestEvents();
}

class SendConfirmationRequestEvent extends BaseSendConfirmationRequestEvents {
  final SendConfirmationRequestParam param;
  final BuildContext context;
  final TabController controller;
  const SendConfirmationRequestEvent({
    required this.param,
    required this.context,
    required this.controller,
  });

  @override
  List<Object?> get props => [param,context,controller];
}
