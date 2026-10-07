part of'take_action_bloc.dart';

abstract class BaseTakeActionEvent extends Equatable {
  const BaseTakeActionEvent();

  @override
  List<Object?> get props => const [];
}

class FamilyTakeActionEvent extends BaseTakeActionEvent {
  final String reqId;
  final String status;
  final String userId;
  final String familyId;
  const FamilyTakeActionEvent({
    required this.reqId,
    required this.status,
    required this.userId,
    required this.familyId,
  });

  @override
  List<Object?> get props => [reqId, status,userId,familyId];
}
