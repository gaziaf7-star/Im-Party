import 'package:general/src/features/auth/data/model/user_model.dart';
import 'package:general/src/features/games/data/model/agency_ranking_model.dart';
import 'package:general/src/features/games/data/model/users_online_model.dart';
import 'package:general/src/features/games/games.dart';
import 'package:general/src/features/home/home.dart';

class GamesRepositoryImp implements BaseGamesRepository {
  final BaseGamesRemoteDataSource _remote;

  GamesRepositoryImp(this._remote);

  @override
  ResultFuture<BaseResponse<GamesModel>> fetchGames(String type) {
    return execute<BaseResponse<GamesModel>>(() => _remote.fetchGames(type));
  }

  @override
  ResultFuture<BaseResponse<List<RoomModel>>> fetchGamesRoom(
      {required String gameId}) {
    return execute<BaseResponse<List<RoomModel>>>(
        () => _remote.fetchGamesRoom(gameId: gameId));
  }

  @override
  ResultFuture<BaseResponse<List<UsersOnlineModel>>> fetchOnlineUsers(String page) {
    return execute<BaseResponse<List<UsersOnlineModel>>>(
        () => _remote.fetchOnlineUsers(page));
  }

  @override
  ResultFuture<BaseResponse<List<UserModel>>> fetchGamers(String page) {
    return execute<BaseResponse<List<UserModel>>>(
        () => _remote.fetchGamers(page));
  }

  @override
  ResultFuture<BaseResponse<RankingModel>> fetchRanking(
      {required TopParameter params}) {
    return execute<BaseResponse<RankingModel>>(
        () => _remote.fetchRanking(params: params));
  }


  @override
  ResultFuture<BaseResponse<List<UserProfileModel>>> fetchUsers(int page) {
    return execute<BaseResponse<List<UserProfileModel>>>(
        () => _remote.fetchUsers(page));
  }

  @override
  ResultFuture<String> stopGamers() {
    return execute<String>(
        () => _remote.stopGamers());
  }

  @override
  ResultFuture<BaseResponse<int>> makeIgnoreUser({required String userId}) {
    return execute<BaseResponse<int>>(
        () => _remote.makeIgnoreUser(userId: userId));
  }

  @override
  ResultFuture<BaseResponse<int>> makeLikeUser({required String userId}) {
    return execute<BaseResponse<int>>(
        () => _remote.makeLikeUser(userId: userId));
  }

    @override
  ResultFuture<BaseResponse<List<AgencyRankingModel>>> fetchAgencyRanking({required TopParameter params}) {
    return execute<BaseResponse<List<AgencyRankingModel>>>(
            () => _remote.fetchAgencyRanking(params: params));
  }
}
