import 'package:general/src/features/vip/vip.dart';
import '../../data/models/vip_bag_item_model.dart';

abstract class VipBaseRepository {
  ResultFuture<BaseResponse<List<VipCenterModel>>> getVipCenter();
  ResultFuture<String> buyVip(BuyVipParameter buyVipParameter);
  ResultFuture<String> useVip(BuyVipParameter buyVipParameter);
  ResultFuture<BaseResponse<List<VipBagItemModel>>> getBoughtVip();
  ResultFuture<String> sendVip(BuyVipParameter buyVipParameter);
  ResultFuture<BaseResponse<List<VipThemeSetting>>> getVipThemeSettings();
}
