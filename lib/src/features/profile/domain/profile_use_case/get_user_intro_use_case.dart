import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/data/model/user_intro_model.dart';
import 'package:general/src/features/profile/domain/profile_base_repository/profile_base_repository.dart';


class GetUserIntroUseCase extends UseCaseWithParams<BaseResponse<List<UserIntroModel>>,String> {
  ProfileBaseRepository baseRepositoryProfile;
  GetUserIntroUseCase({required this.baseRepositoryProfile});

  @override
  ResultFuture<BaseResponse<List<UserIntroModel>>> call(String params)async {
    final result = await baseRepositoryProfile.getUserIntro(userId: params);
    return result ;
  }
}