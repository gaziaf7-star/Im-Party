part of 'login_bloc.dart';

sealed class LoginEvent extends Equatable {
  final PhoneNumber? phone;
  final bool validatePhoneNumber;
  final bool isChecked;

  const LoginEvent({
    this.phone,
    this.validatePhoneNumber = false,
    this.isChecked = false,
  });

  @override
  List<Object?> get props => [phone, validatePhoneNumber, isChecked];
}

class FetchPhoneEvent extends LoginEvent {
  const FetchPhoneEvent({super.phone, super.validatePhoneNumber});
}

class TogglePasswordEvent extends LoginEvent {
  const TogglePasswordEvent();
}

class LoginWithPhoneEvent extends LoginEvent {
  final BuildContext context;
  bool? isLogin ;
   LoginWithPhoneEvent({required this.context, this.isLogin});

  @override
  List<Object?> get props => [context];
}

class ToggleTheCheckBoxEvent extends LoginEvent {
  const ToggleTheCheckBoxEvent({required super.isChecked});
}
class ChangeCountryEvent extends LoginEvent {
  final Country newCountry;
  const ChangeCountryEvent(this.newCountry);

  @override
  List<Object> get props => [newCountry];
}
class UpdatePhoneEvent extends LoginEvent {
  final String phoneNumber;
  const UpdatePhoneEvent(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}

class UpdatePasswordEvent extends LoginEvent {
  final String password;
  const UpdatePasswordEvent(this.password);

  @override
  List<Object> get props => [password];
}

class UpdatePhoneEventDespos extends LoginEvent {
  final String phoneNumber;
  const UpdatePhoneEventDespos(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}

class UpdatePasswordEventDespos extends LoginEvent {
  final String password;
  const UpdatePasswordEventDespos(this.password);

  @override
  List<Object> get props => [password];
}

class UpdateFormValidationEvent extends LoginEvent {
  const UpdateFormValidationEvent();
}

class CheckPhoneEvent extends LoginEvent {
  const CheckPhoneEvent();
}
class UpdateFormValidationEventPhoneFound extends LoginEvent {
  const UpdateFormValidationEventPhoneFound();
}
class ResetLoginStateEvent extends LoginEvent {
  const ResetLoginStateEvent();
}
