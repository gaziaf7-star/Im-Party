import 'package:general/src/core/index.dart';
import 'package:general/src/features/mall_bag/mall_bag.dart';
class GetBackBagUseCase
    extends UseCaseWithParams<BaseResponse<List<MyBagModel>>, String> {
  final BaseMallMyBagRepository mallBagBaseRepository;
  const GetBackBagUseCase({required this.mallBagBaseRepository});
  @override
  ResultFuture<BaseResponse<List<MyBagModel>>> call(params) async {
    return await mallBagBaseRepository.fetchMyBag(type: params);
  }
}
