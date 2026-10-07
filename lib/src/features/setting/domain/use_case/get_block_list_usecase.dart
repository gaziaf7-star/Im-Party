
import 'package:general/src/features/auth/data/model/user_model.dart';
import 'package:general/src/features/setting/domain/base_repo/settings_base_repository.dart';

import '../../../../core/index.dart';

class GetBlockListUseCase extends UseCaseWithoutParams <BaseResponse<List<UserModel>>>{
  final SettingsBaseRepository baseRepositoryProfile;
  const GetBlockListUseCase({required this.baseRepositoryProfile});

  @override
  ResultFuture<BaseResponse<List<UserModel>>> call() async {
    final result = await baseRepositoryProfile.getBlockList();
    return result;
  }
}
