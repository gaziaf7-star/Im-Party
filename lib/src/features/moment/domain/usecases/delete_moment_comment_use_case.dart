import 'package:general/src/core/index.dart';
import 'package:general/src/features/moment/moment.dart';

class DeleteMomentCommentUseCase extends UseCaseWithParams<BaseResponse<String>,
    DeleteMomentCommentPrameter> {
  final BaseMomentRepository baseMomentRepository;
  const DeleteMomentCommentUseCase({required this.baseMomentRepository});

  @override
  ResultFuture<BaseResponse<String>> call(params) async {
    return await baseMomentRepository.deleteMomentComment(data: params);
  }
}
