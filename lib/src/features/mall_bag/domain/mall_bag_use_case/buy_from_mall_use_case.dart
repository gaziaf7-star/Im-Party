import 'package:general/src/core/index.dart';
import 'package:general/src/features/mall_bag/mall_bag.dart';

class BuyFromMallUseCase extends UseCaseWithParams<BaseResponse<String>, String> {
  final BaseMallMyBagRepository mallBagBaseRepository;

  const BuyFromMallUseCase({required this.mallBagBaseRepository});

  @override
  ResultFuture<BaseResponse<String>> call(params) {
    return mallBagBaseRepository.buyItemFromMall(id: params);
  }
}
