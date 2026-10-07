
import 'package:general/src/features/games/data/model/agency_ranking_model.dart';
import 'package:general/src/features/games/games.dart';

class FetchRankingUC
    extends UseCaseWithParams<BaseResponse<RankingModel>, TopParameter> {
  final BaseGamesRepository _repo;
  const FetchRankingUC(this._repo);

  @override
  ResultFuture<BaseResponse<RankingModel>> call(params) async {
    final result = await _repo.fetchRanking(params: params);
    return result;
  }
}

class FetchAgencyRankingUC
    extends UseCaseWithParams<BaseResponse<List<AgencyRankingModel>>, TopParameter> {
  final BaseGamesRepository _repo;
  const FetchAgencyRankingUC(this._repo);

  @override
  ResultFuture<BaseResponse<List<AgencyRankingModel>>> call(params) async {
    final result = await _repo.fetchAgencyRanking(params: params);
    return result;
  }
}