

import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';

class RegisterUc
    extends UseCaseWithParams<BaseResponse<String>, AuthParameterUC > {
  final BaseAuthenticationRepository _repo;

  const RegisterUc(this._repo);

  @override
  ResultFuture<BaseResponse<String>> call(params) async {
    return await _repo.register(params: params);
  }
}
