import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';

class SignInWithGoogleUC
    extends UseCaseWithoutParams<BaseResponse<GoogleModel>> {
  final BaseAuthenticationRepository _repo;

  SignInWithGoogleUC(this._repo);

  @override
  ResultFuture<BaseResponse<GoogleModel>> call() async {
    final result = await _repo.sigInWithGoogle();

    return result;
  }
}
