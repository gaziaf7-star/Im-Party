import 'dart:io';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/groups/domain/entities/group_enums.dart';

class CreateGroupParams extends Equatable {
  final String name;
  final File? avatar;
  final GroupPrivacy privacy;
  final GroupJoinPolicy joinPolicy;
  final bool onlyAdminsPost;
  final List<int> memberIds;

  const CreateGroupParams({
    required this.name,
    this.avatar,
    this.privacy = GroupPrivacy.public,
    this.joinPolicy = GroupJoinPolicy.open,
    this.onlyAdminsPost = false,
    this.memberIds = const [],
  });

  @override
  List<Object?> get props =>
      [name, avatar, privacy, joinPolicy, onlyAdminsPost, memberIds];
}

class UpdateGroupParams extends Equatable {
  final int groupId;
  final String? name;
  final File? avatar;
  final GroupPrivacy? privacy;
  final GroupJoinPolicy? joinPolicy;
  final bool? onlyAdminsPost;

  const UpdateGroupParams({
    required this.groupId,
    this.name,
    this.avatar,
    this.privacy,
    this.joinPolicy,
    this.onlyAdminsPost,
  });

  @override
  List<Object?> get props =>
      [groupId, name, avatar, privacy, joinPolicy, onlyAdminsPost];
}

class GroupMembersParams extends Equatable {
  final int groupId;
  final int? page;

  const GroupMembersParams({required this.groupId, this.page});

  @override
  List<Object?> get props => [groupId, page];
}

class AddGroupMembersParams extends Equatable {
  final int groupId;
  final List<int> userIds;

  const AddGroupMembersParams({required this.groupId, required this.userIds});

  @override
  List<Object?> get props => [groupId, userIds];
}

class GroupMemberActionParams extends Equatable {
  final int groupId;
  final int userId;

  const GroupMemberActionParams({required this.groupId, required this.userId});

  @override
  List<Object?> get props => [groupId, userId];
}

class MuteGroupMemberParams extends Equatable {
  final int groupId;
  final int userId;

  /// Minutes to mute for; null/0 means mute until manually unmuted.
  final int? durationMinutes;

  const MuteGroupMemberParams({
    required this.groupId,
    required this.userId,
    this.durationMinutes,
  });

  @override
  List<Object?> get props => [groupId, userId, durationMinutes];
}

class TransferOwnershipParams extends Equatable {
  final int groupId;
  final int newOwnerId;

  const TransferOwnershipParams({
    required this.groupId,
    required this.newOwnerId,
  });

  @override
  List<Object?> get props => [groupId, newOwnerId];
}

class JoinGroupParams extends Equatable {
  final int? groupId;
  final String? inviteToken;

  const JoinGroupParams({this.groupId, this.inviteToken});

  @override
  List<Object?> get props => [groupId, inviteToken];
}
