import 'dart:io';

import 'package:general/src/core/base/base_repository.dart';
import 'package:general/src/core/base/base_response.dart';
import 'package:general/src/core/base/parameters.dart';
import 'package:general/src/features/reels/data/data_source/reels_data_source.dart';
import 'package:general/src/features/reels/data/model/reel_comment_model.dart';
import 'package:general/src/features/reels/data/model/reel_model.dart';
import 'package:general/src/features/reels/domain/base_repo/reels_base_repo.dart';



class ReelsRepoImp implements ReelsBaseRepo {
  final ReelsBaseDataSource dataSource;

  ReelsRepoImp(this.dataSource);

  @override
  ResultFuture<BaseResponse<List<ReelCommentModel>>> getComments(ReelParam param) {
    return execute<BaseResponse<List<ReelCommentModel>>>(
          () => dataSource.getComments(param),
    );
  }

  @override
  ResultFuture<BaseResponse<String>> deleteReel(ReelParam param) {
    return execute<BaseResponse<String>>(
          () => dataSource.deleteReel(param),
    );
  }
  @override
  ResultFuture<BaseResponse<String>> updateReelDescription(ReelParam param) {
    return execute<BaseResponse<String>>(
          () => dataSource.updateReelDescription(param),
    );
  }

 @override
  ResultFuture<BaseResponse<List<ReelsMainModel>>> getMyReels(ReelParam param) {
    return execute<BaseResponse<List<ReelsMainModel>>>(
          () => dataSource.getMyReels(param),
    );
  }


  @override
  ResultFuture<BaseResponse<List<ReelsMainModel>>> getFollowingReels(String? page) {
    return execute<BaseResponse<List<ReelsMainModel>>>(
          () => dataSource.getFollowingReels(page),
    );
  }

  @override
  ResultFuture<BaseResponse<List<ReelsMainModel>>> getReels(ReelParam param) {
    return execute<BaseResponse<List<ReelsMainModel>>>(
          () => dataSource.getReels(param),
    );
  }
  @override
  ResultFuture<BaseResponse<ReelsMainModel>> getOneReel(ReelParam param) {
    return execute<BaseResponse<ReelsMainModel>>(
          () => dataSource.getOneReel(param),
    );
  }

  @override
  ResultFuture<BaseResponse<String>> makeComments(ReelParam param) {
    return execute<BaseResponse<String>>(
          () => dataSource.makeComments(param),
    );
  }

  @override
  ResultFuture<BaseResponse<String>> makeLike(String reelId) {
    return execute<BaseResponse<String>>(
          () => dataSource.makeLike(reelId),
    );
  }



  @override
  ResultFuture<Map<String, String>> getPreSignedUrl(File reel) {
    return execute<Map<String, String>>(
          () => dataSource.getPreSignedUrl(reel),
    );
  }

  @override
  ResultFuture<BaseResponse<ReelsMainModel>> notifyBackend(UploadReelParam param) {
    return execute<BaseResponse<ReelsMainModel>>(
          () => dataSource.notifyBackend(param),
    );
  }

  @override
  ResultFuture<int> uploadFileToStorage(UploadReelParam param) {
    return execute<int>(
          () => dataSource.uploadFileToStorage(param),
    );
  }
}


