import 'package:general/src/core/index.dart';
import 'package:general/src/features/groups/data/models/group_member_model.dart';
import 'package:general/src/features/groups/data/models/group_model.dart';
import 'package:general/src/features/groups/domain/entities/group_params.dart';

abstract class GroupsRemoteDataSource {
  Future<BaseResponse<List<GroupModel>>> fetchGroups({int? page});

  /// Discover PUBLIC groups (chat rebuild §4 browse).
  Future<BaseResponse<List<GroupModel>>> fetchPublicGroups(
      {int? page, String? query});

  /// Join a public group by id (open join_policy).
  Future<BaseResponse<GroupModel>> joinPublicGroup(int groupId);

  Future<BaseResponse<GroupModel>> fetchGroupDetail(int groupId);

  Future<BaseResponse<GroupModel>> createGroup(CreateGroupParams params);

  Future<BaseResponse<GroupModel>> updateGroup(UpdateGroupParams params);

  Future<BaseResponse<void>> deleteGroup(int groupId);

  Future<BaseResponse<List<GroupMemberModel>>> fetchMembers(
      GroupMembersParams params);

  Future<BaseResponse<void>> addMembers(AddGroupMembersParams params);

  Future<BaseResponse<void>> kickMember(GroupMemberActionParams params);

  Future<BaseResponse<void>> promoteMember(GroupMemberActionParams params);

  Future<BaseResponse<void>> demoteMember(GroupMemberActionParams params);

  Future<BaseResponse<void>> muteMember(MuteGroupMemberParams params);

  Future<BaseResponse<void>> transferOwnership(TransferOwnershipParams params);

  Future<BaseResponse<void>> leaveGroup(int groupId);

  Future<BaseResponse<GroupModel>> joinGroup(JoinGroupParams params);
}

class GroupsRemoteDataSourceImp extends GroupsRemoteDataSource {
  final DioFactory _dio;

  GroupsRemoteDataSourceImp(this._dio);

  /// Reads a list out of [json] regardless of whether the API returned a bare
  /// list or wrapped it in a `{data: [...]}` / `{data: {data: [...]}}` envelope
  /// (Laravel resource collections sometimes double-wrap). Returns an empty list
  /// for any unexpected shape so the screen renders empty instead of throwing.
  static List<dynamic> _asList(dynamic json) {
    if (json is List) return json;
    if (json is Map<String, dynamic>) {
      final inner = json['data'];
      if (inner is List) return inner;
      if (inner is Map<String, dynamic> && inner['data'] is List) {
        return inner['data'] as List<dynamic>;
      }
    }
    return const [];
  }

  /// Reads a single object out of [json], unwrapping a `{data: {...}}` envelope
  /// when present so detail endpoints survive both shapes.
  static Map<String, dynamic> _asMap(dynamic json) {
    if (json is Map<String, dynamic>) {
      final inner = json['data'];
      if (inner is Map<String, dynamic>) return inner;
      return json;
    }
    return const {};
  }

  @override
  Future<BaseResponse<List<GroupModel>>> fetchGroups({int? page}) async {
    final response = await _dio.get(
      EndPoints.groups,
      queryParameters: {if (page != null) 'page': page},
    );
    return BaseResponse<List<GroupModel>>.fromJson(
      response.data,
      fromJsonT: (json) => _asList(json)
          .map((e) => GroupModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<List<GroupModel>>> fetchPublicGroups(
      {int? page, String? query}) async {
    final response = await _dio.get(
      EndPoints.publicGroups,
      queryParameters: {
        if (page != null) 'page': page,
        if (query != null && query.isNotEmpty) 'q': query,
      },
    );
    return BaseResponse<List<GroupModel>>.fromJson(
      response.data,
      fromJsonT: (json) => _asList(json)
          .map((e) => GroupModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<GroupModel>> joinPublicGroup(int groupId) async {
    final response = await _dio.post(EndPoints.groupJoin(groupId));
    return BaseResponse<GroupModel>.fromJson(
      response.data,
      fromJsonT: (json) => GroupModel.fromJson(_asMap(json)),
    );
  }

  @override
  Future<BaseResponse<GroupModel>> fetchGroupDetail(int groupId) async {
    final response = await _dio.get(EndPoints.group(groupId));
    return BaseResponse<GroupModel>.fromJson(
      response.data,
      fromJsonT: (json) => GroupModel.fromJson(_asMap(json)),
    );
  }

  @override
  Future<BaseResponse<GroupModel>> createGroup(CreateGroupParams params) async {
    final formData = FormData.fromMap({
      'name': params.name,
      'privacy': params.privacy.value,
      'join_policy': params.joinPolicy.value,
      'only_admins_post': params.onlyAdminsPost ? 1 : 0,
      if (params.memberIds.isNotEmpty)
        'members': params.memberIds.map((e) => e.toString()).toList(),
      if (params.avatar != null)
        'avatar': await MultipartFile.fromFile(params.avatar!.path),
    });
    final response = await _dio.post(EndPoints.groups, data: formData);
    return BaseResponse<GroupModel>.fromJson(
      response.data,
      fromJsonT: (json) => GroupModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<BaseResponse<GroupModel>> updateGroup(UpdateGroupParams params) async {
    // When an avatar file is attached the request must be multipart; Laravel
    // reads PUT-over-POST via the `_method` spoof. Without a file a plain PUT
    // with a JSON map is enough.
    final Map<String, dynamic> fields = {
      if (params.name != null) 'name': params.name,
      if (params.privacy != null) 'privacy': params.privacy!.value,
      if (params.joinPolicy != null) 'join_policy': params.joinPolicy!.value,
      if (params.onlyAdminsPost != null)
        'only_admins_post': params.onlyAdminsPost! ? 1 : 0,
    };

    final Response response;
    if (params.avatar != null) {
      final formData = FormData.fromMap({
        ...fields,
        '_method': 'PUT',
        'avatar': await MultipartFile.fromFile(params.avatar!.path),
      });
      response = await _dio.post(EndPoints.group(params.groupId), data: formData);
    } else {
      response = await _dio.put(EndPoints.group(params.groupId), data: fields);
    }

    return BaseResponse<GroupModel>.fromJson(
      response.data,
      fromJsonT: (json) => GroupModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<BaseResponse<void>> deleteGroup(int groupId) async {
    final response = await _dio.delete(EndPoints.group(groupId));
    return BaseResponse<void>.fromJson(response.data);
  }

  @override
  Future<BaseResponse<List<GroupMemberModel>>> fetchMembers(
      GroupMembersParams params) async {
    final response = await _dio.get(
      EndPoints.groupMembers(params.groupId),
      queryParameters: {if (params.page != null) 'page': params.page},
    );
    return BaseResponse<List<GroupMemberModel>>.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((e) => GroupMemberModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<void>> addMembers(AddGroupMembersParams params) async {
    final response = await _dio.post(
      EndPoints.groupMembers(params.groupId),
      data: {'user_ids': params.userIds},
    );
    return BaseResponse<void>.fromJson(response.data);
  }

  @override
  Future<BaseResponse<void>> kickMember(GroupMemberActionParams params) async {
    final response =
        await _dio.delete(EndPoints.groupMemberKick(params.groupId, params.userId));
    return BaseResponse<void>.fromJson(response.data);
  }

  @override
  Future<BaseResponse<void>> promoteMember(
      GroupMemberActionParams params) async {
    final response = await _dio
        .post(EndPoints.groupMemberPromote(params.groupId, params.userId));
    return BaseResponse<void>.fromJson(response.data);
  }

  @override
  Future<BaseResponse<void>> demoteMember(GroupMemberActionParams params) async {
    final response = await _dio
        .post(EndPoints.groupMemberDemote(params.groupId, params.userId));
    return BaseResponse<void>.fromJson(response.data);
  }

  @override
  Future<BaseResponse<void>> muteMember(MuteGroupMemberParams params) async {
    final response = await _dio.post(
      EndPoints.groupMemberMute(params.groupId, params.userId),
      data: {
        if (params.durationMinutes != null && params.durationMinutes! > 0)
          'duration_minutes': params.durationMinutes,
      },
    );
    return BaseResponse<void>.fromJson(response.data);
  }

  @override
  Future<BaseResponse<void>> transferOwnership(
      TransferOwnershipParams params) async {
    final response = await _dio.post(
      EndPoints.groupTransferOwnership(params.groupId),
      data: {'user_id': params.newOwnerId},
    );
    return BaseResponse<void>.fromJson(response.data);
  }

  @override
  Future<BaseResponse<void>> leaveGroup(int groupId) async {
    final response = await _dio.post(EndPoints.groupLeave(groupId));
    return BaseResponse<void>.fromJson(response.data);
  }

  @override
  Future<BaseResponse<GroupModel>> joinGroup(JoinGroupParams params) async {
    final response = await _dio.post(
      EndPoints.groupJoin(params.groupId ?? 0),
      data: {
        if (params.inviteToken != null) 'invite_token': params.inviteToken,
      },
    );
    return BaseResponse<GroupModel>.fromJson(
      response.data,
      fromJsonT: (json) => GroupModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
