
import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/features/agency/data/model/information_agency_model.dart';
import '../../../../core/index.dart';
class InformationAgencyUC
    extends UseCaseWithParams<BaseResponse<InformationAgencyModel>,AgencyHistoryParam> {
  final AgencyBaseRepository repository;

  const InformationAgencyUC({required this.repository});

  @override
  ResultFuture<BaseResponse<InformationAgencyModel>> call(params) {
    return repository.informationAgency(params);
  }
}

