import 'package:general/src/features/cp/cp.dart';
import 'package:general/src/features/cp/data/model/cp_model.dart';
import '../../../../core/index.dart';

abstract class BaseCpRemotelyDataSource {
  Future<BaseResponse<CpRelationsModel>> getCpRelations();
  Future<BaseResponse<List<CpRelationLevelsGiftsModel>>>
      getRelationsCpLevelsGifts();
  Future<BaseResponse<List<CpRelationLevelsGiftsModel>>>
      getRelationsCpSpecialFriendLevelsGifts();
  Future<String> cpRequest({required CpRequestParam param});
  Future<String> buyCpSeats({required String wareId});
  Future<BaseResponse<CpProfileModel>> getCpProfile({required String userId});
  Future<BaseResponse<String>> cpRequestRespond(CpRequestRespondParam param);
  Future<BaseResponse<CpModel>> fetchRankingCp({
    required TopParameter params,
  });

}

class CpRemotelyDataSource extends BaseCpRemotelyDataSource {
  final DioFactory dioFactory;

  CpRemotelyDataSource({required this.dioFactory});
  @override
  Future<BaseResponse<CpRelationsModel>> getCpRelations() async {
    final response = await dioFactory.get(
      EndPoints.getCpRelations,
    );

    return BaseResponse.fromJson(response.data,
        fromJsonT: (json) => CpRelationsModel.fromJson(response.data));
  }

  @override
  Future<String> cpRequest({required CpRequestParam param}) async {
    final body = {'user_id': param.userId, 'cp_relation_id': param.relationId};
    final response = await DioFactory().post(
      EndPoints.cpRequest,
      data: body,
    );

    return response.data['message'].toString();
  }

  @override
  Future<String> buyCpSeats({required String wareId}) async {
    final body = {
      'ware_id': wareId,
    };
    final response = await DioFactory().post(
      EndPoints.cpBySeats,
      data: body,
    );

    return response.data['message'].toString();
  }

  @override
  Future<BaseResponse<CpProfileModel>> getCpProfile(
      {required String userId}) async {
    final response = await dioFactory.get(
      EndPoints.cpProfile(userId),
    );

    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => CpProfileModel.fromJson(json),
    );
  }

  @override
  Future<BaseResponse<List<CpRelationLevelsGiftsModel>>>
      getRelationsCpLevelsGifts() async {
    final response = await dioFactory.get(
      EndPoints.cpRelationsLevelsGifts,
    );

    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => (json as List)
          .map((e) => CpRelationLevelsGiftsModel.fromJson(e))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<List<CpRelationLevelsGiftsModel>>>
      getRelationsCpSpecialFriendLevelsGifts() async {
    final response = await dioFactory.get(
      EndPoints.cpRelationsSpecialFriendLevelsGifts,
    );

    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => (json as List)
          .map((e) => CpRelationLevelsGiftsModel.fromJson(e))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<CpModel>> fetchRankingCp({
    required TopParameter params,
  }) async {
    final response = await dioFactory.get(EndPoints.cpRanking,queryParameters: {'type':params.date.toString(),'relationType':params.sendOrReceiver.toString()});
    return BaseResponse<CpModel>.fromJson(
      response.data,
      fromJsonT: (json) {
        return CpModel.fromJson(json);
      },
    );
  }


  @override
  Future<BaseResponse<String>> cpRequestRespond(CpRequestRespondParam param) async {
    final response = await dioFactory.post(EndPoints.cpRequestRespond,
        data: {"cp_id": param.cpId, "message_id": param.messageId, "status": param.status});
    //Map<String, dynamic> resultData = response.data;

    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => response.data['message'],
    );
  }
}
