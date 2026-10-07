part of 'recover_password_bloc.dart';

const _undefined = Object();

// RP ---> recover password
// CP ---> create password
class RecoverPasswordState extends Equatable {
  final GlobalKey<FormState> formKeyRP, formKeyCP;
  final RequestState reqStateRP, reqStateCP;
  final PhoneController phoneController;
  final bool validatePhoneNumber;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmPasswordCtrl;
  final TextEditingController phoneControllerNew;
  final bool isPassword;
  final bool? isFormValid;
  final bool isConfirmPassword;
  final bool isPhoneEmpty;
  final IconData suffixIcon;
  final IconData confirmSuffixIcon;
  final String message;
  final bool showErrorReasons;
  final Country? selectedCountry;

  const RecoverPasswordState({
    required this.formKeyRP,
    required this.formKeyCP,
    this.reqStateRP = RequestState.idle,
    this.reqStateCP = RequestState.idle,
    required this.phoneController,
    this.validatePhoneNumber = false,
    required this.passwordCtrl,
    required this.confirmPasswordCtrl,
    required this.phoneControllerNew,
    this.isPassword = true,
    this.isConfirmPassword = true,
    this.isPhoneEmpty = false,
    this.suffixIcon = CupertinoIcons.eye,
    this.confirmSuffixIcon = CupertinoIcons.eye,
    this.message = '',
    this.showErrorReasons = false,
    this.isFormValid = false,
    this.selectedCountry,
  });

  RecoverPasswordState copyWith({
    RequestState? reqStateRP,
    RequestState? reqStateCP,
    PhoneController? phoneController,
    bool? validatePhoneNumber,
    String? passwordCtrl,
    String? confirmPasswordCtrl,
    bool? isPassword,
    bool? isPhoneEmpty,
    bool? isFormValid,
    bool? isConfirmPassword,
    IconData? suffixIcon,
    IconData? confirmSuffixIcon,
    String? message,
    Object? selectedCountry = _undefined,
    bool? showErrorReasons,
    String? phoneText,
  }) {
    if (phoneText != null) {
      phoneControllerNew.text = phoneText;
    }
    return RecoverPasswordState(
      formKeyRP: formKeyRP,
      formKeyCP: formKeyCP,
      reqStateRP: reqStateRP ?? this.reqStateRP,
      reqStateCP: reqStateCP ?? this.reqStateCP,
      phoneController: phoneController ?? this.phoneController,
      validatePhoneNumber: validatePhoneNumber ?? this.validatePhoneNumber,
      passwordCtrl: this.passwordCtrl.copyWith(text: passwordCtrl),
      confirmPasswordCtrl:
          this.confirmPasswordCtrl.copyWith(text: confirmPasswordCtrl),
      phoneControllerNew: phoneControllerNew,
      isPassword: isPassword ?? this.isPassword,
      isPhoneEmpty: isPhoneEmpty ?? this.isPhoneEmpty,
      isFormValid: isFormValid ?? this.isFormValid,
      isConfirmPassword: isConfirmPassword ?? this.isConfirmPassword,
      suffixIcon: suffixIcon ?? this.suffixIcon,
      confirmSuffixIcon: confirmSuffixIcon ?? this.confirmSuffixIcon,
      message: message ?? this.message,
      showErrorReasons: showErrorReasons ?? this.showErrorReasons,
      selectedCountry: selectedCountry == _undefined
          ? this.selectedCountry
          : selectedCountry as Country?,
    );
  }

  @override
  List<Object?> get props => [
        formKeyRP,
        formKeyCP,
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
        showErrorReasons,
        reqStateRP,
        confirmPasswordCtrl,
        selectedCountry,
        phoneControllerNew,
        isPhoneEmpty,
        isFormValid,
      ];
}
