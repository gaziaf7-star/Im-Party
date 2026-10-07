part of 'package:general/src/features/auth/presentation/change_phone/bloc/change_number_bloc.dart';

const _undefined = Object();

class ChangePhoneState extends Equatable {
  final RequestState changeNumberState;

  final PhoneController phoneController;
  final bool validatePhoneNumber;

  final String? changeNumberError;
  final String? changeNumberSuccessMessage;
  final GlobalKey<FormState> formKeyRP, formKeyCP;
  final Country? selectedCountry;
  final TextEditingController phoneControllerNew;

  const ChangePhoneState({
    this.changeNumberState = RequestState.idle,
    this.changeNumberError,
    this.changeNumberSuccessMessage,
    required this.phoneController,
    this.validatePhoneNumber = false,
    required this.formKeyRP,
    required this.formKeyCP,
    this.selectedCountry,
    required this.phoneControllerNew,
  });

  ChangePhoneState copyWith({
    RequestState? changeNumberState,
    String? changeNumberError,
    String? changeNumberSuccessMessage,
    PhoneController? phoneController,
    bool? validatePhoneNumber,
    Object? selectedCountry = _undefined,
    String? phoneText,
  }) {
    if (phoneText != null) {
      phoneControllerNew.text = phoneText;
    }

    return ChangePhoneState(
      formKeyRP: formKeyRP,
      formKeyCP: formKeyCP,
      changeNumberState: changeNumberState ?? this.changeNumberState,
      changeNumberError: changeNumberError ?? this.changeNumberError,
      changeNumberSuccessMessage:
          changeNumberSuccessMessage ?? this.changeNumberSuccessMessage,
      validatePhoneNumber: validatePhoneNumber ?? this.validatePhoneNumber,
      phoneController: phoneController ?? this.phoneController,
      selectedCountry: selectedCountry == _undefined
          ? this.selectedCountry
          : selectedCountry as Country?,
      phoneControllerNew: phoneControllerNew,
    );
  }

  @override
  List<Object?> get props => [
        changeNumberState,
        changeNumberError,
        changeNumberSuccessMessage,
        phoneController,
        validatePhoneNumber,
        formKeyCP,
        formKeyRP,
        selectedCountry,
        phoneControllerNew,
      ];
}
