import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

class GetGiftImagesUC extends UseCaseWithoutParams<BaseResponse<List<String>>> {
  final RoomBaseRepository _repo;

  GetGiftImagesUC(this._repo);

  @override
  ResultFuture<BaseResponse<List<String>>> call() async {
    final result = await _repo.getGiftImages();
    return result;
  }
}
