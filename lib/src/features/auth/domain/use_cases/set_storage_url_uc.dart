import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';

class SetStorageUrlUc extends UseCaseWithoutParams<String> {
  final BaseAuthenticationRepository _repo;

  const SetStorageUrlUc(this._repo);

  @override
  ResultFuture<String> call() async {
    return await _repo.setStorageUrl();
  }
}
