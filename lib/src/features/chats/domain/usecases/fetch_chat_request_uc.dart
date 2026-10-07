import 'package:general/src/features/chats/chats.dart';
import 'package:general/src/features/chats/domain/repository/chats_repository.dart';


class FetchChatRequestUC extends UseCaseWithoutParams<UserAllChatRequestModel>{
  final ChatsRepository _repo ;

  const FetchChatRequestUC( this._repo);

  @override
  ResultFuture<UserAllChatRequestModel> call() async {
    final result = await _repo.fetchChatsRequest();
    return result;
  }
}

