import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/data/model/user_badges_model.dart';
import 'package:general/src/features/profile/domain/profile_base_repository/profile_base_repository.dart';


class UserBadgeUc extends UseCaseWithParams <BaseResponse<UserBadgesModel>, int> {
  ProfileBaseRepository baseRepositoryProfile;
  UserBadgeUc({required this.baseRepositoryProfile});
  
  @override
  ResultFuture<BaseResponse<UserBadgesModel>>  call(int params)async {
    final result = await baseRepositoryProfile.getUserBadges(params);
    return result ;
  }
}
