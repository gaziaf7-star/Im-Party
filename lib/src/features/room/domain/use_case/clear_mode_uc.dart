import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/data/model/close_effect_model.dart';
import 'package:general/src/features/room/room.dart';

class ClearModeUC extends UseCaseWithParams<BaseResponse<CloseEffectModel>, String> {
  final RoomBaseRepository _repo;

  ClearModeUC( this._repo);

  @override
  ResultFuture<BaseResponse<CloseEffectModel>> call(String params) async {
    final result = await _repo.clearMode(params);
    return result;
  }
}