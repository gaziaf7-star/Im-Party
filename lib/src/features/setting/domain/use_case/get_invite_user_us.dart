import 'package:general/src/features/setting/data/model/invite_user_model.dart';
import 'package:general/src/features/setting/domain/base_repo/settings_base_repository.dart';

import '../../../../core/index.dart';

class GetInviteUserUseCase extends UseCaseWithoutParams<BaseResponse<List<InvitationUsersModel>>> {
  final SettingsBaseRepository baseRepository;

  const GetInviteUserUseCase({required this.baseRepository});

  @override
  ResultFuture<BaseResponse<List<InvitationUsersModel>>> call() {
    return baseRepository.getInviteUserList();
  }
}