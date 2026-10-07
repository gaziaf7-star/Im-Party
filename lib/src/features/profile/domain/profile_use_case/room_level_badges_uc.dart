import '../../../../core/base/base_repository.dart';
import '../../../../core/base/base_response.dart';
import '../../../../core/base/base_use_case.dart';
import '../../../room/presentation/gifts/gift.dart';
import '../../data/model/levels_badges_model.dart';

class RoomLevelBadgesUc
    extends UseCaseWithoutParams<BaseResponse<RoomLevelBadgesModel>> {
  final ProfileBaseRepository baseRepositoryProfile;
  RoomLevelBadgesUc({required this.baseRepositoryProfile});

  @override
  ResultFuture<BaseResponse<RoomLevelBadgesModel>> call() async {
    final result = await baseRepositoryProfile.roomLevelBadges();
    return result;
  }
}
