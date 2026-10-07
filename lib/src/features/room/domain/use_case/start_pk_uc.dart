import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/domain/base_repository/room_base_repository.dart';

class StartPKUC extends UseCaseWithParams<BaseResponse<String>,StartPKParameter>{
  final RoomBaseRepository _repo;

  StartPKUC(this._repo);

  @override
  ResultFuture<BaseResponse<String>> call(StartPKParameter params) async {
    return await _repo.startPK(params);
  }
}
