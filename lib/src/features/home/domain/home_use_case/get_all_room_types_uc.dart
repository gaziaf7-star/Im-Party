import 'package:general/src/features/home/home.dart';

import '../../../../core/index.dart';


class GetAllRoomTypesUC extends UseCaseWithoutParams<BaseResponse<List<RoomTypesModel>>>{
  final BaseHomeRepository _repo;
  GetAllRoomTypesUC(this._repo);

  @override
  ResultFuture <BaseResponse<List<RoomTypesModel>>> call() async {
    return await _repo.fetchAllTypesRoom();
  }
}