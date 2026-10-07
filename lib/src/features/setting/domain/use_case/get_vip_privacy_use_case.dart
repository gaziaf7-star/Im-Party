import 'package:general/src/core/base/base_repository.dart';
import 'package:general/src/core/base/base_response.dart';
import 'package:general/src/core/base/base_use_case.dart';

import '../../data/model/get_vip_prev.dart';
import '../base_repo/settings_base_repository.dart';

class GetVipPrivacyUseCase
    extends UseCaseWithoutParams<BaseResponse<List<GetVipPrevModel>>> {
  final SettingsBaseRepository baseRepository;

  const GetVipPrivacyUseCase({required this.baseRepository});

  @override
  ResultFuture<BaseResponse<List<GetVipPrevModel>>> call() {
    return baseRepository.getVipPrev();
  }
}
