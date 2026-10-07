
import 'package:general/src/features/agency/agency.dart';
import '../../../../core/index.dart';
class GetShippingAgentRequestsUC
    extends UseCaseWithParams<BaseResponse<List<ShippingAgentRequestModel>>,int> {
  final AgencyBaseRepository repository;

  const GetShippingAgentRequestsUC({required this.repository});

  @override
  ResultFuture<BaseResponse<List<ShippingAgentRequestModel>>> call(params) {
    return repository.fetchShippingAgentRequests(params);
  }
}

