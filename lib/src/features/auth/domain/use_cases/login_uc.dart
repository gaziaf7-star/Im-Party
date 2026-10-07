import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/setting/data/model/switch_account_model.dart';

class LoginUC extends UseCaseWithParams<BaseResponse<SwitchLoginAccountModel>,
    AuthParameter> {
  final BaseAuthenticationRepository _repo;

  const LoginUC(this._repo);

  @override
  ResultFuture<BaseResponse<SwitchLoginAccountModel>> call(params) async {
    final result = await _repo.login(params);

    return result;
  }
}
