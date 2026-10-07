import 'package:general/src/features/auth/auth.dart';

import '../../../../core/base/base_repository.dart';
import '../../../../core/base/base_response.dart';
import '../../../../core/base/base_use_case.dart';
import '../../../../core/base/parameters.dart';

class ChangeForgetPassUseCase extends UseCaseWithParams<BaseResponse<String>, SendCodeParameter> {
  final BaseAuthenticationRepository baseRepository;

  const ChangeForgetPassUseCase({required this.baseRepository});

  @override
  ResultFuture<BaseResponse<String>> call(params) {
    return baseRepository.changePassword(params);
  }
}
