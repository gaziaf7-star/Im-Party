import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

class GetUserGiftUC
    extends UseCaseWithoutParams<BaseResponse<List<GiftsModel>>> {
  final RoomBaseRepository _repo;

  GetUserGiftUC(this._repo);

  @override
  ResultFuture<BaseResponse<List<GiftsModel>>> call() async {
    final result = await _repo.getUserGift();
    return result;
  }
}
