import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/features/agency/data/model/hosts_agency_dollars_records_model.dart';

import '../../../../core/index.dart';

class HostsAgencyDollarsRecordsUC extends UseCaseWithParams<
    BaseResponse<List<HostsAgencyDollarsRecordsModel>>, FetchHostsAgencyDollarsParam> {
  final AgencyBaseRepository repository;

  const HostsAgencyDollarsRecordsUC({required this.repository});

  @override
  ResultFuture<BaseResponse<List<HostsAgencyDollarsRecordsModel>>> call(
      params) {
    return repository.hostsAgencyDollarsRecord(params);
  }
}
