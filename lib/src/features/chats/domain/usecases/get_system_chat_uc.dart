import 'package:general/src/features/chats/domain/repository/chats_repository.dart';
import '../../chats.dart';

class GetSystemChatUC extends UseCaseWithParams<
    BaseResponse<List<SystemAndOfficialMessagesModel>>,SystemOfficialParam > {
  final ChatsRepository _repo;

  const GetSystemChatUC(this._repo);

  @override
  ResultFuture<BaseResponse<List<SystemAndOfficialMessagesModel>>>
      call(SystemOfficialParam params) async {
    final result = await _repo.getSystemMessage(params);
    return result;
  }
}
