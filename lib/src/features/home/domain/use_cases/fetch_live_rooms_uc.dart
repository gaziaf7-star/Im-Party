import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/home.dart';

class FetchLiveRoomsUC
    extends UseCaseWithParams<BaseResponse<List<RoomModel>>, RoomsParameterUC> {
  final BaseHomeRepository _repo;
  const FetchLiveRoomsUC(this._repo);

  @override
  ResultFuture<BaseResponse<List<RoomModel>>> call(params) async {
    return await _repo.fetchLiveRooms(params: params);
  }
}
