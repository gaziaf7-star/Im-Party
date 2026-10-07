import 'package:general/src/core/index.dart';
import 'package:general/src/features/reels/domain/base_repo/reels_base_repo.dart';

class MakeCommentsUseCase extends UseCaseWithParams<BaseResponse<String>, ReelParam> {
  final ReelsBaseRepo baseRepositoryReels;

  MakeCommentsUseCase({required this.baseRepositoryReels});

  @override
  ResultFuture<BaseResponse<String>> call(ReelParam params) async {
    return await baseRepositoryReels.makeComments(params);
  }
}
