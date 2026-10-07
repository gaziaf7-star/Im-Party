import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';

class SignInWithHuaweiUC
    extends UseCaseWithoutParams<BaseResponse<AuthWithHuaweiModel>> {
  final BaseAuthenticationRepository _repo;

  SignInWithHuaweiUC(this._repo);

  @override
  ResultFuture<BaseResponse<AuthWithHuaweiModel>> call() async {
    final result = await _repo.sigInWithHuawei();

    return result;
  }
}
