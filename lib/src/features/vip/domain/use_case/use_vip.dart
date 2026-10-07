import 'package:general/src/features/vip/vip.dart';

class UseVipUseCase extends UseCaseWithParams<String, BuyVipParameter> {
  final VipBaseRepository vipBaseRepository;
   UseVipUseCase({required this.vipBaseRepository});

  @override
  ResultFuture<String> call(BuyVipParameter params) async {
    final result = await vipBaseRepository.useVip(params);
    return result;
  }
}
