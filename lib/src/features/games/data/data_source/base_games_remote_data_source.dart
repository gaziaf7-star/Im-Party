import 'package:general/src/features/auth/data/model/user_model.dart';
import 'package:general/src/features/games/data/model/agency_ranking_model.dart';
import 'package:general/src/features/games/data/model/users_online_model.dart';
import 'package:general/src/features/games/games.dart';
import 'package:general/src/features/home/home.dart';

abstract class BaseGamesRemoteDataSource {
  Future<BaseResponse<GamesModel>> fetchGames(String type);
  Future<BaseResponse<List<UsersOnlineModel>>> fetchOnlineUsers(String page);
  Future<BaseResponse<List<UserModel>>> fetchGamers(String page);
  Future<String> stopGamers();

  Future<BaseResponse<List<RoomModel>>> fetchGamesRoom({
    required String gameId,
  });

  Future<BaseResponse<RankingModel>> fetchRanking({
    required TopParameter params,
  });

  Future<BaseResponse<List<UserProfileModel>>> fetchUsers(int page);

  Future<BaseResponse<int>> makeLikeUser({required String userId});

  Future<BaseResponse<int>> makeIgnoreUser({required String userId});

  Future<BaseResponse<List<AgencyRankingModel>>> fetchAgencyRanking({
    required TopParameter params,
  });
}

class GamesRemoteDataSoursImp implements BaseGamesRemoteDataSource {
  final DioFactory _dio;

  GamesRemoteDataSoursImp(this._dio);

  @override
  Future<BaseResponse<List<RoomModel>>> fetchGamesRoom({
    required gameId,
  }) async {
    final response = await _dio.get(EndPoints.getGameRoom(gameId));

    return BaseResponse<List<RoomModel>>.fromJson(
      response.data,
      fromJsonT: (json) => List<RoomModel>.from(
        (json as List).map((element) => RoomModel.fromJson(element)),
      ),
    );
  }

  @override
  Future<BaseResponse<GamesModel>> fetchGames(String type) async {
    final response = await _dio.get(

        type=='inner'?'${EndPoints.getAllGamesData}in-room':
        '${EndPoints.getAllGamesData}out-of-room');

    return BaseResponse<GamesModel>.fromJson(
      response.data,
      fromJsonT: (json) => GamesModel.fromJson(json),
    );
  }

  @override
  Future<BaseResponse<RankingModel>> fetchRanking({required params}) async {
    final body = {
      'class': params.sendOrReceiver,
      'type': params.date,
      'is_home': params.isHome,
    };
    final response = await _dio.post(EndPoints.getTopUrl, data: body);
    return BaseResponse<RankingModel>.fromJson(
      response.data,
      fromJsonT: (json) {
        return RankingModel.fromJson(json);
      },
    );
  }

  @override
  Future<BaseResponse<List<UserProfileModel>>> fetchUsers(int page) async {
    final response = await _dio.get(EndPoints.getUserProfile, queryParameters: {
      'page': page,
    });
    return BaseResponse<List<UserProfileModel>>.fromJson(
      response.data,
      fromJsonT: (json) => (json as List)
          .map((element) => UserProfileModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<List<UserModel>>> fetchGamers(String page) async {
    final response =
        await _dio.get(EndPoints.usersPlay, queryParameters: {'page': page});
    return BaseResponse<List<UserModel>>.fromJson(
      response.data,
      fromJsonT: (json) =>
          (json as List).map((element) => UserModel.fromJson(element)).toList(),
    );
  }

  @override
  Future<BaseResponse<List<UsersOnlineModel>>> fetchOnlineUsers(
      String page) async {
    final response = await _dio.get(EndPoints.usersOnline, queryParameters: {
      'page': page,
    });
    return BaseResponse<List<UsersOnlineModel>>.fromJson(
      response.data,
      fromJsonT: (json) => (json as List)
          .map((element) => UsersOnlineModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<List<AgencyRankingModel>>> fetchAgencyRanking(
      {required TopParameter params}) async {
    final body = {
      'class': params.sendOrReceiver,
      'type': params.date,
      'is_home': params.isHome,
    };
    final response = await _dio.post(EndPoints.getTopUrl, data: body);

    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => (json as List)
          .map((element) => AgencyRankingModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<String> stopGamers() async {
    final response = await _dio.get(EndPoints.stopPlay);
    return response.data['message'];
  }

  @override
  Future<BaseResponse<int>> makeLikeUser({required userId}) async {
    final body = {'user_id': userId};
    final response = await _dio.post(EndPoints.likeUser, data: body);
    return BaseResponse<int>.fromJson(response.data);
  }

  @override
  Future<BaseResponse<int>> makeIgnoreUser({required userId}) async {
    final body = {'user_id': userId};
    final response = await _dio.post(EndPoints.ignoreUser, data: body);
    return BaseResponse<int>.fromJson(response.data);
  }
}
