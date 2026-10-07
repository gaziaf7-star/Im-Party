import 'package:general/src/core/index.dart';
import 'package:general/src/features/moment/moment.dart';

class FetchMomentCommentUseCase extends UseCaseWithParams<
    BaseResponse<List<MomentCommentsModel>>, GetMomentCommentPrameter> {
  final BaseMomentRepository baseMomentRepository;
  const FetchMomentCommentUseCase({required this.baseMomentRepository});

  @override
  ResultFuture<BaseResponse<List<MomentCommentsModel>>> call(params) async {
    return await baseMomentRepository.fetchMomentComment(param: params);
  }
}
