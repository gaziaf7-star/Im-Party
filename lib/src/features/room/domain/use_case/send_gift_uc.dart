import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/domain/base_repository/room_base_repository.dart';
import 'package:general/src/features/room/data/model/send_gift_model.dart';

class SendGiftUC extends UseCaseWithParams<BaseResponse<SendGiftModel>, GiftParameter> {
  final RoomBaseRepository _repo;

  SendGiftUC(this._repo);

  @override
  ResultFuture<BaseResponse<SendGiftModel>> call(GiftParameter params) async {
    final result = await _repo.sendGifts(params);
    return result;
  }
}
