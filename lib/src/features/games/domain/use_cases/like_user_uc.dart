import 'package:general/src/features/games/games.dart';

class LikeUserUC extends UseCaseWithParams<BaseResponse<int>, String> {
  final BaseGamesRepository _repo;

  const LikeUserUC(this._repo);

  @override
  ResultFuture<BaseResponse<int>> call(params) async {
    final result = await _repo.makeLikeUser(userId: params);
    return result;
  }
}
