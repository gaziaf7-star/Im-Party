import 'package:general/src/features/room/room.dart';

import '../../../../core/index.dart';

class ResetCharismaUC extends UseCaseWithParams<BaseResponse<Map<String, dynamic>>, ResetCharismaParam> {
  final RoomBaseRepository _repo;

  ResetCharismaUC(this._repo);

  @override
  ResultFuture<BaseResponse<Map<String, dynamic>>> call(ResetCharismaParam params) async {
    return await _repo.resetCharisma(params);
  }
}
