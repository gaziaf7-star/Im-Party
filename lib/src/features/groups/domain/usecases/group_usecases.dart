import 'package:general/src/core/index.dart';
import 'package:general/src/features/groups/domain/entities/group_entity.dart';
import 'package:general/src/features/groups/domain/entities/group_member_entity.dart';
import 'package:general/src/features/groups/domain/entities/group_params.dart';
import 'package:general/src/features/groups/domain/repository/groups_repository.dart';

class FetchGroupsUC extends UseCaseWithParams<BaseResponse<List<GroupEntity>>, int?> {
  final GroupsRepository _repo;
  const FetchGroupsUC(this._repo);

  @override
  ResultFuture<BaseResponse<List<GroupEntity>>> call(int? page) =>
      _repo.fetchGroups(page: page);
}

class FetchGroupDetailUC extends UseCaseWithParams<BaseResponse<GroupEntity>, int> {
  final GroupsRepository _repo;
  const FetchGroupDetailUC(this._repo);

  @override
  ResultFuture<BaseResponse<GroupEntity>> call(int groupId) =>
      _repo.fetchGroupDetail(groupId);
}

class CreateGroupUC
    extends UseCaseWithParams<BaseResponse<GroupEntity>, CreateGroupParams> {
  final GroupsRepository _repo;
  const CreateGroupUC(this._repo);

  @override
  ResultFuture<BaseResponse<GroupEntity>> call(CreateGroupParams params) =>
      _repo.createGroup(params);
}

class UpdateGroupUC
    extends UseCaseWithParams<BaseResponse<GroupEntity>, UpdateGroupParams> {
  final GroupsRepository _repo;
  const UpdateGroupUC(this._repo);

  @override
  ResultFuture<BaseResponse<GroupEntity>> call(UpdateGroupParams params) =>
      _repo.updateGroup(params);
}

class DeleteGroupUC extends UseCaseWithParams<BaseResponse<void>, int> {
  final GroupsRepository _repo;
  const DeleteGroupUC(this._repo);

  @override
  ResultFuture<BaseResponse<void>> call(int groupId) =>
      _repo.deleteGroup(groupId);
}

class FetchGroupMembersUC extends UseCaseWithParams<
    BaseResponse<List<GroupMemberEntity>>, GroupMembersParams> {
  final GroupsRepository _repo;
  const FetchGroupMembersUC(this._repo);

  @override
  ResultFuture<BaseResponse<List<GroupMemberEntity>>> call(
          GroupMembersParams params) =>
      _repo.fetchMembers(params);
}

class AddGroupMembersUC
    extends UseCaseWithParams<BaseResponse<void>, AddGroupMembersParams> {
  final GroupsRepository _repo;
  const AddGroupMembersUC(this._repo);

  @override
  ResultFuture<BaseResponse<void>> call(AddGroupMembersParams params) =>
      _repo.addMembers(params);
}

class KickGroupMemberUC
    extends UseCaseWithParams<BaseResponse<void>, GroupMemberActionParams> {
  final GroupsRepository _repo;
  const KickGroupMemberUC(this._repo);

  @override
  ResultFuture<BaseResponse<void>> call(GroupMemberActionParams params) =>
      _repo.kickMember(params);
}

class PromoteGroupMemberUC
    extends UseCaseWithParams<BaseResponse<void>, GroupMemberActionParams> {
  final GroupsRepository _repo;
  const PromoteGroupMemberUC(this._repo);

  @override
  ResultFuture<BaseResponse<void>> call(GroupMemberActionParams params) =>
      _repo.promoteMember(params);
}

class DemoteGroupMemberUC
    extends UseCaseWithParams<BaseResponse<void>, GroupMemberActionParams> {
  final GroupsRepository _repo;
  const DemoteGroupMemberUC(this._repo);

  @override
  ResultFuture<BaseResponse<void>> call(GroupMemberActionParams params) =>
      _repo.demoteMember(params);
}

class MuteGroupMemberUC
    extends UseCaseWithParams<BaseResponse<void>, MuteGroupMemberParams> {
  final GroupsRepository _repo;
  const MuteGroupMemberUC(this._repo);

  @override
  ResultFuture<BaseResponse<void>> call(MuteGroupMemberParams params) =>
      _repo.muteMember(params);
}

class TransferGroupOwnershipUC
    extends UseCaseWithParams<BaseResponse<void>, TransferOwnershipParams> {
  final GroupsRepository _repo;
  const TransferGroupOwnershipUC(this._repo);

  @override
  ResultFuture<BaseResponse<void>> call(TransferOwnershipParams params) =>
      _repo.transferOwnership(params);
}

class LeaveGroupUC extends UseCaseWithParams<BaseResponse<void>, int> {
  final GroupsRepository _repo;
  const LeaveGroupUC(this._repo);

  @override
  ResultFuture<BaseResponse<void>> call(int groupId) =>
      _repo.leaveGroup(groupId);
}

class JoinGroupUC
    extends UseCaseWithParams<BaseResponse<GroupEntity>, JoinGroupParams> {
  final GroupsRepository _repo;
  const JoinGroupUC(this._repo);

  @override
  ResultFuture<BaseResponse<GroupEntity>> call(JoinGroupParams params) =>
      _repo.joinGroup(params);
}
