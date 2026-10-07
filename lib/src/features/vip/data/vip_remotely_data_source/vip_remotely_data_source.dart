import 'package:general/src/features/vip/vip.dart';

import '../models/vip_bag_item_model.dart';

abstract class BaseVipRemotelyDataSource {
  Future<BaseResponse<List<VipCenterModel>>> getVipCenter();
  Future<BaseResponse<List<VipBagItemModel>>> getBoughtVip();
  Future<BaseResponse<List<VipThemeSetting>>> getVipThemeSettings();
  Future<String> sendVip(BuyVipParameter buyVipParameter);
  Future<String> buyVip(BuyVipParameter buyVipParameter);
  Future<String> useVip(BuyVipParameter buyVipParameter);
}

class VipRemotelyDataSource extends BaseVipRemotelyDataSource {
  final DioFactory? dioFactory;

  VipRemotelyDataSource({this.dioFactory});

  @override
  Future<BaseResponse<List<VipCenterModel>>> getVipCenter() async {
    final response = await dioFactory?.get(
      EndPoints.vipList,
    );
    return BaseResponse.fromJson(
      response?.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => VipCenterModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<String> buyVip(BuyVipParameter buyVipParameter) async {
    final body = {
      'type': '0',
      'vip_id': buyVipParameter.vipId,
    };
    final response = await dioFactory?.post(EndPoints.buyVip, data: body);
    return response?.data['message'];
  }

  @override
  Future<String> useVip(BuyVipParameter buyVipParameter) async {
    final body = {
      'type': buyVipParameter.type,
      'vip_id': buyVipParameter.vipId,
    };
    final response = await dioFactory?.post(EndPoints.vipUse, data: body);
    return response?.data['data'].toString()??'';
  }

@override
  Future<String> sendVip(BuyVipParameter buyVipParameter) async {
    final body = {
      'user_id': buyVipParameter.uuid,
      'vip_id': buyVipParameter.vipId,
    };
    final response = await dioFactory?.post(EndPoints.sendVip, data: body);
    return response?.data['message'].toString()??'';
  }

  @override
  Future<BaseResponse<List<VipBagItemModel>>> getBoughtVip() async {

    final response = await dioFactory?.get(EndPoints.getUserVip);
    return BaseResponse.fromJson(
      response?.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => VipBagItemModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<List<VipThemeSetting>>> getVipThemeSettings() async {
    final response = await dioFactory?.get(EndPoints.vipThemeSettings);
    return BaseResponse.fromJson(
      response?.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => VipThemeSetting.fromJson(element))
          .toList(),
    );
  }
}
