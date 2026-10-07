import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

class GetRoomBoomThemesUC
    extends UseCaseWithoutParams<BaseResponse<RoomBoomThemeModel>> {
  final RoomBaseRepository _repo;

  GetRoomBoomThemesUC(this._repo);

  @override
  ResultFuture<BaseResponse<RoomBoomThemeModel>> call() async {
    final result = await _repo.getRoomBoomThemes();
    return result;
  }
}
