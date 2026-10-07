import 'package:general/src/features/agency/agency.dart';

import '../../../../core/index.dart';
class AgencyRequestsUC
    extends UseCaseWithParams<BaseResponse<List<ShowAgencyRequestModel>>,String> {
  final AgencyBaseRepository repository;

  const AgencyRequestsUC({required this.repository});

  @override
  ResultFuture<BaseResponse<List<ShowAgencyRequestModel>>> call(params) {
    return repository.agencyRequests(params);
  }
}


