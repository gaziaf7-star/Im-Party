
part of 'package:general/src/features/auth/presentation/change_phone/bloc/change_number_bloc.dart';

abstract class ChangePhoneEvent extends Equatable {
  final PhoneNumber? phone;
  final bool validatePhoneNumber;

  const ChangePhoneEvent({this.phone, this.validatePhoneNumber = false});

  @override
  List<Object?> get props => [phone, validatePhoneNumber];
}

class ChangeNumberEvent extends ChangePhoneEvent {
  final SendCodeParameter bindAccountParam;
  final BuildContext context ;
  const ChangeNumberEvent({required this.bindAccountParam,required this.context});

  @override
  List<Object?> get props => [bindAccountParam];
}
class FetchPhoneEvent extends ChangePhoneEvent {
  const FetchPhoneEvent({super.phone, super.validatePhoneNumber});
}

class ChangeCountryChangePhone extends ChangePhoneEvent {
  final Country newCountry;
  const ChangeCountryChangePhone(this.newCountry);

  @override
  List<Object> get props => [newCountry];
}

