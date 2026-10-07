import 'package:general/src/features/room/room.dart';
import '../../../../core/index.dart';

class SendLuckyBoxUc
    extends UseCaseWithParams<BaseResponse<SendLuckyBoxModel>, LuckyBoxParam> {
  final RoomBaseRepository _repo;

  SendLuckyBoxUc(this._repo);

  @override
  ResultFuture<BaseResponse<SendLuckyBoxModel>> call(
      LuckyBoxParam params) async {
    return await _repo.sendLuckyBox(params);
  }
}
