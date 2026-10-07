import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/data/model/user_model.dart';
import 'package:general/src/features/room/room.dart';

class FetchUsersDataUc
    extends UseCaseWithParams<BaseResponse<List<UserModel>>, List<String>> {
  final RoomBaseRepository _repo;
  const FetchUsersDataUc(this._repo);

  @override
  ResultFuture<BaseResponse<List<UserModel>>> call(List<String> param) async {
    return await _repo.fetchUsersData(userIds: param);
  }
}
