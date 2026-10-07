import 'package:general/src/core/index.dart';
import 'package:general/src/features/messages/messages.dart';


class SendMessageAllUseCase extends UseCaseWithParams<BaseResponse<String>, SendMessageAllPram> {

  final BaseMessagesRepository baseRepositoryChat;


  const SendMessageAllUseCase({required this.baseRepositoryChat});


 @override
  ResultFuture<BaseResponse<String>> call(params) async {
    final result = await baseRepositoryChat.sendMessageAll(pram: params);
    return result;
  }

}