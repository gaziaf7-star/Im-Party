import 'package:general/src/features/room/domain/base_repository/room_base_repository.dart';
import 'package:general/src/core/index.dart';

class RemovePassRoomUC extends UseCaseWithParams<String,String>{
  final RoomBaseRepository _repo;

  RemovePassRoomUC(this._repo);

  @override
  ResultFuture<String> call(String params) async {
    final result = await _repo.removePassRoom(params);
    return result;
  }
}
