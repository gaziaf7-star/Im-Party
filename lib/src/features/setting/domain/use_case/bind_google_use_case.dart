import 'package:general/src/core/base/base_repository.dart';
import 'package:general/src/core/base/base_use_case.dart';

import '../base_repo/settings_base_repository.dart';

class BindGoogleUseCase extends UseCaseWithoutParams<String> {
  final SettingsBaseRepository baseRepository;

  const BindGoogleUseCase({required this.baseRepository});

  @override
  ResultFuture<String> call() {
    return baseRepository.bindGmail();
  }
}
