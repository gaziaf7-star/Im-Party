import 'package:general/src/features/agency/agency.dart';

import '../../../../core/index.dart';
class AgencyMemberUC
    extends UseCaseWithParams<BaseResponse<List<AgencyMemberModel>>,String> {
  final AgencyBaseRepository repository;

  const AgencyMemberUC({required this.repository});

  @override
  ResultFuture<BaseResponse<List<AgencyMemberModel>>> call(params) {
    return repository.agencyMember(params);
  }
}

