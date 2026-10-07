import 'package:general/src/core/index.dart';
import 'package:general/src/features/cp/cp.dart';

class CpRequestUseCase extends UseCaseWithParams<String,CpRequestParam> {
    final CpBaseRepository _repo;
  CpRequestUseCase(this._repo);

  @override
  ResultFuture<String> call(CpRequestParam params) async {
    final result = await _repo.cpRequest(param: params);
    return result;
  }
}
