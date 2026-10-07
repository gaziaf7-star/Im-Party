import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

class GetConfigKeyUC extends UseCaseWithParams<BaseResponse<GetConfigKeyModel>,
    GetConfigKeyPram> {
  final RoomBaseRepository _repo;

  GetConfigKeyUC(this._repo);

  @override
  ResultFuture<BaseResponse<GetConfigKeyModel>> call(
      GetConfigKeyPram params) async {
    final result = await _repo.fetchConfigKey(params);
    return result;
  }
}
