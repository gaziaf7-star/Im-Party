import 'package:general/src/features/vip/vip.dart';

class GetVipCenterUseCase
    extends UseCaseWithoutParams<BaseResponse<List<VipCenterModel>>> {
  final VipBaseRepository _vipBaseRepository;
  const GetVipCenterUseCase({required VipBaseRepository vipBaseRepository})
      : _vipBaseRepository = vipBaseRepository;

  @override
  ResultFuture<BaseResponse<List<VipCenterModel>>> call() async {
    final result = await _vipBaseRepository.getVipCenter();
    return result;
  }
}
