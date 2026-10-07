part of'family_remove_user_bloc.dart';

abstract class BaseFamilyRemoveUserEvent extends Equatable {
  const BaseFamilyRemoveUserEvent();

  @override
  List<Object> get props => [];
}

class RemoverFamilyUser extends BaseFamilyRemoveUserEvent {
  final String uId;
  final String familyId;
  const RemoverFamilyUser({required this.uId, required this.familyId});
}
