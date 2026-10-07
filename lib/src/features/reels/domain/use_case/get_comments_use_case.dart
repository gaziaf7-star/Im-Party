import 'package:general/src/core/index.dart';
import 'package:general/src/features/reels/data/model/reel_comment_model.dart';

import 'package:general/src/features/reels/domain/base_repo/reels_base_repo.dart';

class GetCommentsUseCase extends UseCaseWithParams<BaseResponse<List<ReelCommentModel>>, ReelParam> {
  final ReelsBaseRepo baseRepositoryReels;

  GetCommentsUseCase({required this.baseRepositoryReels});

  @override
  ResultFuture<BaseResponse<List<ReelCommentModel>>> call(ReelParam params) async {
    return await baseRepositoryReels.getComments(params);
  }
}
