import 'package:general/src/core/index.dart';
import 'package:general/src/features/reels/data/model/reel_model.dart';
import 'package:general/src/features/reels/domain/base_repo/reels_base_repo.dart';

class GetReelsUseCase
    extends UseCaseWithParams<BaseResponse<List<ReelsMainModel>>, ReelParam> {
  final ReelsBaseRepo baseRepositoryReels;

  GetReelsUseCase({required this.baseRepositoryReels});

  @override
  ResultFuture<BaseResponse<List<ReelsMainModel>>> call(ReelParam params) async {
    return await baseRepositoryReels.getReels(params);
  }

}

class GetOneReelsUseCase
    extends UseCaseWithParams<BaseResponse<ReelsMainModel>, ReelParam> {
  final ReelsBaseRepo baseRepositoryReels;

  GetOneReelsUseCase({required this.baseRepositoryReels});


  @override
  ResultFuture<BaseResponse<ReelsMainModel>> call(ReelParam params) async {
    return await baseRepositoryReels.getOneReel(params);
  }
}
