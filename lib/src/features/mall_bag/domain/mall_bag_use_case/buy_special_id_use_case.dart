import 'package:general/src/core/index.dart';
import 'package:general/src/features/mall_bag/mall_bag.dart';



class BuyMallSpecialIdUC extends UseCaseWithParams <BaseResponse<String>,int>{
  final BaseMallMyBagRepository mallBagBaseRepository;
  const BuyMallSpecialIdUC({required this.mallBagBaseRepository});

  @override
  ResultFuture<BaseResponse<String>> call(int params) async{
 return await mallBagBaseRepository.buySpecialId(type: params);
  }
}
