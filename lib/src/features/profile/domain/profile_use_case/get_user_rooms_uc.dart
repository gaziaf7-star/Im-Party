import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/data/model/user_room_model.dart';
import 'package:general/src/features/profile/domain/profile_base_repository/profile_base_repository.dart';

class GetUserRoomsUseCase
    extends UseCaseWithParams<BaseResponse<UserRoomsModel>, int> {
  ProfileBaseRepository baseRepositoryProfile;
  GetUserRoomsUseCase({required this.baseRepositoryProfile});

  @override
  ResultFuture<BaseResponse<UserRoomsModel>> call(int params) async {
    final result = await baseRepositoryProfile.userRooms(params);
    return result;
  }
}
