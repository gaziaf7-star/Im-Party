import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/data/model/level_model.dart';
import 'package:general/src/features/profile/domain/profile_base_repository/profile_base_repository.dart';

class GetMyLevelDataUseCase
    extends UseCaseWithoutParams<BaseResponse<LevelModel>> {
  ProfileBaseRepository baseRepositoryProfile;
  GetMyLevelDataUseCase({required this.baseRepositoryProfile});
  @override
  ResultFuture<BaseResponse<LevelModel>> call() async {
    final result = await baseRepositoryProfile.getMyLevelsData();
    return result;
  }
}
