import 'package:general/src/core/index.dart';
import 'package:general/src/features/cp/cp.dart';

class GetCpRelationsUseCase extends UseCaseWithoutParams<BaseResponse<CpRelationsModel>>{
  final CpBaseRepository _repo;
  GetCpRelationsUseCase(this._repo);
  @override
  ResultFuture <BaseResponse<CpRelationsModel>> call() async {
    final result = await _repo.getCpRelations();
    return result;
  }
}
