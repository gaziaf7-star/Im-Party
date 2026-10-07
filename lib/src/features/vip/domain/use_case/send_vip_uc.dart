import 'package:general/src/features/vip/vip.dart';

class SendVipUc extends UseCaseWithParams<String, BuyVipParameter> {
  final VipBaseRepository vipBaseRepository;
  SendVipUc({required this.vipBaseRepository});

  @override
  ResultFuture<String> call(BuyVipParameter params) async {
    final result = await vipBaseRepository.sendVip(params);
    return result;
  }
}
