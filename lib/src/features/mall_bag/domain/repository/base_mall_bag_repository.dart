import 'package:general/src/core/index.dart';
import 'package:general/src/features/mall_bag/mall_bag.dart';

abstract class BaseMallMyBagRepository {
  ResultFuture<BaseResponse<List<MyBagModel>>> fetchMyBag({
    required String type,
  });
  ResultFuture<BaseResponse<String>> buySpecialId({required int type});
  ResultFuture<BaseResponse<int>> usedMyBagItem({required UseUnUseBagItemParam param});
  ResultFuture<BaseResponse<int>> unUsedBagItem({required UseUnUseBagItemParam param});
  ResultFuture<BaseResponse<String>> usedMyBagItemSpecialId({required UseUnUseBagItemParam param});
  ResultFuture<BaseResponse<List<MallModel>>> fetchMall({required int type});
  ResultFuture<BaseResponse<String>> buyItemFromMall({required String id});
  ResultFuture<BaseResponse<String>> sendItemFromMall({required SendMallParam param});
  ResultFuture<BaseResponse<String>> sendItemFromBag({required SendBagParam param});

}
