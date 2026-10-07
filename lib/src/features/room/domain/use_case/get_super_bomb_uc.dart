import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

class GetSuperBombUC
    extends UseCaseWithParams<BaseResponse<SuperBombModel>, String> {
  final RoomBaseRepository _repo;

  GetSuperBombUC(this._repo);

  @override
  ResultFuture<BaseResponse<SuperBombModel>> call(String params) async {
    final result = await _repo.getSuperBomb(roomId: params);
    return result;
  }
}
