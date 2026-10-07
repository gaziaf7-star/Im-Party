import 'package:general/src/core/index.dart';
import 'package:general/src/features/moment/moment.dart';

class LikeMomentUseCase
    extends UseCaseWithParams<BaseResponse<String>, String> {
  final BaseMomentRepository baseMomentRepository;
  const LikeMomentUseCase({required this.baseMomentRepository});

  @override
  ResultFuture<BaseResponse<String>> call(params) async {
    return await baseMomentRepository.likeMoment(momentId: params);
  }
}
