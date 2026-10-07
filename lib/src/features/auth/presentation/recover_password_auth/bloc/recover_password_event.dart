part of 'recover_password_bloc.dart';

sealed class BaseRecoverPasswordEvent extends Equatable {
  final PhoneNumber? phoneNumber;
  final bool validatePhoneNumber;

  const BaseRecoverPasswordEvent({
    this.phoneNumber,
    this.validatePhoneNumber = false,
  });

  @override
  List<Object?> get props => [phoneNumber, validatePhoneNumber];
}

final class RecoverPasswordFetchPhoneEvent extends BaseRecoverPasswordEvent {
  const RecoverPasswordFetchPhoneEvent({
    super.phoneNumber,
    super.validatePhoneNumber,
  });
}

final class RecoverTogglePasswordEvent extends BaseRecoverPasswordEvent {
  const RecoverTogglePasswordEvent();
}

final class RecoverToggleConfirmPasswordEvent extends BaseRecoverPasswordEvent {
  const RecoverToggleConfirmPasswordEvent();
}

class ToggleErrorReasonsEvent extends BaseRecoverPasswordEvent {}

class ChangeCountryRecoverEvent extends BaseRecoverPasswordEvent {
  final Country newCountry;
  const ChangeCountryRecoverEvent(this.newCountry);

  @override
  List<Object> get props => [newCountry];
}
final class RecoverPasswordEvent extends BaseRecoverPasswordEvent {
  final BuildContext context;
  final String code , phone;
  const RecoverPasswordEvent({
    required this.context,
    required this.code,
    required this.phone,
  });

    @override
  List<Object?> get props => [context, code , phone];
}
class IsPhoneEmptyEvent extends BaseRecoverPasswordEvent {
  const IsPhoneEmptyEvent();
}
class ValidaEvent extends BaseRecoverPasswordEvent {
  const ValidaEvent();
}
