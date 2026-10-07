import 'package:general/src/features/vip/vip.dart';

import '../models/vip_bag_item_model.dart';

class VipRepositoryImp extends VipBaseRepository {
  final BaseVipRemotelyDataSource baseVipRemotelyDataSource;

  VipRepositoryImp({required this.baseVipRemotelyDataSource});

  @override
  ResultFuture<BaseResponse<List<VipCenterModel>>> getVipCenter() {
    return execute<BaseResponse<List<VipCenterModel>>>(
        () => baseVipRemotelyDataSource.getVipCenter());
  }

  @override
  ResultFuture<String> buyVip(BuyVipParameter buyVipParameter) {
    return execute<String>(
        () => baseVipRemotelyDataSource.buyVip(buyVipParameter));
  }

  @override
  ResultFuture<String> useVip(BuyVipParameter buyVipParameter) {
    return execute<String>(
        () => baseVipRemotelyDataSource.useVip(buyVipParameter));
  }

  @override
  ResultFuture<String> sendVip(BuyVipParameter buyVipParameter) {
    return execute<String>(
        () => baseVipRemotelyDataSource.sendVip(buyVipParameter));
  }

  @override
  ResultFuture<BaseResponse<List<VipBagItemModel>>> getBoughtVip() {
    return execute<BaseResponse<List<VipBagItemModel>>>(
        () => baseVipRemotelyDataSource.getBoughtVip());
  }

  @override
  ResultFuture<BaseResponse<List<VipThemeSetting>>> getVipThemeSettings() {
    return execute<BaseResponse<List<VipThemeSetting>>>(
        () => baseVipRemotelyDataSource.getVipThemeSettings());
  }
}
