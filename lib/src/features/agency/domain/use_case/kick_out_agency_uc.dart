
import 'package:general/src/features/agency/agency.dart';
import '../../../../core/index.dart';
class KickOutAgencyUC
    extends UseCaseWithParams<BaseResponse<String>,String> {
  final AgencyBaseRepository repository;

  const KickOutAgencyUC({required this.repository});

  @override
  ResultFuture<BaseResponse<String>> call(params) {
    return repository.kickOutAgency(params);
  }
}

