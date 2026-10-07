import 'package:general/src/features/room/domain/base_repository/room_base_repository.dart';
import 'package:general/src/core/index.dart';

class LockCommentsUC extends UseCaseWithParams<String, LockCommentsParameter> {
  final RoomBaseRepository _repo;
  LockCommentsUC(this._repo);

  @override
  ResultFuture<String> call(LockCommentsParameter params) async {
    return await _repo.lockComments(params);
  }
}

class UnLockCommentsUC
    extends UseCaseWithParams<String, LockCommentsParameter> {
  final RoomBaseRepository _repo;
  UnLockCommentsUC(this._repo);

  @override
  ResultFuture<String> call(LockCommentsParameter params) async {
    return await _repo.unLockComments(params);
  }
}
