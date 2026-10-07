
import 'package:general/src/features/agency/agency.dart';
import '../../../../core/index.dart';
class SendWithdrawalRequestUC extends UseCaseWithParams<
    BaseResponse<String>, SendWithdrawalRequestParam> {
  final AgencyBaseRepository repository;

  const SendWithdrawalRequestUC({required this.repository});

  @override
  ResultFuture<BaseResponse<String>> call(params) {
    return repository.sendWithdrawelRequest(params);
  }
}
