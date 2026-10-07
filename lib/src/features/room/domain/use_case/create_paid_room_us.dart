import 'package:general/src/features/room/room.dart';

import '../../../../core/index.dart';

class CreatePaidRoomUs extends UseCaseWithoutParams<BaseResponse<CreatePaidRoomModel>> {

  final RoomBaseRepository _repo;
  CreatePaidRoomUs(this._repo);

  @override
  ResultFuture<BaseResponse<CreatePaidRoomModel>> call() async {
    return await _repo.getCreatePaidRoom();
  }
}