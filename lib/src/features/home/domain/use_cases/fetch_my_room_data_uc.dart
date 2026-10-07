import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/data/model/my_rooms_model.dart';
import 'package:general/src/features/home/domain/repository/base_home_repository.dart';


class FetchMyRoomDataUc
    extends UseCaseWithoutParams<BaseResponse<MyRoomsModel>> {
  final BaseHomeRepository _repo;

  const FetchMyRoomDataUc(this._repo);

  @override
  ResultFuture<BaseResponse<MyRoomsModel>> call() async {
    return await _repo.getMyRoomData();
  }
}
