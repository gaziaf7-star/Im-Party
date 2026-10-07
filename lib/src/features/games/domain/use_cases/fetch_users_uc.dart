import 'package:general/src/features/games/games.dart';

class FetchUsersUC
    extends UseCaseWithParams<BaseResponse<List<UserProfileModel>>,int> {
  final BaseGamesRepository _repo;
  const FetchUsersUC(this._repo);
  @override
  ResultFuture<BaseResponse<List<UserProfileModel>>> call(int params) async {
    final result = await _repo.fetchUsers(params);
    return result;
  }
}
