import 'package:general/src/features/setting/domain/base_repo/settings_base_repository.dart';
import '../../../../core/index.dart';

class AddInviteCodeUseCase extends UseCaseWithParams<BaseResponse<String>, String> {
  final SettingsBaseRepository baseRepository;
  const AddInviteCodeUseCase({required this.baseRepository});


  @override
  ResultFuture<BaseResponse<String>> call(String code) {
    return baseRepository.addInvitationCode(code: code);
  }
}