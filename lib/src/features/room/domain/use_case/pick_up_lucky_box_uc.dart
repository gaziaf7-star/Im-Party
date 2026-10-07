import 'package:general/src/features/room/room.dart';
import '../../../../core/index.dart';

class PickUpLuckyBoxUc
    extends UseCaseWithParams<BaseResponse<PickUpLuckyBoxModel>, String> {
  final RoomBaseRepository _repo;

  PickUpLuckyBoxUc(this._repo);

  @override
  ResultFuture<BaseResponse<PickUpLuckyBoxModel>> call(String params) async {
    return await _repo.pickUpLuckyBox(params);
  }
}
