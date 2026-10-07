import 'package:general/src/features/setting/data/model/privacy_policy.dart';
import 'package:general/src/features/setting/domain/base_repo/settings_base_repository.dart';

import '../../../../core/index.dart';

class PrivacyPolicyUseCase extends UseCaseWithoutParams<PrivacyPolicy>{
  final SettingsBaseRepository _repository;

  PrivacyPolicyUseCase( this._repository);

  @override
  ResultFuture<PrivacyPolicy> call() async {
    final result = await _repository.privacyPolicy();

    return result;
  }
}
