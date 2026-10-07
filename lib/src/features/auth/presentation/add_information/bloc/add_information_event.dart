part of 'add_information_bloc.dart';

sealed class BaseAddInformationEvent extends Equatable {
  final DateTime? dateTime;
  final String? gender;
  final File? image;
  final String? name;
  final String? emile;
  final ThirdPartyEntity? kThirdPartyEntity;

  const BaseAddInformationEvent({
    this.gender,
    this.dateTime,
    this.image,
    this.name,
    this.emile,
    this.kThirdPartyEntity,
  });

  @override
  List<Object?> get props => [gender, dateTime, image, name];
}

class ThirdPartyEvent extends BaseAddInformationEvent {
  const ThirdPartyEvent({super.kThirdPartyEntity});
}

final class SelectedGenderEvent extends BaseAddInformationEvent {
  const SelectedGenderEvent({required super.gender});
}

final class SelectedCountryInfoEvent extends BaseAddInformationEvent {
  final int countryId;
  final String countryName;

  const SelectedCountryInfoEvent({
    required this.countryId,
    required this.countryName,
  });
}

final class SelectedBirthdayEvent extends BaseAddInformationEvent {
  const SelectedBirthdayEvent({required super.dateTime});
}

final class PickImageEvent extends BaseAddInformationEvent {
  const PickImageEvent({required super.image});
}

final class AddInformationEvent extends BaseAddInformationEvent {
  final String uuid;
  final BuildContext context;
  final bool isNavLayout;
  final bool isUpdateOnlyUid;

  const AddInformationEvent({
    required this.context,
    this.uuid = '',
    this.isNavLayout = true,
    this.isUpdateOnlyUid = false,
  });

  @override
  List<Object?> get props => [context, uuid, isNavLayout , isUpdateOnlyUid];
}

final class UsernameEvent extends BaseAddInformationEvent {
  const UsernameEvent({required super.name});
}

final class UserImageEvent extends BaseAddInformationEvent {
  const UserImageEvent({required super.image});
}

final class EmileEvent extends BaseAddInformationEvent {
  const EmileEvent({required super.emile});
}
