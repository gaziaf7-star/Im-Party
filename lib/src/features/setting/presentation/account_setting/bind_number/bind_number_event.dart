part of 'bind_number_bloc.dart';


sealed class AccountEvent extends Equatable {
  final PhoneNumber? phone;
  final bool validatePhoneNumber;
  final bool isChecked;
final String? passWord;
  const AccountEvent({
    this.phone,
    this.passWord,
    this.validatePhoneNumber = false,
    this.isChecked = false,
  });

  @override
  List<Object?> get props => [];
}


class ChangePasswordEvent extends AccountEvent {
  final BindAccountParam bindAccountParam;

  const ChangePasswordEvent({required this.bindAccountParam});

}

class FetchPhoneEvent extends AccountEvent {
  const FetchPhoneEvent({super.phone, super.validatePhoneNumber});
}
class FetchPasswordEvent extends AccountEvent {
  const FetchPasswordEvent({ super.passWord});
}

class TogglePasswordBindEvent extends AccountEvent {
  const TogglePasswordBindEvent();
}

class BindNumberEvent extends AccountEvent {
  final SendCodeParameter bindAccountParam;
  final BuildContext buildContext;
  const BindNumberEvent({required this.bindAccountParam,required this.buildContext});

  @override
  List<Object?> get props => [bindAccountParam];
}
class BindGoogleEvent extends AccountEvent {

final BuildContext context;
  const BindGoogleEvent({required this.context});

  @override
  List<Object?> get props => [
    context,
  ];
}
class ChangeCountryBindPhone extends AccountEvent {
  final Country newCountry;
  const ChangeCountryBindPhone(this.newCountry);

  @override
  List<Object> get props => [newCountry];
}

