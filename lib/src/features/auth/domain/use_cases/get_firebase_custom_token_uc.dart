import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';

class GetFirebaseCustomTokenUc extends UseCaseWithoutParams<BaseResponse<String>> {
  final BaseAuthenticationRepository _repo;

  const GetFirebaseCustomTokenUc(this._repo);

  @override
  ResultFuture<BaseResponse<String>> call() async {
    return await _repo.getFirebaseCustomToken();
  }
}
