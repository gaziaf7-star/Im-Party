import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/agency.dart';
class MakeUserAdminUC extends UseCaseWithParams<BaseResponse<String>, AgencyRequestsActionParam> {
  final AgencyBaseRepository repository;

  const MakeUserAdminUC({required this.repository});

  @override
  ResultFuture<BaseResponse<String>> call(params) {
    return repository.makeUserAdmin(params);
  }
}
