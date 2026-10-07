


import 'package:general/src/features/agency/agency.dart';
import '../../../../core/index.dart';
class MakeShippingAgentToAdminWithdrawalRequestUC
    extends UseCaseWithParams<BaseResponse<String>,MakeShippingAgentToAdminWithdrawelRequestParam> {
  final AgencyBaseRepository repository;

  const MakeShippingAgentToAdminWithdrawalRequestUC({required this.repository});

  @override
  ResultFuture<BaseResponse<String>> call(params) {
    return repository.makeShippingAgentToAdminWithdrawelRequest(params);
  }
}

