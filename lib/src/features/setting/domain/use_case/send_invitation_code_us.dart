
import 'dart:developer';

import 'package:general/src/features/setting/domain/base_repo/settings_base_repository.dart';


import '../../../../core/index.dart';

class SendInvitationCodeUseCase  extends UseCaseWithParams<BaseResponse<String>,String> {
  final SettingsBaseRepository baseRepository;
  SendInvitationCodeUseCase({required this.baseRepository});

  @override
  ResultFuture<BaseResponse<String>> call(params) {
    final result =  baseRepository.sendInvitationCode(sendCode: params);
    log("QWERTY US $params");
    return result;
  }
}
