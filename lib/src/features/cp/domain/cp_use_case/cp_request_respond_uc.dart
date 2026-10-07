

import 'package:general/src/features/cp/cp.dart';

import '../../../../core/index.dart';

class CpRequestRespondUseCase extends UseCaseWithParams<BaseResponse<String>,CpRequestRespondParam>{
  final CpBaseRepository _repo;
  CpRequestRespondUseCase(this._repo);


  @override
  ResultFuture<BaseResponse<String>> call(CpRequestRespondParam params) async {
    final result = await _repo.cpRequestRespond(params);
    return result;
  }
}
