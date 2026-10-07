import 'package:general/src/core/index.dart';
import 'package:general/src/features/messages/messages.dart';

class FetchMessagesUC
    extends UseCaseWithParams<BaseResponse<ConversationModel>, FetchMessagesParamsUC> {
  final BaseMessagesRepository _repo;

  const FetchMessagesUC(this._repo);

  @override
  ResultFuture<BaseResponse<ConversationModel>> call( params) async {
    final result = await _repo.fetchMessages(param: params);
    return result;
  }
}
