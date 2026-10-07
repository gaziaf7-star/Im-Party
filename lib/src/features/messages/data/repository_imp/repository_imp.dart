import 'package:general/src/core/index.dart';
import 'package:general/src/features/messages/messages.dart';

class MessagesRepositoryImp extends BaseMessagesRepository {
  final BaseMessagesRemoteDataSource _repo;

  MessagesRepositoryImp(this._repo);

  @override
  ResultFuture<BaseResponse<String>> sendMessageAll({required pram}) async {
    return execute<BaseResponse<String>>(() => _repo.sendMessageAll(pram));
  }

  @override
  ResultFuture<BaseResponse<MessagesModel>> updateMessage(
      {required pram}) async {
    return execute<BaseResponse<MessagesModel>>(
        () => _repo.updateMessage(param: pram));
  }

  @override
  ResultFuture<BaseResponse<String>> deleteMessage({required pram}) async {
    return execute<BaseResponse<String>>(
        () => _repo.deleteMessage(param: pram));
  }

  @override
  ResultFuture<BaseResponse<String>> pinChatToTop({required pram}) async {
    return execute<BaseResponse<String>>(() => _repo.pinChatToTop(param: pram));
  }

  @override
  ResultFuture<BaseResponse<String>> removePinChatToTop(
      {required String userId}) async {
    return execute<BaseResponse<String>>(
        () => _repo.removePinChatToTop(userId: userId));
  }

  @override
  ResultFuture<BaseResponse<ConversationModel>> fetchMessages(
      {required param}) async {
    return execute<BaseResponse<ConversationModel>>(
        () => _repo.fetchMessages(param: param));
  }

  @override
  ResultFuture<MessagesModel> makeReact({required param}) async {
    return execute<MessagesModel>(() => _repo.makeReact(param: param));
  }

  @override
  ResultFuture<void> closeChat({required chatId}) async {
    return execute<void>(() => _repo.closeChat(chatId: chatId));
  }

  @override
  ResultFuture<UserStatusEntity> onlineUser({required userId}) async {
    return execute<UserStatusEntity>(() => _repo.onlineUser(userId: userId));
  }

  @override
  ResultFuture<Map<String, String>> getPreSignedUrl(
      SendVideoParam param) {
    return execute<Map<String, String>>(
      () => _repo.getPreSignedUrl(param),
    );
  }

  @override
  ResultFuture<int> uploadFileToStorage(SendVideoParam param) {
    return execute<int>(
      () => _repo.uploadFileToStorage(param),
    );
  }
}
