import 'package:general/src/core/index.dart';
import 'package:general/src/features/mall_bag/mall_bag.dart';

class UnUseBagItemUseCase extends UseCaseWithParams<BaseResponse<int>,UseUnUseBagItemParam> {

  final BaseMallMyBagRepository mallBagBaseRepository;
  const UnUseBagItemUseCase({required this.mallBagBaseRepository});


  @override
  ResultFuture<BaseResponse<int>> call(UseUnUseBagItemParam params) {
return  mallBagBaseRepository.unUsedBagItem(param: params);
  }
}

class UseBagItemUseCase extends UseCaseWithParams<BaseResponse<int>,UseUnUseBagItemParam> {

 final BaseMallMyBagRepository mallBagBaseRepository;

 const UseBagItemUseCase({required this.mallBagBaseRepository});


  @override
  ResultFuture<BaseResponse<int>> call(UseUnUseBagItemParam params) {
return  mallBagBaseRepository.usedMyBagItem(param: params);
  }
}
