import 'package:general/src/features/games/data/model/users_online_model.dart';
import 'package:general/src/features/games/games.dart';

class FetchOnlineUsersUc
    extends UseCaseWithParams<BaseResponse<List<UsersOnlineModel>>,String> {
  final BaseGamesRepository _repo;
  const FetchOnlineUsersUc(this._repo);
  @override
  ResultFuture<BaseResponse<List<UsersOnlineModel>>> call(String params) async {
    final result = await _repo.fetchOnlineUsers(params);
    return result;
  }
}
