import 'package:general/src/core/base/base_repository.dart';
import 'package:general/src/core/base/base_use_case.dart';

import '../../../../core/base/base_response.dart';
import '../base_repo/settings_base_repository.dart';

class LogOutUseCase extends UseCaseWithoutParams<BaseResponse<String>> {
  final SettingsBaseRepository baseRepository;

  const LogOutUseCase({required this.baseRepository});

  @override
  ResultFuture<BaseResponse<String>> call() {
    return baseRepository.logOut();
  }
}
