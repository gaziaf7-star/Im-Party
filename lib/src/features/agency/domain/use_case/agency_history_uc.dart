import 'package:general/src/features/agency/agency.dart';

import '../../../../core/index.dart';

class AgencyHistoryUC extends UseCaseWithParams<
    BaseResponse<List<AgencyHistoryModel>>, AgencyHistoryParam> {
  final AgencyBaseRepository repository;

  const AgencyHistoryUC({required this.repository});

  @override
  ResultFuture<BaseResponse<List<AgencyHistoryModel>>> call(params) {
    return repository.fetchAgencyHistory(params);
  }
}

class AgencyMemberChargesHistoryUC extends UseCaseWithParams<
    BaseResponse<List<AgencyMemberChargesHistoryModel>>, String> {
  final AgencyBaseRepository repository;

  const AgencyMemberChargesHistoryUC({required this.repository});

  @override
  ResultFuture<BaseResponse<List<AgencyMemberChargesHistoryModel>>> call(params) {
    return repository.agencyMemberChargesHistory(params);
  }
}
