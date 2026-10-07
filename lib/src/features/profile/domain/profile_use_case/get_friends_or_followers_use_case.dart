
import '../../../../core/base/base_repository.dart';
import '../../../../core/base/base_response.dart';
import '../../../../core/base/base_use_case.dart';
import '../../../../core/base/parameters.dart';
import 'package:general/src/features/auth/data/model/user_model.dart';
import '../profile_base_repository/profile_base_repository.dart';

class GetFriendsOrFollowersUseCase extends UseCaseWithParams<BaseResponse<List<UserModel>>,FFFParameter> {
  final ProfileBaseRepository profileBaseRepository;

  GetFriendsOrFollowersUseCase({required this.profileBaseRepository});

  @override
  ResultFuture <BaseResponse<List<UserModel>>> call(FFFParameter params) async{
    final result = profileBaseRepository.getFriendsOrFollowers(params);
    return result;
  }
}
