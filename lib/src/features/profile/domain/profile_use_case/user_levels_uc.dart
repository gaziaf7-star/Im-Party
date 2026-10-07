import 'package:general/src/features/auth/data/model/user_levels_model.dart';

import '../../../../core/base/base_repository.dart';
import '../../../../core/base/base_response.dart';
import '../../../../core/base/base_use_case.dart';
import '../../../room/presentation/gifts/gift.dart';

class UserLevelsUc extends UseCaseWithoutParams<BaseResponse<UserLevelsModel>> {
  final ProfileBaseRepository baseRepositoryProfile;
  UserLevelsUc({required this.baseRepositoryProfile});

  @override  
  ResultFuture <BaseResponse<UserLevelsModel>> call() async {
    final result = await baseRepositoryProfile.userLevels();
    return result;
  }
 
}


