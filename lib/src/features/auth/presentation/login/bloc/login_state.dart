part of 'login_bloc.dart';

const _undefined = Object();

class LoginState extends Equatable {
  final GlobalKey<FormState> formKey;
  final RequestState requestState;
  final PhoneController phoneController;
  final bool validatePhoneNumber;
  final TextEditingController passwordController;
  final TextEditingController phoneControllerNew;
  final bool isPassword;
  final bool isChecked;
  final IconData suffixIcon;
  final String message;
  final Country? selectedCountry;
  final bool? isFormValid;
  final bool? isFormValidPhoneFound;
  final RequestState requestStateCheckPhone;
  final bool? isFoundAccount;
  final bool showRegisterDialog;

  const LoginState({
    required this.formKey,
    this.requestState = RequestState.idle,
    this.requestStateCheckPhone = RequestState.idle,
    required this.phoneController,
    this.validatePhoneNumber = false,
    this.isFoundAccount = false,
    required this.passwordController,
    required this.phoneControllerNew,
    this.isPassword = true,
    this.isChecked = false,
    this.suffixIcon = CupertinoIcons.eye,
    this.message = '',
    this.selectedCountry,
    this.isFormValid,
    this.isFormValidPhoneFound,
    this.showRegisterDialog = false,
  });

  LoginState copyWith({
    RequestState? requestState,
    RequestState? requestStateCheckPhone,
    PhoneController? phoneController,
    bool? validatePhoneNumber,
    String? passwordText,
    String? phoneText,
    bool? isPassword,
    bool? isChecked,
    IconData? suffixIcon,
    String? message,
    Object? selectedCountry = _undefined,
    bool? isFormValid,
    bool? isFoundAccount,
    bool? isFormValidPhoneFound,
    bool? showRegisterDialog,
  }) {
    // Update the existing controllers' text if new text is provided
    if (passwordText != null) {
      passwordController.text = passwordText;
    }
    if (phoneText != null) {
      phoneControllerNew.text = phoneText;
    }
    return LoginState(
      formKey: formKey,
      requestState: requestState ?? this.requestState,
      phoneController: phoneController ?? this.phoneController,
      validatePhoneNumber: validatePhoneNumber ?? this.validatePhoneNumber,
      passwordController: passwordController,
      phoneControllerNew: phoneControllerNew,
      isPassword: isPassword ?? this.isPassword,
      isChecked: isChecked ?? this.isChecked,
      suffixIcon: suffixIcon ?? this.suffixIcon,
      message: message ?? this.message,
      selectedCountry: selectedCountry == _undefined
          ? this.selectedCountry
          : selectedCountry as Country?,
      isFormValid: isFormValid ?? this.isFormValid,
      isFoundAccount: isFoundAccount ?? this.isFoundAccount,
      isFormValidPhoneFound:
          isFormValidPhoneFound ?? this.isFormValidPhoneFound,
      requestStateCheckPhone:
          requestStateCheckPhone ?? this.requestStateCheckPhone,
      showRegisterDialog: showRegisterDialog ?? this.showRegisterDialog,
    );
  }

  @override
  List<Object?> get props => [
        requestState,
        phoneController,
        validatePhoneNumber,
        phoneControllerNew,
        passwordController,
        isPassword,
        suffixIcon,
        message,
        isChecked,
        selectedCountry,
        isFormValid,
        isFoundAccount,
        requestStateCheckPhone,
        isFormValidPhoneFound,
        showRegisterDialog,
      ];
}
