part of 'reset_password_bloc.dart';

// RP ---> recover password
// CP ---> create password
class ResetPasswordState extends Equatable {
  final GlobalKey<FormState> formKeyRP, formKeyCP;
  final RequestState reqStateRP, reqStateCP;
  final PhoneController phoneController;
  final bool validatePhoneNumber;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmPasswordCtrl;
  final bool isPassword;
  final bool isConfirmPassword;
  final IconData suffixIcon;
  final IconData confirmSuffixIcon;
  final String? message;
  final String? codeOTP;

  const ResetPasswordState({
    required this.formKeyRP,
    required this.formKeyCP,
    this.reqStateRP = RequestState.idle,
    this.reqStateCP = RequestState.idle,
    required this.phoneController,
    this.validatePhoneNumber = false,
    required this.passwordCtrl,
    required this.confirmPasswordCtrl,
    this.isPassword = true,
    this.isConfirmPassword = true,
    this.suffixIcon =CupertinoIcons.eye,
    this.confirmSuffixIcon = CupertinoIcons.eye,
    this.message = '',
    this.codeOTP = '',
  });

  ResetPasswordState copyWith({
    RequestState? reqStateRP,
    RequestState? reqStateCP,
    PhoneController? phoneController,
    bool? validatePhoneNumber,
    String? passwordCtrl,
    String? confirmPasswordCtrl,
    bool? isPassword,
    bool? isConfirmPassword,
    IconData? suffixIcon,
    IconData? confirmSuffixIcon,
    String? message,
    String? codeOTP,
  }) =>
      ResetPasswordState(
        formKeyRP: formKeyRP,
        formKeyCP: formKeyCP,
        reqStateRP: reqStateRP ?? this.reqStateRP,
        reqStateCP: reqStateCP ?? this.reqStateCP,
        phoneController: phoneController ?? this.phoneController,
        validatePhoneNumber: validatePhoneNumber ?? this.validatePhoneNumber,
        passwordCtrl: this.passwordCtrl.copyWith(text: passwordCtrl),
        confirmPasswordCtrl:
            this.confirmPasswordCtrl.copyWith(text: confirmPasswordCtrl),
        isPassword: isPassword ?? this.isPassword,
        isConfirmPassword: isConfirmPassword ?? this.isConfirmPassword,
        suffixIcon: suffixIcon ?? this.suffixIcon,
        confirmSuffixIcon: confirmSuffixIcon ?? this.confirmSuffixIcon,
        codeOTP: codeOTP ?? this.codeOTP,
        message: message ?? this.message,
      );

  @override
  List<Object?> get props => [
        formKeyRP,
        reqStateCP,
        reqStateRP,
        phoneController,
        validatePhoneNumber,
        passwordCtrl,
        isPassword,
        isConfirmPassword,
        suffixIcon,
        confirmSuffixIcon,
        message,
        reqStateRP,
        codeOTP,
        confirmPasswordCtrl,
      ];
}
