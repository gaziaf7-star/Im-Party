import 'package:general/src/core/index.dart';
import 'package:general/src/features/moment/moment.dart';

class AddMomentCommentUseCase
    extends UseCaseWithParams<BaseResponse<String>, AddMomentCommentPrameter> {
  final BaseMomentRepository baseMomentRepository;
  const AddMomentCommentUseCase({required this.baseMomentRepository});

  @override
  ResultFuture<BaseResponse<String>> call(params) async {
    return await baseMomentRepository.addMomentComment(data: params);
  }
}
