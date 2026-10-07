part of 'group_members_bloc.dart';

abstract class GroupMembersEvent extends Equatable {
  const GroupMembersEvent();

  @override
  List<Object?> get props => [];
}

class FetchMembersEvent extends GroupMembersEvent {
  final int groupId;
  const FetchMembersEvent(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class LoadMoreMembersEvent extends GroupMembersEvent {
  final int groupId;
  const LoadMoreMembersEvent(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class PromoteMemberEvent extends GroupMembersEvent {
  final int groupId;
  final int userId;
  const PromoteMemberEvent({required this.groupId, required this.userId});

  @override
  List<Object?> get props => [groupId, userId];
}

class DemoteMemberEvent extends GroupMembersEvent {
  final int groupId;
  final int userId;
  const DemoteMemberEvent({required this.groupId, required this.userId});

  @override
  List<Object?> get props => [groupId, userId];
}

class KickMemberEvent extends GroupMembersEvent {
  final int groupId;
  final int userId;
  const KickMemberEvent({required this.groupId, required this.userId});

  @override
  List<Object?> get props => [groupId, userId];
}

class MuteMemberEvent extends GroupMembersEvent {
  final int groupId;
  final int userId;
  final int? durationMinutes;
  const MuteMemberEvent({
    required this.groupId,
    required this.userId,
    this.durationMinutes,
  });

  @override
  List<Object?> get props => [groupId, userId, durationMinutes];
}

class AddMembersEvent extends GroupMembersEvent {
  final int groupId;
  final List<int> userIds;
  const AddMembersEvent({required this.groupId, required this.userIds});

  @override
  List<Object?> get props => [groupId, userIds];
}
