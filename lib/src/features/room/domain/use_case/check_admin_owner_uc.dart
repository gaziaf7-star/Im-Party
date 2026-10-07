import 'package:general/src/features/room/domain/base_repository/room_base_repository.dart';
import 'package:general/src/core/index.dart';

class CheckAdminOwnerUc extends UseCaseWithParams<BaseResponse<bool>,CheckAdminOwnerParam>{

  final RoomBaseRepository _repo;

  CheckAdminOwnerUc(this._repo);

  @override
  ResultFuture<BaseResponse<bool>> call(CheckAdminOwnerParam params) async {
    return await _repo.checkAdminOwner(params) ;
  }
}