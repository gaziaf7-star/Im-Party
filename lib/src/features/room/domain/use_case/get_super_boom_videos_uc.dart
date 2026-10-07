import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

class GetSuperBoomVideosUC
    extends UseCaseWithoutParams<BaseResponse<SuberBoomVideoseModel>> {
  final RoomBaseRepository _repo;

  GetSuperBoomVideosUC(this._repo);

  @override
  ResultFuture<BaseResponse<SuberBoomVideoseModel>> call() async {
    final result = await _repo.getSuperBombVideos();
    return result;
  }
}
