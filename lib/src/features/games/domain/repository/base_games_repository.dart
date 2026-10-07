import 'package:general/src/features/auth/data/model/user_model.dart';
import 'package:general/src/features/games/data/model/agency_ranking_model.dart';
import 'package:general/src/features/games/data/model/users_online_model.dart';
import 'package:general/src/features/games/games.dart';
import 'package:general/src/features/home/home.dart';

abstract class BaseGamesRepository {
  ResultFuture<BaseResponse<GamesModel>> fetchGames(String type);
  ResultFuture<BaseResponse<List<RoomModel>>> fetchGamesRoom({
    required String gameId,
  });
  ResultFuture<BaseResponse<RankingModel>> fetchRanking({
    required TopParameter params,
  });

  ResultFuture<BaseResponse<List<UserProfileModel>>> fetchUsers(int page);
  ResultFuture<BaseResponse<List<UsersOnlineModel>>> fetchOnlineUsers(String page);
  ResultFuture<BaseResponse<List<UserModel>>> fetchGamers(String page);
  ResultFuture<String> stopGamers();
  ResultFuture<BaseResponse<int>> makeLikeUser({required String userId});
  ResultFuture<BaseResponse<int>> makeIgnoreUser({required String userId});
    ResultFuture<BaseResponse<List<AgencyRankingModel>>> fetchAgencyRanking(
      {required TopParameter params});

}
