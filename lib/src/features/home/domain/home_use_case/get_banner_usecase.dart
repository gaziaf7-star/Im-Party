import '../../../../core/index.dart';
import '../../data/model/banner_model.dart';
import '../../home.dart';

class GetBannerUseCase extends UseCaseWithoutParams<BaseResponse<BannerModel>> {
  final BaseHomeRepository _repo;

  GetBannerUseCase(this._repo);
   
   @override
  ResultFuture<BaseResponse<BannerModel>> call() async{
    final result = await _repo.getBanner() ;
    return result ;
  }

}

