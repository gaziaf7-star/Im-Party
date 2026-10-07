

import '../../data/models/moment_like_model.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/moment/moment.dart';


class GetMomentLikeUseCase extends UseCaseWithParams<
    BaseResponse<List<MomentLikeModel>>, GetMomentLikePrameter>{
 final BaseMomentRepository baseMomentRepository;
  const GetMomentLikeUseCase({required this.baseMomentRepository});


 @override
  ResultFuture<BaseResponse<List<MomentLikeModel>>> call(params) async {
    return await baseMomentRepository.getMomentLike(param: params);
  }




}



