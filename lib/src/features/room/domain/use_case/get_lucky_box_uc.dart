import 'package:general/src/features/room/room.dart';
import '../../../../core/index.dart';

class GetLuckyBoxUC extends UseCaseWithoutParams<BaseResponse<LuckyBoxModel>> {
  final RoomBaseRepository _repo;

  GetLuckyBoxUC(this._repo);

  @override
  ResultFuture<BaseResponse<LuckyBoxModel>> call() async {
    return await _repo.getLuckyBoxes();
  }
}
