part of 'change_user_type_bloc.dart';

abstract class BaseChangeUserTypeEvent extends Equatable {
  const BaseChangeUserTypeEvent({
    this.userId='',
    this.familyId='',
    this.type=''});
  final String userId;
  final String familyId;
  final String type;
  @override
  List<Object> get props => [userId, familyId, type];
}

class ChangeUserTypeEvent extends BaseChangeUserTypeEvent {

  const ChangeUserTypeEvent(
      {required super.userId,
        required super.familyId,
        required super.type,
      });
}
