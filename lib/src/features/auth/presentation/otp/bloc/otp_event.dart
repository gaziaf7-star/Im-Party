part of 'otp_bloc.dart';

sealed class OtpEvent extends Equatable {
  const OtpEvent();

  @override
  List<Object?> get props => [];
}

final class FetchCodeOTPEvent extends OtpEvent {
  final String codeOTP;
  const FetchCodeOTPEvent({required this.codeOTP});

  @override
  List<Object?> get props => [codeOTP];
}

final class VerifyCodeOTPEvent extends OtpEvent {
  final BuildContext context;
  final SendCodeParameter parameter;

  const VerifyCodeOTPEvent({
    required this.context,
    required this.parameter,
  });

  @override
  List<Object?> get props => [context, parameter];
}
