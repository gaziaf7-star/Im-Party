import 'package:general/src/core/index.dart';
import 'package:general/src/features/cp/cp.dart';


class CpProfileUseCase extends UseCaseWithParams<BaseResponse<CpProfileModel>,String>{
   final CpBaseRepository _repo;
  CpProfileUseCase(this._repo);
  

   @override
   ResultFuture <BaseResponse<CpProfileModel>> call(String params) async {
    final result = await _repo.getCpProfile(userId: params);
    return result;
  }
}

