import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/data/model/user_model.dart';
import 'package:general/src/features/profile/domain/profile_base_repository/profile_base_repository.dart';




class FetchUserDataUseCase extends UseCaseWithParams <BaseResponse<UserModel>,GetUserDataParameter> {
  ProfileBaseRepository baseRepositoryProfile;
  FetchUserDataUseCase({required this.baseRepositoryProfile});
  @override
  ResultFuture <BaseResponse<UserModel>> call(params) async {
    final result = await baseRepositoryProfile.getUserData(params: params);
    return result ;
  }
}

