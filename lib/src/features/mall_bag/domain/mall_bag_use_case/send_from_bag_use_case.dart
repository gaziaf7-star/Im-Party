import '../../../../../reels_viewer/reels_viewer.dart';
import '../../mall_bag.dart';

class SendFromBagUseCase extends  UseCaseWithParams<BaseResponse<String>, SendBagParam> {
  final BaseMallMyBagRepository mallBagBaseRepository;


  SendFromBagUseCase({required this.mallBagBaseRepository});

  @override
  ResultFuture<BaseResponse<String>> call(SendBagParam params) {
    return mallBagBaseRepository.sendItemFromBag(param: params);
  }

}