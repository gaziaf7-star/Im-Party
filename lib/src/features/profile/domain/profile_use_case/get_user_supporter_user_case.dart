import 'package:general/src/features/profile/data/model/top_support.dart';
import 'package:general/src/features/profile/domain/profile_base_repository/profile_base_repository.dart';

import '../../../../core/index.dart';

class GetUserSupporterUserCase extends UseCaseWithParams <BaseResponse<TopSupportModel>, String> {
  ProfileBaseRepository baseRepositoryProfile;
  GetUserSupporterUserCase({required this.baseRepositoryProfile});
  @override
  ResultFuture<BaseResponse<TopSupportModel>>  call(String params)async {
    final result = await baseRepositoryProfile.getUserSupporter(params);
    return result ;
  }
}
