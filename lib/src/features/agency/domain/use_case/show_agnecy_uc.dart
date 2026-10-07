
import 'package:general/src/features/agency/agency.dart';
import '../../../../core/index.dart';
class ShowAgencyUC
    extends UseCaseWithParams<BaseResponse<ShowAgencyModel>,int?> {
  final AgencyBaseRepository repository;

  const ShowAgencyUC({required this.repository});

  @override
  ResultFuture<BaseResponse<ShowAgencyModel>> call(params) {
    return repository.showAgency(params);
  }
}


