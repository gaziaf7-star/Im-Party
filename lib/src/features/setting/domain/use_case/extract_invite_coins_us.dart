import 'package:general/src/features/setting/domain/base_repo/settings_base_repository.dart';
import '../../../../core/index.dart';

class ExtractInviteCoinsUseCase
    extends UseCaseWithoutParams<BaseResponse<String>> {
  final SettingsBaseRepository baseRepository;
  const ExtractInviteCoinsUseCase({required this.baseRepository});

  @override
  ResultFuture<BaseResponse<String>> call() {
    return baseRepository.extractInvitationCoins();
  }
}
