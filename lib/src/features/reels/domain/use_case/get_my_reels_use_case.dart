import 'package:general/src/core/index.dart';
import 'package:general/src/features/reels/data/model/reel_model.dart';
import 'package:general/src/features/reels/domain/base_repo/reels_base_repo.dart';

class GetMyReelsUseCase
    extends UseCaseWithParams<BaseResponse<List<ReelsMainModel>>, ReelParam> {
  final ReelsBaseRepo baseRepositoryReels;

  GetMyReelsUseCase({required this.baseRepositoryReels});

  @override
  ResultFuture<BaseResponse<List<ReelsMainModel>>> call(ReelParam params) async {
    return await baseRepositoryReels.getMyReels(params);
  }

}

