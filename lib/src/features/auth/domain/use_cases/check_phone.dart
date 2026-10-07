import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';

class CheckPhoneUC extends UseCaseWithParams<BaseResponse<bool>, String> {
  final BaseAuthenticationRepository _repo;

  const CheckPhoneUC(this._repo);

  @override
  ResultFuture<BaseResponse<bool>> call( params) async {
    final result = await _repo.checkPhone(params);

    return result;
  }
}
