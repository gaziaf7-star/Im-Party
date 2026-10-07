import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

class GetTopRoomUC extends UseCaseWithParams<BaseResponse<RankingModel>,
    TopParameterInRoom> {
  final RoomBaseRepository _repo;

  GetTopRoomUC(this._repo);

  @override
  ResultFuture<BaseResponse<RankingModel>> call(
      TopParameterInRoom params) async {
    final result = await _repo.fetchTopInRoom(params);
    return result;
  }
}
