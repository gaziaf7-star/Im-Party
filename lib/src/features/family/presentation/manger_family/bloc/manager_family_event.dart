part of 'manager_family_bloc.dart';

sealed class BaseManagerFamilyEvent extends Equatable {
  // final FamilyParameter? params;
  final String? familyId;
  // final FamilyParameter? editFamilyParam;
  const BaseManagerFamilyEvent({this.familyId});
  @override
  List<Object?> get props => [
        // params,
        familyId
      ];
}

class ManagerFamilyEvent extends BaseManagerFamilyEvent {
  final BuildContext context;
  const ManagerFamilyEvent({
    required super.familyId,
    required this.context,
  });
}

// pick image
class PickImageEvent extends BaseManagerFamilyEvent {
  const PickImageEvent();
}

class EditFamilyEvent extends BaseManagerFamilyEvent {
  const EditFamilyEvent();
}

class AssignValueToController extends BaseManagerFamilyEvent {
  const AssignValueToController();
}
