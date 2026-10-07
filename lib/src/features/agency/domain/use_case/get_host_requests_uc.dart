import 'package:general/src/features/agency/agency.dart';

import '../../../../core/index.dart';
class GetHostRequestsUC
    extends UseCaseWithParams<BaseResponse<List<HostRequestsModel>>,String> {
  final AgencyBaseRepository repository;

  const GetHostRequestsUC({required this.repository});

  @override
  ResultFuture<BaseResponse<List<HostRequestsModel>>> call(params) {
    return repository.fetchHostRequests(params);
  }
}

