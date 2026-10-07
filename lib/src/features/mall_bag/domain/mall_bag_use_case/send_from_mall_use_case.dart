import 'package:general/src/core/index.dart';
import 'package:general/src/features/mall_bag/mall_bag.dart';

class SendFromMallUseCase
    extends UseCaseWithParams<BaseResponse<String>, SendMallParam> {
  final BaseMallMyBagRepository mallBagBaseRepository;

  SendFromMallUseCase({required this.mallBagBaseRepository});

  @override
  ResultFuture<BaseResponse<String>> call(SendMallParam params) {
    return mallBagBaseRepository.sendItemFromMall(param: params);
  }
}
