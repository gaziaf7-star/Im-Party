import 'package:general/src/features/agency/data/model/search_user_agency_model.dart';
import 'package:general/src/features/agency/domain/base_repository/agency_base_repository.dart';

import '../../../../core/index.dart';

class SearchUserAgencyUc extends UseCaseWithParams<BaseResponse<MainResponseModel>,SearchUserAgencyParam> {
  final AgencyBaseRepository _repo;
  SearchUserAgencyUc(this._repo);
  @override
  ResultFuture <BaseResponse<MainResponseModel>> call(params) async {
    return await _repo.searchUserAgency(params);
  }
}
