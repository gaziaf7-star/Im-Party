import 'package:general/src/features/chats/chats.dart';
import 'package:general/src/features/chats/domain/repository/chats_repository.dart';
class ChatsRepositoryImp extends ChatsRepository {
  final ChatsRemoteDataSource _repo;

  ChatsRepositoryImp(this._repo);

  @override
  ResultFuture<BaseResponse<List<SystemAndOfficialMessagesModel>>> getSystemMessage(SystemOfficialParam params) async {
    return execute<BaseResponse<List<SystemAndOfficialMessagesModel>>>(() => _repo.getSystemMessage(params));
  }

  @override
  ResultFuture<BaseResponse<UserAllChatModel>> fetchChats(int? page) async{
    return execute<BaseResponse<UserAllChatModel>>(() => _repo.fetchChats(page));
  }
  @override
  ResultFuture<UserAllChatRequestModel> fetchChatsRequest() async{
    return execute<UserAllChatRequestModel>(() => _repo.fetchChatsRequest());
  }

  @override
  ResultFuture<BaseResponse<DeleteChatModel>> deleteChat({required int userId}) async{
    return execute<BaseResponse<DeleteChatModel>>(() => _repo.deleteChat(userId: userId));
  }

}