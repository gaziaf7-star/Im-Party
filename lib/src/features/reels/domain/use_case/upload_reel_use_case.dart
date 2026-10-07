import 'package:general/src/core/index.dart';
import 'package:general/src/features/reels/data/model/reel_model.dart';
import 'package:general/src/features/reels/domain/base_repo/reels_base_repo.dart';

import 'dart:io';

// UseCase for getting pre-signed URL
class GetPreSignedUrlUseCase extends UseCaseWithParams<Map<String, String>, File> {
  final ReelsBaseRepo baseRepositoryReels;

  GetPreSignedUrlUseCase({required this.baseRepositoryReels});

  @override
  ResultFuture<Map<String, String>> call( File params) async {
    return await baseRepositoryReels.getPreSignedUrl(params);
  }
}

// UseCase for uploading file to storage
class UploadFileToStorageUseCase extends UseCaseWithParams<int, UploadReelParam> {
  final ReelsBaseRepo baseRepositoryReels;

  UploadFileToStorageUseCase({required this.baseRepositoryReels});

  @override
  ResultFuture<int> call(UploadReelParam params) async {
    return await baseRepositoryReels.uploadFileToStorage(params);
  }
}

// UseCase for notifying the backend
class NotifyBackendUseCase extends UseCaseWithParams<BaseResponse<ReelsMainModel>, UploadReelParam> {
  final ReelsBaseRepo baseRepositoryReels;

  NotifyBackendUseCase({required this.baseRepositoryReels});

  @override
  ResultFuture<BaseResponse<ReelsMainModel>> call(UploadReelParam params) async {
    return await baseRepositoryReels.notifyBackend(params);
  }
}

