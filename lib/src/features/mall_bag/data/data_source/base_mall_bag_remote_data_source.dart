
import 'package:general/src/core/index.dart';
import 'package:general/src/features/mall_bag/mall_bag.dart';

abstract class BaseMallMyBagRemoteDataSource {
  Future<BaseResponse<List<MyBagModel>>> fetchMyBag({required String type});

  Future<BaseResponse<int>> usedMyBagItem({required UseUnUseBagItemParam param});
  Future<BaseResponse<int>> unUsedBagItem({required UseUnUseBagItemParam param});
  Future<BaseResponse<String>> usedMyBagItemSpecialId({required UseUnUseBagItemParam param});
  Future<BaseResponse<List<MallModel>>> fetchMall({required int type});
  Future<BaseResponse<String>> buySpecialId({required int type});
  Future<BaseResponse<String>> buyItemFromMall({required String id});
  Future<BaseResponse<String>> sendItemFrommMall({required SendMallParam param}) ;
  Future<BaseResponse<String>> sendItemFromBag({required SendBagParam param}) ;

}

class MallMyBagRemoteDataSourceImp extends BaseMallMyBagRemoteDataSource {
  final DioFactory _dio;
  MallMyBagRemoteDataSourceImp(this._dio);

  @override
  Future<BaseResponse<List<MyBagModel>>> fetchMyBag({required type}) async {
    final response = await _dio.get(
      EndPoints.fetchMyBag(type),
      headers: {'tz': DateTime.now().timeZoneName},
    );
    return BaseResponse<List<MyBagModel>>.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => MyBagModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<List<MallModel>>> fetchMall({required type}) async {
    final response = await _dio.get(EndPoints.fetchMall(type));
    return BaseResponse<List<MallModel>>.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => MallModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<String>> buySpecialId({required int type}) async {
    final response = await _dio.post(
      EndPoints.buyMallSpecialID,
      queryParameters: {'special_id': type},
    );
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => response.data['message'],
    );
  }

  @override
  Future<BaseResponse<String>> buyItemFromMall({required id}) async {
    final response = await _dio.post(
      EndPoints.buyMall,
      queryParameters: {'ware_id': id},
    );
    return BaseResponse<String>.fromJson(response.data);
  }

  @override
  Future<BaseResponse<int>> usedMyBagItem({required UseUnUseBagItemParam param}) async {
    final response = await _dio.post(
      EndPoints.usedMyBagItem,
      queryParameters: {'item_id': param.itemId,'type':param.type},
    );
    return BaseResponse<int>.fromJson(response.data);
  }

  @override
  Future<BaseResponse<int>> unUsedBagItem({required UseUnUseBagItemParam param}) async {
    final response = await _dio.post(
      EndPoints.unUsedMyBagItem,
        queryParameters: {'item_id': param.itemId.toString(),'type':param.type}
    );
    return BaseResponse<int>.fromJson(response.data);
  }

  @override
  Future<BaseResponse<String>> usedMyBagItemSpecialId(
      {required UseUnUseBagItemParam param}) async {
    final response = await _dio.post(
      EndPoints.usedMyBagSpecialId,
      queryParameters: {'item_id': param.itemId,'used':param.isUsed!?1:0},
    );
    return BaseResponse<String>.fromJson(response.data);
  }

  @override
  Future<BaseResponse<String>> sendItemFrommMall({required SendMallParam param}) async{
    final response = await _dio.post(
        EndPoints.sendMall,
        data: {"to_id": param.userId, "ware_id": param.itemId},
        );
    return BaseResponse<String>.fromJson(response.data);

  }

  @override
  Future<BaseResponse<String>> sendItemFromBag({required SendBagParam param}) async {
    final response = await _dio.post(
      EndPoints.sendBagItem,
      data: {"touid": param.userId, "pack_id": param.itemId,"target_id":param.targetId},    );
    return BaseResponse<String>.fromJson(response.data);
  }
}
