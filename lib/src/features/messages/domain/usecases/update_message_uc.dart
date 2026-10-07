import 'package:general/src/core/index.dart';
import 'package:general/src/features/messages/messages.dart';

class EditMessageUC
    extends UseCaseWithParams<BaseResponse<MessagesModel>, UpdateMessageUC> {
  final BaseMessagesRepository _repo;

  const EditMessageUC(this._repo);

  @override
  ResultFuture<BaseResponse<MessagesModel>> call(params) async {
    final result = await _repo.updateMessage(pram: params);
    return result;
  }
}
