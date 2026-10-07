import 'package:general/src/features/auth/data/model/wabbles_model.dart';
import 'package:general/src/features/auth/domain/repository/base_auth_repository.dart';
import 'package:general/src/features/chats/chats.dart';

class GetWabblesUc extends UseCaseWithoutParams<List<WabblesModel>> {
  final BaseAuthenticationRepository _repo;

  GetWabblesUc(this._repo);

  @override
  ResultFuture<List<WabblesModel>> call() async {
    final result = await _repo.getWabbles();
    return result;
  }
}
