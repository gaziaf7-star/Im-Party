import 'package:general/src/features/auth/data/model/user_model.dart';
import 'package:general/src/features/games/games.dart';

class FetchUsersGamersUC
    extends UseCaseWithParams<BaseResponse<List<UserModel>>,String> {
  final BaseGamesRepository _repo;
  const FetchUsersGamersUC(this._repo);
  @override
  ResultFuture<BaseResponse<List<UserModel>>> call(String params) async {
    final result = await _repo.fetchGamers(params);
    return result;
  }
}
