import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';


class UpdateRoomUC extends UseCaseWithParams<BaseResponse<EnterRoomModel>,ParameterUpdate>{
  final RoomBaseRepository _repo;

  UpdateRoomUC(this._repo);

  @override
  ResultFuture<BaseResponse<EnterRoomModel>> call(
      ParameterUpdate params) async {
    final result = await _repo.updateRoom(parameterUpdate: params);
    return result;
  }
}
