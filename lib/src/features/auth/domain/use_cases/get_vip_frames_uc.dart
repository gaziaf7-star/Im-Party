import 'package:general/src/features/auth/data/model/vip_frames_model.dart';
import 'package:general/src/features/auth/domain/repository/base_auth_repository.dart';
import 'package:general/src/features/chats/chats.dart';

class GetVipFramesUc extends  UseCaseWithoutParams<BaseResponse<List<VipFramesModel>>>  {
  final BaseAuthenticationRepository _repo;

  GetVipFramesUc(this._repo);

  @override
  ResultFuture<BaseResponse<List<VipFramesModel>>>  call() async {
    final result = await _repo.getVipFrames();
    return result;
  }
}
