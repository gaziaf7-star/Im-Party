import 'dart:io';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/family/family.dart';
import 'package:general/src/features/home/data/model/room_model.dart';

abstract class BaseFamilyRemoteDataSource {
  Future<BaseResponse<List<FamilyRankModel>>> fetchFamilyRanking(String time);
  Future<BaseResponse<List<FamilyRankModel>>> getAllFamily();

  Future<BaseResponse<int>> createFamily({required FamilyParameter params});

  Future<String> joinFamily(String familyId);

  Future<BaseResponse<ShowFamilyModel>> editFamily(
      {required FamilyParameter params});

  Future<BaseResponse<ShowFamilyModel>> showFamily(String id);

  Future<BaseResponse<List<RoomModel>>> fetchFamilyRoom(String familyId);

  Future<String> exitFamily();

  Future<BaseResponse<FamilyMemberModel>> fetchFamilyMember(
      {required FamilyParameter params});

  Future<String> changeUserType(
      {required ChangeFamilyUserTypeParameter params});

  Future<BaseResponse<MemberFamilyDataModel?>> familyTakeAction({required FamilyTakeActionReq params});

  Future<BaseResponse<List<FamilyRequestsModel>>> getFamilyRequest();

  Future<String> removeUserFromFamily(
      {required ChangeFamilyUserTypeParameter params});

  Future<String> deleteFamily(String id);
}

class FamilyDataSource extends BaseFamilyRemoteDataSource {
  final DioFactory? dioFactory;

  FamilyDataSource({this.dioFactory});

  @override
  Future<BaseResponse<List<FamilyRankModel>>> fetchFamilyRanking(
      String time) async {
    final response = await dioFactory
        ?.post(EndPoints.familyRank, queryParameters: {'time': time});
    return BaseResponse.fromJson(
      response?.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => FamilyRankModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<int>> createFamily(
      {required FamilyParameter params}) async {
    FormData formData;
    File file = params.image!;
    String fileName = file.path.split('/').last;

    formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(file.path, filename: fileName),
      'name': params.name,
      'introduce': params.bio,
    });

    final response = await dioFactory?.post(
      EndPoints.createFamily,
      data: formData,
    );

    return BaseResponse<int>.fromJson(
      response?.data,
      fromJsonT: (json) => json['id'] as int,
    );
  }

  @override
  Future<String> joinFamily(String familyId) async {
    final response = await dioFactory
        ?.post(EndPoints.joinFamily,
        queryParameters: {'family_id': familyId});
    return response?.data['message'];
  }

  @override
  Future<BaseResponse<ShowFamilyModel>> editFamily(
      {required FamilyParameter params}) async {
    FormData formData;
    if (params.image == null) {
      formData = FormData.fromMap({
        'name': params.name,
        'introduce': params.bio,
      });
    } else {
      File file = params.image!;
      String fileName = file.path.split('/').last;
      formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(file.path, filename: fileName),
        'name': params.name,
        'introduce': params.bio,
      });
    }

    final response = await dioFactory?.post(
      EndPoints.editFamily(params.id!),
      data: formData,
    );
    return BaseResponse.fromJson(response?.data,
        fromJsonT: (json) => ShowFamilyModel.fromJson(json));
  }

  @override
  Future<BaseResponse<ShowFamilyModel>> showFamily(String id) async {
    final response = await dioFactory?.get(
      EndPoints.showFamily(id),
    );
    return BaseResponse.fromJson(response?.data,
        fromJsonT: (json) => ShowFamilyModel.fromJson(json));
  }

  @override
  Future<BaseResponse<List<RoomModel>>> fetchFamilyRoom(String familyId) async {
    final response = await dioFactory?.post(
      EndPoints.getFamilyRoom,
      queryParameters: {
        'family_id': familyId,
      },
    );
    return BaseResponse.fromJson(
      response?.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => RoomModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<String> exitFamily() async {
    final response = await dioFactory?.post(
      EndPoints.exitFamily,
    );
    return response?.data['message'];
  }

  @override
  Future<BaseResponse<FamilyMemberModel>> fetchFamilyMember(
      {required FamilyParameter params}) async {
    final response = await dioFactory?.post(EndPoints.getMembersFamily,
        queryParameters: {'family_id': params.id, "page": params.page ?? 1});
    return BaseResponse.fromJson(
      response?.data,
      fromJsonT: (json) => FamilyMemberModel.fromJson(response!.data['data']),
    );
  }

  @override
  Future<String> changeUserType(
      {required ChangeFamilyUserTypeParameter params}) async {
    final response = await dioFactory?.post(EndPoints.changeusertype,
        queryParameters: {
          'family_id': params.familyId,
          'user_id': params.userId,
          'type': params.type
        });
    return response?.data['message'];
  }

  @override
  Future<BaseResponse<MemberFamilyDataModel?>> familyTakeAction({required FamilyTakeActionReq params}) async {
    final response = await dioFactory?.post(EndPoints.familyTakeAction,
        data: {
      'user_id': params.userId,
      'req_id': params.reqId,
          'status': params.status});
    return BaseResponse.fromJson(response?.data,

    fromJsonT: (json) => MemberFamilyDataModel.fromJson(json));
  }

  @override
  Future<BaseResponse<List<FamilyRequestsModel>>> getFamilyRequest() async {
    final response = await dioFactory?.post(
      EndPoints.familyRequest,
    );

    return BaseResponse.fromJson(
      response?.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => FamilyRequestsModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<String> removeUserFromFamily(
      {required ChangeFamilyUserTypeParameter params}) async {
    final response = await dioFactory?.post(
      EndPoints.familyRemoveUser(params.userId!, params.familyId!),
    );
    return response?.data['message'];
  }

  @override
  Future<String> deleteFamily(String id) async {
    final response = await dioFactory?.get(
      EndPoints.deleteFamily(id),
    );
    return response?.data['message'];
  }

  @override
  Future<BaseResponse<List<FamilyRankModel>>> getAllFamily() async{
    final response = await dioFactory
        ?.get(EndPoints.allFamily);
    return BaseResponse.fromJson(
      response?.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => FamilyRankModel.fromJson(element))
          .toList(),
    );
  }
}
