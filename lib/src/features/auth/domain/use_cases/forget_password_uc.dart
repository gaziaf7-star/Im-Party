
import '../../../../core/base/base_repository.dart';
import '../../../../core/base/base_response.dart';
import '../../../../core/base/base_use_case.dart';
import '../../../../core/base/parameters.dart';
import '../repository/base_auth_repository.dart';

class ForgetPasswordUC
    extends UseCaseWithParams<BaseResponse<String>, AuthParameterUC > {
  final BaseAuthenticationRepository _repo;

  const ForgetPasswordUC(this._repo);

  @override
  ResultFuture<BaseResponse<String>> call(params) async {
    return await _repo.forgetPassword(params: params);
  }
}
