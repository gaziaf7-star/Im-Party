import 'package:general/src/core/index.dart';
import 'package:general/src/features/moment/data/models/moment_gift_model.dart';
import 'package:general/src/features/moment/moment.dart';

import '../models/moment_like_model.dart';

class MomentRepositoryImp extends BaseMomentRepository {
  final BaseMomentRemoteDataSource _repo;

  MomentRepositoryImp(this._repo);

  @override
  ResultFuture<BaseResponse<List<MomentModel>>> fetchMoments(
      {required MomentsParam param}) {
    return execute<BaseResponse<List<MomentModel>>>(
        () => _repo.fetchMoments(param: param));
  }

  @override
  ResultFuture<BaseResponse<String>> addMomnet({required AddMomentParametersUC param}) {
    return execute<BaseResponse<String>>(() => _repo.addMomnet(param: param));
  }

  @override
  ResultFuture<BaseResponse<int>> deleteMoment({required String momentId}) {
    return execute<BaseResponse<int>>(
        () => _repo.deleteMoment(momentId: momentId));
  }

  @override
  ResultFuture<BaseResponse<String>> likeMoment({required String momentId}) {
    return execute<BaseResponse<String>>(
        () => _repo.likeMoment(momentId: momentId));
  }

  @override
  ResultFuture<BaseResponse<List<MomentCommentsModel>>> fetchMomentComment(
      {required GetMomentCommentPrameter param}) {
    return execute<BaseResponse<List<MomentCommentsModel>>>(
        () => _repo.fetchMomentComment(param: param));
  }

  @override
  ResultFuture<BaseResponse<String>> addMomentComment(
      {required AddMomentCommentPrameter data}) {
    return execute<BaseResponse<String>>(
        () => _repo.addMomentComment(data: data));
  }

@override
  ResultFuture<BaseResponse<String>> reportMoment(ReportMomentParam reportMomentParam) {
    return execute<BaseResponse<String>>(
        () => _repo.reportMoment(reportMomentParam));
  }

  @override
  ResultFuture<BaseResponse<String>> deleteMomentComment(
      {required DeleteMomentCommentPrameter data}) {
    return execute<BaseResponse<String>>(
        () => _repo.deleteMomentComment(data: data));
  }

    @override
  ResultFuture<BaseResponse<List<MomentLikeModel>>> getMomentLike(
      {required GetMomentLikePrameter param}) {
    return execute<BaseResponse<List<MomentLikeModel>>>(
        () => _repo.getMomentLike(param: param));
  }

  @override
  ResultFuture<BaseResponse<List<MomentGiftModel>>> fetchGiftMoment({required int userId}) {
    return execute<BaseResponse<List<MomentGiftModel>>>(
            () => _repo.fetchGiftMoments(userID: userId));
  }

  @override
  ResultFuture<String> sendGiftsMoment(SendGiftMomentParameter giftParameter) {
    return execute<String>(() => _repo.sendGiftsMoment(giftParameter));
  }
}
