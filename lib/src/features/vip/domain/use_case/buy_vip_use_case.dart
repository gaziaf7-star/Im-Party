import 'package:general/src/features/vip/vip.dart';

class BuyVipUseCase extends UseCaseWithParams<String, BuyVipParameter> {
  final VipBaseRepository _vipBaseRepository;
  const BuyVipUseCase({required VipBaseRepository vipBaseRepository})
      : _vipBaseRepository = vipBaseRepository;
      
  @override
  ResultFuture<String> call(BuyVipParameter params) async {
    final result = await _vipBaseRepository.buyVip(params);
    return result;
  }
}
