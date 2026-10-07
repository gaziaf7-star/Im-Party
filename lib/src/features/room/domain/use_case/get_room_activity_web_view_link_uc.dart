import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

class GetRoomActivityWebViewLinkUC
    extends UseCaseWithoutParams<BaseResponse<String>> {
  final RoomBaseRepository _repo;

  GetRoomActivityWebViewLinkUC(this._repo);

  @override
  ResultFuture<BaseResponse<String>> call() async {
    final result = await _repo.getRoomActivityWebViewLink();
    return result;
  }
}
