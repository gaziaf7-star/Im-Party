import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/home.dart';

class FetchRoomsUC extends UseCaseWithParams<
    BaseResponse<List<RoomModel>>, RoomsParameterUC> {
  final BaseHomeRepository _repo;
  const FetchRoomsUC(this._repo);
  @override
  ResultFuture<BaseResponse<List<RoomModel>>> call(params) async {
    return await _repo.fetchRooms(params: params);
  }
}
