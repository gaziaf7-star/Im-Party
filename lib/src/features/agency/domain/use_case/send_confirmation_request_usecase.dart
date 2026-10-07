
import 'package:general/src/features/agency/agency.dart';
import '../../../../core/index.dart';
class SendTransferConfirmationRequestUC extends UseCaseWithParams<
    BaseResponse<String>, SendConfirmationRequestParam> {
  final AgencyBaseRepository repository;

  const SendTransferConfirmationRequestUC(
      {required this.repository});

  @override
  ResultFuture<BaseResponse<String>> call(params) {
    return repository.sendConfirmationRequest(params);
  }
}
