import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/domain/base_repository/room_base_repository.dart';

class BlockCommentsUC extends UseCaseWithParams<BaseResponse<String>, BlockCommentsParameter> {
  final RoomBaseRepository _repo;

  BlockCommentsUC(this._repo);

  @override
  ResultFuture<BaseResponse<String>> call(BlockCommentsParameter params) async {
    return await _repo.blockComments(params);
  }
}
