import 'package:general/src/core/index.dart';
import 'package:general/src/features/moment/data/models/moment_gift_model.dart';
import 'package:general/src/features/moment/moment.dart';

import '../../data/models/moment_like_model.dart';

abstract class BaseMomentRepository {
  ResultFuture<BaseResponse<List<MomentModel>>> fetchMoments(
      {required MomentsParam param});
  ResultFuture<BaseResponse<String>> addMomnet({required AddMomentParametersUC param});
  ResultFuture<BaseResponse<int>> deleteMoment({required String momentId});
  ResultFuture<BaseResponse<String>> likeMoment({required String momentId});
  ResultFuture<BaseResponse<List<MomentCommentsModel>>> fetchMomentComment(
      {required GetMomentCommentPrameter param});
   ResultFuture<BaseResponse<List<MomentLikeModel>>> getMomentLike(
      {required GetMomentLikePrameter param});
  ResultFuture<BaseResponse<String>> addMomentComment(
      {required AddMomentCommentPrameter data});
  ResultFuture<BaseResponse<String>> reportMoment(ReportMomentParam reportMomentParam);
  ResultFuture<BaseResponse<String>> deleteMomentComment(
      {required DeleteMomentCommentPrameter data});

  ResultFuture<BaseResponse<List<MomentGiftModel>>> fetchGiftMoment(
      {required int userId});

  ResultFuture<String> sendGiftsMoment(SendGiftMomentParameter giftParameter);

}
