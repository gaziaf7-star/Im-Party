import 'package:general/src/core/index.dart';
import 'package:general/src/features/reels/data/model/reel_model.dart';
import 'package:general/src/features/reels/domain/base_repo/reels_base_repo.dart';

class GetFollowingReelsUseCase extends UseCaseWithParams<BaseResponse<List<ReelsMainModel>>, String?> {
  final ReelsBaseRepo baseRepositoryReels;

  GetFollowingReelsUseCase({required this.baseRepositoryReels});

  @override
  ResultFuture<BaseResponse<List<ReelsMainModel>>> call(String? params) async {
    return await baseRepositoryReels.getFollowingReels(params);
  }
}
