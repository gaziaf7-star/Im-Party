
import 'package:general/src/features/agency/agency.dart';
import '../../../../core/index.dart';
class JoinToAgencyUC
    extends UseCaseWithParams<BaseResponse<String>, JoinAgencyParam> {
  final AgencyBaseRepository repository;

  const JoinToAgencyUC({required this.repository});

  @override
  ResultFuture<BaseResponse<String>> call(params) {
    return repository.joinToAgency(params);
  }
}
