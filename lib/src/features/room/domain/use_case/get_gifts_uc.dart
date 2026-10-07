import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

class FetchGiftsUC
    extends UseCaseWithParams<BaseResponse<List<GiftsModel>>, int> {
  final RoomBaseRepository _repo;

  FetchGiftsUC(this._repo);

  @override
  ResultFuture<BaseResponse<List<GiftsModel>>> call(int params) async {
    final result = await _repo.fetchGifts(params);
    return result;
  }
}
