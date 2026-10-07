import 'package:general/src/features/chats/chats.dart';
import 'package:general/src/features/chats/domain/repository/chats_repository.dart';


class FetchChatUC extends UseCaseWithParams<BaseResponse<UserAllChatModel>,int>{
  final ChatsRepository _repo ;

  const FetchChatUC( this._repo);

  @override
  ResultFuture<BaseResponse<UserAllChatModel>> call(int? params) async {
    final result = await _repo.fetchChats(params);
    return result;
  }
}

