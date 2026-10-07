import 'package:general/src/features/home/data/model/create_room_model.dart';

import '../../../../core/index.dart';
import '../../home.dart';


class CreateRoomUC extends UseCaseWithParams<BaseResponse<CreateRoomModel>,CreateRoomParameter>{
  final BaseHomeRepository _repo;
  CreateRoomUC(this._repo);

  @override
  ResultFuture <BaseResponse<CreateRoomModel>> call(CreateRoomParameter params) async {
    return await _repo.createRoom(creatRoomParameter: params);
  }
}