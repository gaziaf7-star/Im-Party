import 'package:general/src/core/index.dart';
import 'package:general/src/features/messages/messages.dart';

class PinChatToTopUC
    extends UseCaseWithParams<BaseResponse<String>, PinChatToTopParamsUC> {
  final BaseMessagesRepository _repo;

  const PinChatToTopUC(this._repo);

  @override
  ResultFuture<BaseResponse<String>> call(params) async {
    final result = await _repo.pinChatToTop(pram: params);
    return result;
  }
}
