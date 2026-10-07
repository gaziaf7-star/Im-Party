import 'package:general/src/core/index.dart';
import 'package:general/src/features/groups/data/data_source/groups_remote_data_source.dart';
import 'package:general/src/features/groups/data/models/group_model.dart';
import 'package:general/src/features/groups/domain/entities/group_entity.dart';
import 'package:general/src/features/groups/domain/entities/group_member_entity.dart';
import 'package:general/src/features/groups/domain/entities/group_params.dart';
import 'package:general/src/features/groups/domain/repository/groups_repository.dart';

class GroupsRepositoryImp extends GroupsRepository {
  final GroupsRemoteDataSource _remote;

  GroupsRepositoryImp(this._remote);

  @override
  ResultFuture<BaseResponse<List<GroupEntity>>> fetchGroups({int? page}) {
    return execute(() async {
      final res = await _remote.fetchGroups(page: page);
      return BaseResponse<List<GroupEntity>>(
        success: res.success,
        message: res.message,
        paginates: res.paginates,
        data: res.data,
      );
    });
  }

  @override
  ResultFuture<BaseResponse<List<GroupEntity>>> fetchPublicGroups(
      {int? page, String? query}) {
    return execute(() async {
      final res = await _remote.fetchPublicGroups(page: page, query: query);
      return BaseResponse<List<GroupEntity>>(
        success: res.success,
        message: res.message,
        paginates: res.paginates,
        data: res.data,
      );
    });
  }

  @override
  ResultFuture<BaseResponse<GroupEntity>> joinPublicGroup(int groupId) {
    return execute(() async {
      final res = await _remote.joinPublicGroup(groupId);
      return _toEntityResponse(res);
    });
  }

  @override
  ResultFuture<BaseResponse<GroupEntity>> fetchGroupDetail(int groupId) {
    return execute(() async {
      final res = await _remote.fetchGroupDetail(groupId);
      return _toEntityResponse(res);
    });
  }

  @override
  ResultFuture<BaseResponse<GroupEntity>> createGroup(CreateGroupParams params) {
    return execute(() async {
      final res = await _remote.createGroup(params);
      return _toEntityResponse(res);
    });
  }

  @override
  ResultFuture<BaseResponse<GroupEntity>> updateGroup(UpdateGroupParams params) {
    return execute(() async {
      final res = await _remote.updateGroup(params);
      return _toEntityResponse(res);
    });
  }

  @override
  ResultFuture<BaseResponse<void>> deleteGroup(int groupId) {
    return execute(() => _remote.deleteGroup(groupId));
  }

  @override
  ResultFuture<BaseResponse<List<GroupMemberEntity>>> fetchMembers(
      GroupMembersParams params) {
    return execute(() async {
      final res = await _remote.fetchMembers(params);
      return BaseResponse<List<GroupMemberEntity>>(
        success: res.success,
        message: res.message,
        paginates: res.paginates,
        data: res.data,
      );
    });
  }

  @override
  ResultFuture<BaseResponse<void>> addMembers(AddGroupMembersParams params) {
    return execute(() => _remote.addMembers(params));
  }

  @override
  ResultFuture<BaseResponse<void>> kickMember(GroupMemberActionParams params) {
    return execute(() => _remote.kickMember(params));
  }

  @override
  ResultFuture<BaseResponse<void>> promoteMember(
      GroupMemberActionParams params) {
    return execute(() => _remote.promoteMember(params));
  }

  @override
  ResultFuture<BaseResponse<void>> demoteMember(GroupMemberActionParams params) {
    return execute(() => _remote.demoteMember(params));
  }

  @override
  ResultFuture<BaseResponse<void>> muteMember(MuteGroupMemberParams params) {
    return execute(() => _remote.muteMember(params));
  }

  @override
  ResultFuture<BaseResponse<void>> transferOwnership(
      TransferOwnershipParams params) {
    return execute(() => _remote.transferOwnership(params));
  }

  @override
  ResultFuture<BaseResponse<void>> leaveGroup(int groupId) {
    return execute(() => _remote.leaveGroup(groupId));
  }

  @override
  ResultFuture<BaseResponse<GroupEntity>> joinGroup(JoinGroupParams params) {
    return execute(() async {
      final res = await _remote.joinGroup(params);
      return _toEntityResponse(res);
    });
  }

  BaseResponse<GroupEntity> _toEntityResponse(BaseResponse<GroupModel> res) {
    return BaseResponse<GroupEntity>(
      success: res.success,
      message: res.message,
      paginates: res.paginates,
      data: res.data,
    );
  }
}
