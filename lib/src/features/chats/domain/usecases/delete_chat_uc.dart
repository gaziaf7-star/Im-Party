
import 'package:general/src/features/chats/domain/repository/chats_repository.dart';
import '../../chats.dart';

class DeleteChatUC extends UseCaseWithParams<BaseResponse<DeleteChatModel>,int>{
  final ChatsRepository _repo ;

  const DeleteChatUC( this._repo);

  @override
  ResultFuture<BaseResponse<DeleteChatModel>> call(int params) async {
    final result = await _repo.deleteChat(userId: params);
    return result;
  }
}


