import 'package:general/src/core/index.dart';
import 'package:general/src/features/reels/domain/base_repo/reels_base_repo.dart';

class UpdateReelDescriptionUseCase extends UseCaseWithParams<BaseResponse<String>, ReelParam> {
  final ReelsBaseRepo baseRepositoryReels;

  UpdateReelDescriptionUseCase({required this.baseRepositoryReels});

  @override
  ResultFuture<BaseResponse<String>> call(ReelParam params) async {
    return await baseRepositoryReels.updateReelDescription(params);
  }
}
