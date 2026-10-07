import 'package:general/src/core/index.dart';
import 'package:general/src/features/messages/messages.dart';

class OnlineUserUC extends UseCaseWithParams<UserStatusEntity, String> {
  final BaseMessagesRepository _repo;
  const OnlineUserUC(this._repo);

  @override
  ResultFuture<UserStatusEntity> call(params) async {
    final result = await _repo.onlineUser(userId: params);
    return result;
  }
}
