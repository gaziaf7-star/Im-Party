import 'package:general/src/features/setting/data/model/earn_invite_model.dart';
import 'package:general/src/features/setting/domain/base_repo/settings_base_repository.dart';
import '../../../../core/index.dart';

class GetMyEarnInviteUseCase extends UseCaseWithoutParams<BaseResponse<EarnInviteModel>> {
  final SettingsBaseRepository baseRepository;

  const GetMyEarnInviteUseCase({required this.baseRepository});

  @override
  ResultFuture<BaseResponse<EarnInviteModel>> call() {
    return baseRepository.getMyEarnInvite();
  }
}