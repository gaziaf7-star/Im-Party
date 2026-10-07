import 'package:general/src/core/base/base_repository.dart';
import 'package:general/src/core/base/base_use_case.dart';

import '../../../../core/base/base_response.dart';
import '../../../../core/base/parameters.dart';
import '../base_repo/settings_base_repository.dart';

class BindNumberUseCase
    extends UseCaseWithParams<BaseResponse<String>, SendCodeParameter> {
  final SettingsBaseRepository baseRepository;

  const BindNumberUseCase({required this.baseRepository});

  @override
  ResultFuture<BaseResponse<String>> call(params) {
    return baseRepository.boundNumber(params);
  }
}


class ChangePassUseCase
    extends UseCaseWithParams<BaseResponse<String>, BindAccountParam> {
  final SettingsBaseRepository baseRepository;

  const ChangePassUseCase({required this.baseRepository});

  @override
  ResultFuture<BaseResponse<String>> call(params) {
    return baseRepository.changePassword(params);
  }
}
