part of 'reset_password_bloc.dart';

sealed class BaseResetPasswordEvent extends Equatable {
  final PhoneNumber? phone;
  final bool validatePhoneNumber;
  final String codeOTP,phoneNumber;

  const BaseResetPasswordEvent({
    this.phone,
    this.validatePhoneNumber = false,
    this.codeOTP = '',
    this.phoneNumber = '',
  });

  @override
  List<Object?> get props => [
        phone,
        validatePhoneNumber,
        codeOTP,
      ];
}

final class RecoverPasswordFetchPhoneEvent extends BaseResetPasswordEvent {
  const RecoverPasswordFetchPhoneEvent({
    super.phone,
    super.validatePhoneNumber,
  });
}

final class RecoverPasswordTogglePassword1Event
    extends BaseResetPasswordEvent {
  const RecoverPasswordTogglePassword1Event();
}

final class RecoverPasswordTogglePassword2Event
    extends BaseResetPasswordEvent {
  const RecoverPasswordTogglePassword2Event();
}

final class RecoverPasswordEvent extends BaseResetPasswordEvent {
  final String codeOtp;
  final String number;
  final String type;
  final BuildContext context;
   const RecoverPasswordEvent({ required this.context,required this.type,required this.number ,required this.codeOtp});
}

final class FetchCodeOTPRecoverPasswordEvent extends BaseResetPasswordEvent {
  const FetchCodeOTPRecoverPasswordEvent({required super.codeOTP});
}
final class ValidateCodeOTPRecoverPasswordEvent extends BaseResetPasswordEvent {
  const ValidateCodeOTPRecoverPasswordEvent({required super.phoneNumber,required super.codeOTP});
}
