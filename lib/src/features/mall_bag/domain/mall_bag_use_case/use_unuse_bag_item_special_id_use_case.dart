import 'package:general/src/core/index.dart';
import 'package:general/src/features/mall_bag/mall_bag.dart';

class UseUnUseBagItemSpecialIdUC extends UseCaseWithParams<BaseResponse<String>,UseUnUseBagItemParam> {

  final BaseMallMyBagRepository mallBagBaseRepository;
  const UseUnUseBagItemSpecialIdUC({required this.mallBagBaseRepository});


  @override
  ResultFuture<BaseResponse<String>> call(UseUnUseBagItemParam params) {
return  mallBagBaseRepository.usedMyBagItemSpecialId(param: params);
  }
}


