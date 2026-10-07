import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

class GetSuperBoomRulesUC
    extends UseCaseWithoutParams<BaseResponse<BombRulesResponse>> {
  final RoomBaseRepository _repo;

  GetSuperBoomRulesUC(this._repo);

  @override
  ResultFuture<BaseResponse<BombRulesResponse>> call() async {
    final result = await _repo.getSuperBombRules();
    return result;
  }
}
