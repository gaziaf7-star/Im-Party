import 'package:general/src/features/agency/agency.dart';

import '../../../../core/index.dart';
class AgencyHostReportUC
    extends UseCaseWithParams<BaseResponse<AgencyHostReportModel>,AgencyHistoryParam> {
  final AgencyBaseRepository repository;

  const AgencyHostReportUC({required this.repository});

  @override
  ResultFuture<BaseResponse<AgencyHostReportModel>> call(params) {
    return repository.agencyHostReport(params);
  }
}
