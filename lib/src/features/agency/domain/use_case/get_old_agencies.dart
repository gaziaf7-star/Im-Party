import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/features/agency/data/model/old_agency_model.dart';

import '../../../../core/index.dart';

class GetOldAgenciesUC
    extends UseCaseWithoutParams<BaseResponse<List<OldAgencyModel>>> {
  final AgencyBaseRepository repository;

  const GetOldAgenciesUC({required this.repository});

  @override
  ResultFuture<BaseResponse<List<OldAgencyModel>>> call() {
    return repository.getOldAgenciesIWereIn();
  }
}
