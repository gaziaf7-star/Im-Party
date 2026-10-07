import '../../../../core/index.dart';
import '../../messages.dart';



class CloseChatUC extends UseCaseWithParams<void,int>{

  final BaseMessagesRepository _repo ;


  const CloseChatUC(this._repo);

  @override
  ResultFuture<void> call(int params) async {
    final result = await _repo.closeChat(chatId: params);
    return result ;
  }


}

