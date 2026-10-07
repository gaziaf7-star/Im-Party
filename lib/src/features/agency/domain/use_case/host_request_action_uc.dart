
import 'package:general/src/features/agency/agency.dart';
import '../../../../core/index.dart';
class HostRequestActionUC
    extends UseCaseWithParams<BaseResponse<String>,AgencyRequestsActionParam> {
  final AgencyBaseRepository repository;

  const HostRequestActionUC({required this.repository});

  @override
  ResultFuture<BaseResponse<String>> call(params) {
    return repository.hostRequestAction(params);
  }
}


