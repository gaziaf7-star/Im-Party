import 'package:general/src/features/games/games.dart';
import 'package:general/src/features/home/home.dart';

class FetchGamesRoomUC
    extends UseCaseWithParams<BaseResponse<List<RoomModel>>, String> {
  final BaseGamesRepository _repo;
  const FetchGamesRoomUC(this._repo);

  @override
  ResultFuture<BaseResponse<List<RoomModel>>> call(params) async {
    final result = await _repo.fetchGamesRoom(gameId: params);
    return result;
  }
}
