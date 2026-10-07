
import 'package:general/src/features/chats/chats.dart';


abstract class ChatsRepository {
  ResultFuture<BaseResponse<List<SystemAndOfficialMessagesModel>>> getSystemMessage(SystemOfficialParam params);
  ResultFuture<BaseResponse<UserAllChatModel>> fetchChats(int? page);
  ResultFuture<UserAllChatRequestModel> fetchChatsRequest();
  ResultFuture<BaseResponse<DeleteChatModel>> deleteChat({required int userId});
}