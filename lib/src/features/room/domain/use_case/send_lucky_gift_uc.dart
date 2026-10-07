import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

class SendLuckyGiftUC
    extends UseCaseWithParams<BaseResponse<LuckyGiftModel>, GiftParameter> {
  final RoomBaseRepository _repo;

  SendLuckyGiftUC(this._repo);

  @override
  ResultFuture<BaseResponse<LuckyGiftModel>> call(
      GiftParameter params) async {
    final result = await _repo.sendLuckyGift(params);
    return result;
  }
}
