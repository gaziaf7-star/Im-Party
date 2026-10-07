import 'package:general/src/core/base/base_repository.dart';
import 'package:general/src/core/base/base_response.dart';
import 'package:general/src/core/base/base_use_case.dart';

import '../base_repo/settings_base_repository.dart';

class ActivePrivacyUseCase
    extends UseCaseWithParams<BaseResponse<String>, String> {
  final SettingsBaseRepository baseRepository;

  const ActivePrivacyUseCase({required this.baseRepository});

  @override
  ResultFuture<BaseResponse<String>> call(String params) {
    return baseRepository.prevActive(params);
  }
}

class DisActivePrivacyUseCase
    extends UseCaseWithParams<BaseResponse<String>, String> {
  final SettingsBaseRepository baseRepository;

  const DisActivePrivacyUseCase({required this.baseRepository});

  @override
  ResultFuture<BaseResponse<String>> call(String params) {
    return baseRepository.prevDispose(params);
  }
}
