import 'package:general/src/core/index.dart';
import 'package:general/src/features/mall_bag/mall_bag.dart';

class GetMallDataUseCase extends UseCaseWithParams <BaseResponse<List<MallModel>>,int>{
  final BaseMallMyBagRepository mallBagBaseRepository;
  const GetMallDataUseCase({required this.mallBagBaseRepository});

  @override
  ResultFuture<BaseResponse<List<MallModel>>> call(params) async{
 return await mallBagBaseRepository.fetchMall(type: params);
  }
}
