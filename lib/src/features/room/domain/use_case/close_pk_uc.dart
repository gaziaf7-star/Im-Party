import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/domain/base_repository/room_base_repository.dart';

class ClosePKUC extends UseCaseWithParams<BaseResponse<String>, ClosePKParameter> {
  final RoomBaseRepository _repo;

  ClosePKUC( this._repo);

  @override
  ResultFuture<BaseResponse<String>> call(ClosePKParameter params) async {
    return await _repo.closePK(params);
  }
}
