import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

class GetMyBackgroundSettingUc extends UseCaseWithoutParams<BaseResponse<BackgroundSettingModel>>{
  final RoomBaseRepository _repo;

  GetMyBackgroundSettingUc(this._repo);

  @override
  ResultFuture<BaseResponse<BackgroundSettingModel>> call() async {
    return await _repo.getMyBackGroundSetting();
  }
}
