import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/domain/base_repository/room_base_repository.dart';

class DeleteSongUC extends UseCaseWithParams<BaseResponse<String>, int> {
  final RoomBaseRepository _repo;

  DeleteSongUC(this._repo);

  @override
  ResultFuture<BaseResponse<String>> call(int params) async {
    final result = await _repo.deleteSong(params);
    return result;
  }
}
