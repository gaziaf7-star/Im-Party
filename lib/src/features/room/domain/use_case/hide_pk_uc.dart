import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/domain/base_repository/room_base_repository.dart';

class HidePKUC extends UseCaseWithParams<BaseResponse<String>, String> {
  final RoomBaseRepository _repo;

  HidePKUC(this._repo);

  @override
  ResultFuture<BaseResponse<String>> call(String params) async {
    return await _repo.hidePK(params);
  }
}
