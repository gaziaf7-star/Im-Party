import 'dart:io';

import 'package:general/src/features/reels/data/model/reel_comment_model.dart';
import 'package:general/src/features/reels/data/model/reel_model.dart';

import '../../../../core/index.dart';

abstract class ReelsBaseRepo {
  // ResultFuture<BaseResponse<String>> uploadReel(UploadReelParam param);

  ResultFuture<BaseResponse<List<ReelsMainModel>>> getReels(ReelParam param);
  ResultFuture<BaseResponse<ReelsMainModel>> getOneReel(ReelParam param);

  ResultFuture<BaseResponse<List<ReelCommentModel>>> getComments(
      ReelParam param);

  ResultFuture<BaseResponse<String>> makeComments(ReelParam param);

  ResultFuture<BaseResponse<String>> makeLike(
    String reelId,
  );
  ResultFuture<BaseResponse<String>> deleteReel(ReelParam param);
  ResultFuture<BaseResponse<String>> updateReelDescription(ReelParam param);
  ResultFuture<BaseResponse<List<ReelsMainModel>>> getMyReels(ReelParam param); 

  ResultFuture<BaseResponse<List<ReelsMainModel>>> getFollowingReels(String? page);

  ResultFuture<Map<String, String>> getPreSignedUrl(File reel);

  ResultFuture<int> uploadFileToStorage(UploadReelParam param,);

  ResultFuture<BaseResponse<ReelsMainModel>> notifyBackend(UploadReelParam param,);

}