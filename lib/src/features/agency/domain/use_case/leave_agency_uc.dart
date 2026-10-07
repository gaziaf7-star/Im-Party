
import 'package:general/src/features/agency/agency.dart';
import '../../../../core/index.dart';

class LeaveAgencyUC extends UseCaseWithoutParams<BaseResponse<String>> {
  final AgencyBaseRepository repository;

  const LeaveAgencyUC({required this.repository});
  @override
  ResultFuture<BaseResponse<String>> call() {
    return repository.leaveAgency();
  }
}


