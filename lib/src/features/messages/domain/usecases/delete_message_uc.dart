import 'package:general/src/core/index.dart';
import 'package:general/src/features/messages/messages.dart';

class DeleteMessageUC
    extends UseCaseWithParams<BaseResponse<String>, DeleteMessageParamsUC> {
  final BaseMessagesRepository _repo;

  const DeleteMessageUC(this._repo);

  @override
  ResultFuture<BaseResponse<String>> call(params) async {
    final result = await _repo.deleteMessage(pram: params);
    return result;
  }
}
