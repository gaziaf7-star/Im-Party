import 'package:general/src/core/index.dart';
import 'package:general/src/features/cp/data/model/cp_model.dart';
import 'package:general/src/features/cp/domain/cp_base_repository/cp_base_repository.dart';

class FetchRankingCpUC
    extends UseCaseWithParams<BaseResponse<CpModel>, TopParameter> {
  final CpBaseRepository _repo;
  const FetchRankingCpUC(this._repo);

  @override
  ResultFuture<BaseResponse<CpModel>> call(TopParameter params) async {
    final result = await _repo.fetchRankingCp(params: params);
    return result;
  }
}
