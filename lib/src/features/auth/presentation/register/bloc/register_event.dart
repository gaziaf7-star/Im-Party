part of 'register_bloc.dart';

sealed class BaseRegisterEvent extends Equatable {
  final PhoneNumber? phoneNumber;
  final bool validatePhoneNumber;

  const BaseRegisterEvent({this.phoneNumber, this.validatePhoneNumber = false});

  @override
  List<Object?> get props => [phoneNumber, validatePhoneNumber];
}

class PhoneNumberEvent extends BaseRegisterEvent {
  const PhoneNumberEvent({super.phoneNumber, super.validatePhoneNumber});
}

class TogglePasswordVisibilityEvent extends BaseRegisterEvent {
  final bool isFirst;

  const TogglePasswordVisibilityEvent({required this.isFirst});

  @override
  List<Object> get props => [isFirst];
}

class ToggleCheckBoxEvent extends BaseRegisterEvent {
  final bool isChecked;

  const ToggleCheckBoxEvent({required this.isChecked});

  @override
  List<Object> get props => [isChecked];
}

final class RegisterEvent extends BaseRegisterEvent {
  final BuildContext context;
  final SendCodeParameter parameter;

  const RegisterEvent({
    required this.context,
    required this.parameter,
  });

  @override
  List<Object?> get props => [context, parameter];
}

class CountrySelected extends BaseRegisterEvent {
  final String countryName;
  final String countryCode;

  const CountrySelected({required this.countryName, required this.countryCode});

  @override
  List<Object> get props => [countryName, countryCode];
}

class ValidEventRegister extends BaseRegisterEvent {

   const ValidEventRegister();
  @override
  List<Object?> get props => [];
}

class GetPhoneNumberEvent extends BaseRegisterEvent {
  final String phone;

   const GetPhoneNumberEvent({required this.phone});
  @override
  List<Object?> get props => [phone];
}


