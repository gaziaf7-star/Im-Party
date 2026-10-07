import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

class GetRoomActivityDataUC
    extends UseCaseWithParams<BaseResponse<RoomRewardModel>, int> {
  final RoomBaseRepository _repo;

  GetRoomActivityDataUC(this._repo);

  @override
  ResultFuture<BaseResponse<RoomRewardModel>> call(int params) async {
    final result = await _repo.getRoomActivity(params);
    return result;
  }
}
