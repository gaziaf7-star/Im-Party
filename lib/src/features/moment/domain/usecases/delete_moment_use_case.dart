import 'package:general/src/core/index.dart';
import 'package:general/src/features/moment/moment.dart';

class DeleteMomentUseCase
    extends UseCaseWithParams<BaseResponse<int>, String> {
  final BaseMomentRepository baseMomentRepository;
  const DeleteMomentUseCase({required this.baseMomentRepository});

  @override
  ResultFuture<BaseResponse<int>> call(params) async {
    return await baseMomentRepository.deleteMoment(momentId: params);
  }
}
