import 'package:general/src/core/index.dart';
import 'package:general/src/features/moment/moment.dart';

class FetchMomentUseCase
    extends UseCaseWithParams<BaseResponse<List<MomentModel>>, MomentsParam> {
  final BaseMomentRepository baseMomentRepository;
  const FetchMomentUseCase({required this.baseMomentRepository});

  @override
  ResultFuture<BaseResponse<List<MomentModel>>> call(params) async {
    return await baseMomentRepository.fetchMoments(param: params);
  }
}
