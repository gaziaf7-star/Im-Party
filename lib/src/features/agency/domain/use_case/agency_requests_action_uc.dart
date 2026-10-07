import 'package:general/src/features/agency/agency.dart';

import '../../../../core/index.dart';
class AgencyRequestsActionUC
    extends UseCaseWithParams<BaseResponse<String>,AgencyRequestsActionParam> {
  final AgencyBaseRepository repository;

  const AgencyRequestsActionUC({required this.repository});

  @override
  ResultFuture<BaseResponse<String>> call(params) {
    return repository.agencyRequestsAction(params);
  }
}

