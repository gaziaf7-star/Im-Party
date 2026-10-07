
import 'package:general/src/features/messages/domain/repository/base_messages_repository.dart';

import '../../../../core/index.dart';

// UseCase for getting pre-signed URL
class GetPreSignedUrlmessageVideoUseCase extends UseCaseWithParams<Map<String, String>, SendVideoParam> {
  final BaseMessagesRepository baseMessagesRepository;

  GetPreSignedUrlmessageVideoUseCase({required this.baseMessagesRepository});

  @override
  ResultFuture<Map<String, String>> call( SendVideoParam params) async {
    return await baseMessagesRepository.getPreSignedUrl(params);
  }
}

// UseCase for uploading file to storage
class UploadFileToStorageMessageVideoUseCase extends UseCaseWithParams<int, SendVideoParam> {
  final BaseMessagesRepository baseMessagesRepository;

  UploadFileToStorageMessageVideoUseCase({required this.baseMessagesRepository});

  @override
  ResultFuture<int> call(SendVideoParam params) async {
    return await baseMessagesRepository.uploadFileToStorage(params);
  }
}



