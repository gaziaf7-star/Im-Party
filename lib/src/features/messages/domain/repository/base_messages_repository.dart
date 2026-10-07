import 'package:general/src/core/index.dart';
import 'package:general/src/features/messages/messages.dart';

abstract class BaseMessagesRepository {
  ResultFuture<BaseResponse<ConversationModel>> fetchMessages({
    required FetchMessagesParamsUC param,
  });
  ResultFuture<MessagesModel> makeReact({required MakeReactParamsUC param});

      ResultFuture<BaseResponse<String>> sendMessageAll(
      {required SendMessageAllPram pram});
  ResultFuture<BaseResponse<MessagesModel>> updateMessage({
    required UpdateMessageUC pram,
  });
  ResultFuture<BaseResponse<String>> deleteMessage({
    required DeleteMessageParamsUC pram,
  });
  ResultFuture<BaseResponse<String>> pinChatToTop(
      {required PinChatToTopParamsUC pram});
  ResultFuture<BaseResponse<String>> removePinChatToTop(
      {required String userId});
  ResultFuture<void> closeChat({required int chatId});
  ResultFuture<UserStatusEntity> onlineUser({required String userId});
  ResultFuture<Map<String, String>> getPreSignedUrl(SendVideoParam param);

  ResultFuture<int> uploadFileToStorage(SendVideoParam param,);


}
