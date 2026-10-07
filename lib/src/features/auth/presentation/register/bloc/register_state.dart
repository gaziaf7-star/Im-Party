part of 'register_bloc.dart';

const _undefined = Object();

class RegisterState extends Equatable {
  final GlobalKey<FormState> formKey;
  final PhoneController phoneController;
  final bool validatePhoneNumber;
  final TextEditingController phoneNumber, passwordController;
  final bool isPassword;
  final bool isConfirmPassword;
  final IconData suffixIcon;
  final IconData confirmSuffixIcon;
  final bool isChecked;
  final RequestState reqState;
  final String message;
  final Country? selectedCountry;
  final String selectedCountryName;
  final String selectedCountryCode;
  final bool? isFormValid;

  const RegisterState({
    required this.formKey,
    required this.phoneController,
    this.validatePhoneNumber = false,
    this.isChecked = false,
    required this.phoneNumber,
    required this.passwordController,
    this.isPassword = true,
    this.suffixIcon = CupertinoIcons.eye,
    this.isConfirmPassword = true,
    this.confirmSuffixIcon = CupertinoIcons.eye,
    this.reqState = RequestState.idle,
    this.message = '',
    this.selectedCountry,
    this.selectedCountryName = '',
    this.selectedCountryCode = '',
    this.isFormValid = false,
  });

  RegisterState copyWith({
    PhoneController? phoneController,
    bool? validatePhoneNumber,
    String? phoneNumber,
    String? password,
    bool? isPassword,
    IconData? suffixIcon,
    IconData? confirmSuffixIcon,
    bool? isChecked,
    RequestState? reqState,
    String? message,
    Object? selectedCountry = _undefined,
    String? selectedCountryName,
    String? selectedCountryCode,
    bool? isFormValid,
  }) {
    if (password != null) {
      passwordController.text = password;
    }

    return RegisterState(
      formKey: formKey,
      phoneController: phoneController ?? this.phoneController,
      validatePhoneNumber: validatePhoneNumber ?? this.validatePhoneNumber,
      phoneNumber: this.phoneNumber.copyWith(text: phoneNumber),
      passwordController: passwordController,
      isPassword: isPassword ?? this.isPassword,
      suffixIcon: suffixIcon ?? this.suffixIcon,
      confirmSuffixIcon: confirmSuffixIcon ?? this.confirmSuffixIcon,
      isChecked: isChecked ?? this.isChecked,
      reqState: reqState ?? this.reqState,
      message: message ?? this.message,
      selectedCountry: selectedCountry == _undefined
          ? this.selectedCountry
          : selectedCountry as Country?,
      selectedCountryName: selectedCountryName ?? this.selectedCountryName,
      selectedCountryCode: selectedCountryCode ?? this.selectedCountryCode,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }

  @override
  List<Object?> get props => [
        formKey,
        phoneController,
        validatePhoneNumber,
        phoneNumber,
        isPassword,
        isConfirmPassword,
        suffixIcon,
        confirmSuffixIcon,
        isChecked,
        reqState,
        message,
        selectedCountry,
        selectedCountryName,
        selectedCountryCode,
        isFormValid,
      ];
}
