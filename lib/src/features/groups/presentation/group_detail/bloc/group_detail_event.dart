part of 'group_detail_bloc.dart';

abstract class GroupDetailEvent extends Equatable {
  const GroupDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadGroupDetailEvent extends GroupDetailEvent {
  final int groupId;
  const LoadGroupDetailEvent(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class UpdateGroupEvent extends GroupDetailEvent {
  final UpdateGroupParams params;
  const UpdateGroupEvent(this.params);

  @override
  List<Object?> get props => [params];
}

class DeleteGroupEvent extends GroupDetailEvent {
  final int groupId;
  const DeleteGroupEvent(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class LeaveGroupEvent extends GroupDetailEvent {
  final int groupId;
  const LeaveGroupEvent(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class TransferOwnershipEvent extends GroupDetailEvent {
  final TransferOwnershipParams params;
  const TransferOwnershipEvent(this.params);

  @override
  List<Object?> get props => [params];
}
