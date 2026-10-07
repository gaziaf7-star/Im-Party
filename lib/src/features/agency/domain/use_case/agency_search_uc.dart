import 'package:general/src/features/agency/agency.dart';

import '../../../../core/index.dart';

class AgencySearchParam {
  final String id;
  final String? page;

  const AgencySearchParam({required this.id, this.page});
}

class AgencySearchUC
    extends UseCaseWithParams<BaseResponse<AgencySearchModel>,
        AgencySearchParam> {
  final AgencyBaseRepository repository;

  const AgencySearchUC({required this.repository});

  @override
  ResultFuture<BaseResponse<AgencySearchModel>> call(params) {
    return repository.agencySearch(id: params.id, page: params.page);
  }
}

