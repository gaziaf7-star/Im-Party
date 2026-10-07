import 'package:general/src/features/games/games.dart';

class StopGamersUc extends UseCaseWithoutParams<String> {
  final BaseGamesRepository _repo;

  const StopGamersUc(this._repo);

  @override
  ResultFuture<String> call() async {
    final result = await _repo.stopGamers();
    return result;
  }
}
