

import 'package:general/src/features/agency/agency.dart';
import '../../../../core/index.dart';class MakeShippingAgentRequestActionUC
    extends UseCaseWithParams<BaseResponse<String>,ShippingAgentRequestActionParam> {
  final AgencyBaseRepository repository;

  const MakeShippingAgentRequestActionUC({required this.repository});

  @override
  ResultFuture<BaseResponse<String>> call(params) {
    return repository.makeShippingAgentRequestAction(params);
  }
}




