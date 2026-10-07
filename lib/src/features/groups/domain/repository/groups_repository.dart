import 'package:general/src/core/index.dart';
import 'package:general/src/features/groups/domain/entities/group_entity.dart';
import 'package:general/src/features/groups/domain/entities/group_member_entity.dart';
import 'package:general/src/features/groups/domain/entities/group_params.dart';

abstract class GroupsRepository {
  ResultFuture<BaseResponse<List<GroupEntity>>> fetchGroups({int? page});

  /// Browse public groups (chat rebuild §4).
  ResultFuture<BaseResponse<List<GroupEntity>>> fetchPublicGroups(
      {int? page, String? query});

  /// Join a public group by id (open join_policy).
  ResultFuture<BaseResponse<GroupEntity>> joinPublicGroup(int groupId);

  ResultFuture<BaseResponse<GroupEntity>> fetchGroupDetail(int groupId);

  ResultFuture<BaseResponse<GroupEntity>> createGroup(CreateGroupParams params);

  ResultFuture<BaseResponse<GroupEntity>> updateGroup(UpdateGroupParams params);

  ResultFuture<BaseResponse<void>> deleteGroup(int groupId);

  ResultFuture<BaseResponse<List<GroupMemberEntity>>> fetchMembers(
      GroupMembersParams params);

  ResultFuture<BaseResponse<void>> addMembers(AddGroupMembersParams params);

  ResultFuture<BaseResponse<void>> kickMember(GroupMemberActionParams params);

  ResultFuture<BaseResponse<void>> promoteMember(GroupMemberActionParams params);

  ResultFuture<BaseResponse<void>> demoteMember(GroupMemberActionParams params);

  ResultFuture<BaseResponse<void>> muteMember(MuteGroupMemberParams params);

  ResultFuture<BaseResponse<void>> transferOwnership(
      TransferOwnershipParams params);

  ResultFuture<BaseResponse<void>> leaveGroup(int groupId);

  ResultFuture<BaseResponse<GroupEntity>> joinGroup(JoinGroupParams params);
}
