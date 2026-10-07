part of 'show_family_bloc.dart';


abstract class BaseShowFamilyEvent extends Equatable {
  const BaseShowFamilyEvent();

  @override
  List<Object?> get props => [];
}

class ShowFamilyEvent extends BaseShowFamilyEvent {
  final String familyId;

  const ShowFamilyEvent({required this.familyId});
}

class EditFamilyLocallyEvent extends BaseShowFamilyEvent {
  final ShowFamilyEntity familyParameter;

  const EditFamilyLocallyEvent({
    required this.familyParameter,
  });
}

class EditFamilyLocallyDeleteMemberCountLocallyEvent extends BaseShowFamilyEvent {
  final String userId;

  const EditFamilyLocallyDeleteMemberCountLocallyEvent({required this.userId});
}

class EditFamilyLocallyAcceptRequestLocallyEvent extends BaseShowFamilyEvent {
 final MemberFamilyEntity? userMember;

 const EditFamilyLocallyAcceptRequestLocallyEvent({

   this.userMember

 });
}

class EditFamilyLocallyChangeUserTypeLocallyEvent extends BaseShowFamilyEvent {
  final String? userId;
final String type;
  const EditFamilyLocallyChangeUserTypeLocallyEvent({

    required this.userId,
   required this.type

  });
}
