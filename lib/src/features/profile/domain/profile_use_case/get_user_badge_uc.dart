import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/data/model/badges_model.dart';
import 'package:general/src/features/profile/domain/profile_base_repository/profile_base_repository.dart';


class GetUserBadgeUc extends UseCaseWithParams <BaseResponse<List<ImageData>>, String> {
  ProfileBaseRepository baseRepositoryProfile;
  GetUserBadgeUc({required this.baseRepositoryProfile});
  @override
  ResultFuture<BaseResponse<List<ImageData>>>  call(String params)async {
    final result = await baseRepositoryProfile.getUserBadge(params);
    return result ;
  }
}
