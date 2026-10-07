import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

class GetFreeGamesImagesUC extends UseCaseWithoutParams<BaseResponse<FreeGamesModel>> {
  final RoomBaseRepository _repo;

  GetFreeGamesImagesUC(this._repo);

  @override
  ResultFuture<BaseResponse<FreeGamesModel>> call() async {
    final result = await _repo.getFreeGamesImages();
    return result;
  }
}
