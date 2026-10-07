part of 'family_member_bloc.dart';

abstract class FamilyMemberEvent extends Equatable {
  const FamilyMemberEvent();

  @override
  List<Object?> get props => const [];
}

class GetFamilyMemberEvent extends FamilyMemberEvent {
  final String familyId;
  const GetFamilyMemberEvent({required this.familyId});

  @override
  List<Object?> get props => [familyId];
}

class GetMoreFamilyMemberEvent extends FamilyMemberEvent {
  final String familyId;
  final String page;
  const GetMoreFamilyMemberEvent({
    required this.familyId,
    required this.page,
  });

  @override
  List<Object?> get props => [familyId, page];
}
class LocalRemoveFamilyUserEvent extends FamilyMemberEvent {
  final String userId;
  const LocalRemoveFamilyUserEvent({
    required this.userId,
  });

  @override
  List<Object?> get props => [userId, ];
}class LocalAddFamilyUserEvent extends FamilyMemberEvent {
  final MemberFamilyEntity user;
  const LocalAddFamilyUserEvent({
    required this.user,
  });

  @override
  List<Object?> get props => [user, ];
}
class LocalChangeUserTypeUserEvent extends FamilyMemberEvent {
  final String userId;
  final String type;
  const LocalChangeUserTypeUserEvent({
    required this.userId,
    required this.type,
  });

  @override
  List<Object?> get props => [userId,type ];
}
