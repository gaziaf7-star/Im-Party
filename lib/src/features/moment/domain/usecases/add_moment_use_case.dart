import 'package:general/src/core/index.dart';
import 'package:general/src/features/moment/moment.dart';

class AddMomentUseCase
    extends UseCaseWithParams<BaseResponse<String>, AddMomentParametersUC> {
  final BaseMomentRepository baseMomentRepository;
  const AddMomentUseCase({required this.baseMomentRepository});

  @override
  ResultFuture<BaseResponse<String>> call(params) async {
    return await baseMomentRepository.addMomnet(param: params);
  }
}
