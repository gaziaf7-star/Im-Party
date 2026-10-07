import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';

class SignInWithAppleUC extends UseCaseWithoutParams<BaseResponse<AppleModel>> {
  final BaseAuthenticationRepository _repo;

  SignInWithAppleUC(this._repo);

  @override
  ResultFuture<BaseResponse<AppleModel>> call() async {
    final result = await _repo.sigInWithApple();

    return result;
  }
}
