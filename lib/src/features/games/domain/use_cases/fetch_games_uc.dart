import 'package:general/src/features/games/games.dart';

class FetchGamesUC
    extends UseCaseWithParams<BaseResponse<GamesModel>,String> {
  final BaseGamesRepository _repo;
  const FetchGamesUC(this._repo);
  @override
  ResultFuture<BaseResponse<GamesModel>> call(String type) async {
    final result = await _repo.fetchGames(type);
    return result;
  }
}
