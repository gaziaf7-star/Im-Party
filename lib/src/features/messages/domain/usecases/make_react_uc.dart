import 'package:general/src/core/index.dart';
import 'package:general/src/features/messages/messages.dart';

class MakeReactUC extends UseCaseWithParams<MessagesModel, MakeReactParamsUC> {
  final BaseMessagesRepository _repo;

  const MakeReactUC(this._repo);

  @override
  ResultFuture<MessagesModel> call(params) async {
    final result = await _repo.makeReact(param: params);
    return result;
  }
}
