import 'package:general/src/core/index.dart';
import 'package:general/src/features/reels/domain/base_repo/reels_base_repo.dart';

class MakeLikeUseCase extends UseCaseWithParams<BaseResponse<String>, String> {
  final ReelsBaseRepo baseRepositoryReels;

  MakeLikeUseCase({required this.baseRepositoryReels});

  @override
  ResultFuture<BaseResponse<String>> call(String params) async {
    return await baseRepositoryReels.makeLike(params);
  }
}
