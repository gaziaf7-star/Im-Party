import 'package:general/src/core/index.dart';

import 'dart:io';

import 'package:general/src/features/room/domain/base_repository/room_base_repository.dart';

// UseCase for getting pre-signed URL
class GetPreSignedUrlSongUseCase
    extends UseCaseWithParams<Map<String, String>, File> {
  final RoomBaseRepository roomBaseRepo;

  GetPreSignedUrlSongUseCase({required this.roomBaseRepo});

  @override
  ResultFuture<Map<String, String>> call(File params) async {
    return await roomBaseRepo.getPreSignedUrl(params);
  }
}

// UseCase for uploading file to storage
class UploadFileSongToStorageUseCase
    extends UseCaseWithParams<int, UploadSongParam> {
  final RoomBaseRepository roomBaseRepo;

  UploadFileSongToStorageUseCase({required this.roomBaseRepo});

  @override
  ResultFuture<int> call(UploadSongParam params) async {
    return await roomBaseRepo.uploadFileToStorage(params);
  }
}

// UseCase for notifying the backend
class NotifyBackendSongUseCase
    extends UseCaseWithParams<BaseResponse<String>, UploadSongParam> {
  final RoomBaseRepository roomBaseRepo;

  NotifyBackendSongUseCase({required this.roomBaseRepo});

  @override
  ResultFuture<BaseResponse<String>> call(UploadSongParam params) async {
    return await roomBaseRepo.notifyBackend(params);
  }
}
