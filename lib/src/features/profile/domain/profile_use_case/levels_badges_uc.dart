import '../../../../core/base/base_repository.dart';
import '../../../../core/base/base_response.dart';
import '../../../../core/base/base_use_case.dart';
import '../../../room/presentation/gifts/gift.dart';
import '../../data/model/levels_badges_model.dart';

class LevelsBadgesUc extends UseCaseWithParams <BaseResponse<BadgesModel>, int> {
  final  ProfileBaseRepository baseRepositoryProfile;
  LevelsBadgesUc({required this.baseRepositoryProfile});
  @override
  ResultFuture<BaseResponse<BadgesModel>>  call( params)async {
    final result = await baseRepositoryProfile.levelsBadges(params);
    return result ;
  }
}
