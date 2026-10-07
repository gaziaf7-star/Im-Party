import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

class EnterRoomUC extends UseCaseWithParams <BaseResponse<EnterRoomModel>, EnterRoomParameter> {
  final RoomBaseRepository _repo;

  EnterRoomUC( this._repo);

  @override
  ResultFuture<BaseResponse<EnterRoomModel>> call(EnterRoomParameter params) async {
    final result = await _repo.enterRoom(params);
    return result;
  }
}
