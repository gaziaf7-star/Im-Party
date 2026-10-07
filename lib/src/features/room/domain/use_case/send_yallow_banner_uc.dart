import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/domain/base_repository/room_base_repository.dart';

class SendYallowBannerUC
    extends UseCaseWithParams<BaseResponse<String>, SendPobUpPram> {
  final RoomBaseRepository _repo;

  SendYallowBannerUC(this._repo);

  @override
  ResultFuture<BaseResponse<String>> call(SendPobUpPram params) async {
    final result = await _repo.sendYallowBanner(params);
    return result;
  }
}
