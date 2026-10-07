
import 'package:general/src/features/room/room.dart';

import '../../../../core/index.dart';

class StartCharismaUC extends UseCaseWithParams<BaseResponse<Map<String, dynamic>>,String>{
  final RoomBaseRepository _repo;

  StartCharismaUC(this._repo);

  @override
  ResultFuture<BaseResponse<Map<String, dynamic>>> call(String params) async {
    return await _repo.startCharisma(params);
  }
}
