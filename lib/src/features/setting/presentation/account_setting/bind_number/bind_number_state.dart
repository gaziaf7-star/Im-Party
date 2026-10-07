part of 'bind_number_bloc.dart';

const _undefined = Object();

class AccountState extends Equatable {
  final GlobalKey<FormState> formKey;
  final PhoneController phoneController;
  final TextEditingController passwordController;
  final bool validatePhoneNumber;
  final bool isPassword;
  final bool isChecked;
  final IconData suffixIcon;

  final RequestState changeNumberState;
  final RequestState changePasswordState;
  final RequestState bindNumberState;
  final RequestState googleAuthState; // Google Auth State

  final String? changeNumberError;
  final String? changePasswordError;
  final String? bindNumberError;
  final String? googleAuthError; // Google Auth Error

  final String? changeNumberSuccessMessage;
  final String? changePasswordSuccessMessage;
  final String? bindNumberSuccessMessage;
  final String? googleAuthSuccessMessage; // Google Auth Success Message

  final Country? selectedCountry;
  final TextEditingController phoneControllerNew;

  const AccountState({
    this.validatePhoneNumber = false,
    required this.passwordController,
    required this.formKey,
    required this.phoneController,
    this.isPassword = true,
    this.isChecked = false,
    this.suffixIcon = CupertinoIcons.eye,
    this.changeNumberState = RequestState.idle,
    this.changePasswordState = RequestState.idle,
    this.bindNumberState = RequestState.idle,
    this.googleAuthState = RequestState.idle, // Default to idle
    this.changeNumberError,
    this.changePasswordError,
    this.bindNumberError,
    this.googleAuthError, // Initialize Google error to null
    this.changeNumberSuccessMessage,
    this.changePasswordSuccessMessage,
    this.bindNumberSuccessMessage,
    this.googleAuthSuccessMessage, // Initialize Google success message to null
    this.selectedCountry,
    required this.phoneControllerNew,
  });

  // CopyWith method to update specific parts of the state
  AccountState copyWith({
    RequestState? changeNumberState,
    RequestState? changePasswordState,
    RequestState? bindNumberState,
    RequestState? googleAuthState, // Google auth state
    String? changeNumberError,
    String? changePasswordError,
    String? bindNumberError,
    String? googleAuthError, // Google auth error
    String? changeNumberSuccessMessage,
    String? changePasswordSuccessMessage,
    String? bindNumberSuccessMessage,
    String? googleAuthSuccessMessage, // Google auth success message
    PhoneController? phoneController,
    bool? validatePhoneNumber,
    String? passwordController,
    bool? isPassword,
    bool? isChecked,
    IconData? suffixIcon,
    Object? selectedCountry = _undefined,
    String? phoneText,
  }) {
    if (phoneText != null) {
      phoneControllerNew.text = phoneText;
    }
    return AccountState(
      changeNumberState: changeNumberState ?? this.changeNumberState,
      changePasswordState: changePasswordState ?? this.changePasswordState,
      bindNumberState: bindNumberState ?? this.bindNumberState,
      googleAuthState: googleAuthState ?? this.googleAuthState,
      // Update Google auth state
      changeNumberError: changeNumberError ?? this.changeNumberError,
      changePasswordError: changePasswordError ?? this.changePasswordError,
      bindNumberError: bindNumberError ?? this.bindNumberError,
      googleAuthError: googleAuthError ?? this.googleAuthError,
      // Update Google auth error
      changeNumberSuccessMessage:
          changeNumberSuccessMessage ?? this.changeNumberSuccessMessage,
      changePasswordSuccessMessage:
          changePasswordSuccessMessage ?? this.changePasswordSuccessMessage,
      bindNumberSuccessMessage:
          bindNumberSuccessMessage ?? this.bindNumberSuccessMessage,
      googleAuthSuccessMessage:
          googleAuthSuccessMessage ?? this.googleAuthSuccessMessage,
      // Update Google auth success message
      formKey: formKey,
      phoneController: phoneController ?? this.phoneController,
      validatePhoneNumber: validatePhoneNumber ?? this.validatePhoneNumber,
      passwordController:
          this.passwordController.copyWith(text: passwordController),
      isPassword: isPassword ?? this.isPassword,
      isChecked: isChecked ?? this.isChecked,
      suffixIcon: suffixIcon ?? this.suffixIcon,
      selectedCountry: selectedCountry == _undefined
          ? this.selectedCountry
          : selectedCountry as Country?,
      phoneControllerNew: phoneControllerNew,
    );
  }

  @override
  List<Object?> get props => [
        formKey,
        phoneController,
        passwordController,
        validatePhoneNumber,
        isPassword,
        isChecked,
        suffixIcon,
        changeNumberState,
        changePasswordState,
        bindNumberState,
        googleAuthState,
        changeNumberError,
        changePasswordError,
        bindNumberError,
        googleAuthError,
        changeNumberSuccessMessage,
        changePasswordSuccessMessage,
        bindNumberSuccessMessage,
        googleAuthSuccessMessage,
        selectedCountry,
        phoneControllerNew,
      ];
}
