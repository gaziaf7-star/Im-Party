import 'package:general/src/core/base/base_response.dart';
import 'package:general/src/features/auth/data/model/user_model.dart';

import '../../../../core/base/base_repository.dart';
import '../../../../core/base/base_use_case.dart';
import '../../../../core/base/parameters.dart';
import '../profile_base_repository/profile_base_repository.dart';

class GetVisitorsUc
    extends UseCaseWithParams<BaseResponse<List<UserModel>>, FFFParameter> {
  final ProfileBaseRepository baseRepositoryProfile;

  const GetVisitorsUc({required this.baseRepositoryProfile});

  @override
  ResultFuture<BaseResponse<List<UserModel>>> call(FFFParameter? params) async {
    return await baseRepositoryProfile.getVisitors(page: params);
  }
}
