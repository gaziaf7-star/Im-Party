import 'package:general/src/features/setting/domain/base_repo/settings_base_repository.dart';
import '../../../../core/index.dart';

class DeleteAccountUc extends UseCaseWithoutParams<String>{
  final SettingsBaseRepository _repository;

  DeleteAccountUc(this._repository);

  @override
  ResultFuture<String> call()  async {
    final result = await _repository.deleteAccount();

    return result;
  }
}
