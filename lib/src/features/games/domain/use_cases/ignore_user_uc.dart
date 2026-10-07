import 'package:general/src/features/games/games.dart';

class IgnoreUserUC extends UseCaseWithParams<BaseResponse<int>, String> {
  final BaseGamesRepository _repo;

  const IgnoreUserUC(this._repo);

  @override
  ResultFuture<BaseResponse<int>> call(params) async {
    final result = await _repo.makeIgnoreUser(userId: params);
    return result;
  }
}
