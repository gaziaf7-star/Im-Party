import 'package:general/src/features/agency/agency.dart';

import '../../../../core/index.dart';

class GetShippingAgentsFullDataUC extends UseCaseWithParams<
    BaseResponse<List<ShippingAgentsFullDataModel>>,
    FetchShippingAgentsFullDataModelParam?> {
  final AgencyBaseRepository repository;

  const GetShippingAgentsFullDataUC({required this.repository});

  @override
  ResultFuture<BaseResponse<List<ShippingAgentsFullDataModel>>> call(params) {
    return repository.fetchShippingAgentsFullDataModel(params);
  }
}
