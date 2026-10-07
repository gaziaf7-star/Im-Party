import 'package:general/src/features/vip/vip.dart';

import '../../data/models/vip_bag_item_model.dart';

class GetVipUserBagUc
    extends UseCaseWithoutParams<BaseResponse<List<VipBagItemModel>>> {
  final VipBaseRepository _vipBaseRepository;
  const GetVipUserBagUc({required VipBaseRepository vipBaseRepository})
      : _vipBaseRepository = vipBaseRepository;

  @override
  ResultFuture<BaseResponse<List<VipBagItemModel>>> call() async {
    final result = await _vipBaseRepository.getBoughtVip();
    return result;
  }
}
