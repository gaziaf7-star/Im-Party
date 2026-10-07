part of 'join_family_bloc.dart';

sealed class BaseJoinFamilyEvent extends Equatable {
  const BaseJoinFamilyEvent();
  @override
  List<Object?> get props => [];

}
class JoinFamilyEvent extends BaseJoinFamilyEvent{
 final String familyId;
  const JoinFamilyEvent({required this.familyId});
 @override
 List<Object?> get props => [familyId];
}

class ResetJoinFamilyEvent extends BaseJoinFamilyEvent{
  const ResetJoinFamilyEvent();
 @override
 List<Object?> get props => [];
}
