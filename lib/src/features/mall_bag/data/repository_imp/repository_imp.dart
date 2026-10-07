import 'package:general/src/core/index.dart';
import 'package:general/src/features/mall_bag/mall_bag.dart';

class MallMyBagRepositoryImp extends BaseMallMyBagRepository {
  final BaseMallMyBagRemoteDataSource _remote;
  MallMyBagRepositoryImp(this._remote);

  @override
  ResultFuture<BaseResponse<String>> buyItemFromMall({required id}) {
    return execute<BaseResponse<String>>(() => _remote.buyItemFromMall(id: id));
  }

  @override
  ResultFuture<BaseResponse<List<MallModel>>> fetchMall({required type}) {
    return execute<BaseResponse<List<MallModel>>>(
        () => _remote.fetchMall(type: type));
  }

  @override
  ResultFuture<BaseResponse<String>> buySpecialId({required int type}) {
    return execute<BaseResponse<String>>(
        () => _remote.buySpecialId(type: type));
  }

  @override
  ResultFuture<BaseResponse<List<MyBagModel>>> fetchMyBag({required type}) {
    return execute<BaseResponse<List<MyBagModel>>>(
        () => _remote.fetchMyBag(type: type));
  }

  @override
  ResultFuture<BaseResponse<int>> unUsedBagItem({required UseUnUseBagItemParam param}) {
    return execute<BaseResponse<int>>(() => _remote.unUsedBagItem(param: param));
  }

  @override
  ResultFuture<BaseResponse<int>> usedMyBagItem({required UseUnUseBagItemParam param}) {
    return execute<BaseResponse<int>>(() => _remote.usedMyBagItem(param: param));
  }

  @override
  ResultFuture<BaseResponse<String>> usedMyBagItemSpecialId({required UseUnUseBagItemParam param}) {
    return execute<BaseResponse<String>>(() => _remote.usedMyBagItemSpecialId(param: param));
  }

  @override
  ResultFuture<BaseResponse<String>> sendItemFromMall({required SendMallParam param}) {
    return execute<BaseResponse<String>>(()=>_remote.sendItemFrommMall(param :param));
  }

  @override
  ResultFuture<BaseResponse<String>> sendItemFromBag({required SendBagParam param}) {
    return execute<BaseResponse<String>>(()=>_remote.sendItemFromBag(param :param));
  }




}
