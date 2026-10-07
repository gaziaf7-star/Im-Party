part of 'send_code_bloc.dart';

sealed class BaseSendCodeEvent extends Equatable {
  const BaseSendCodeEvent();

  @override
  List<Object?> get props => [];
}

final class SendCodeEvent extends BaseSendCodeEvent {
  final BuildContext context;
  final SendCodeParameter parameter;
  final bool isResend;

   const SendCodeEvent( {
    required this.context,
    required this.parameter,
    this.isResend = false,
  });

  @override
  List<Object?> get props => [context, parameter, isResend];
}
