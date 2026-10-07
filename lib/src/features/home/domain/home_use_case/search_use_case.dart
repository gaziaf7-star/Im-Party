import 'package:general/src/core/base/base_repository.dart';
import 'package:general/src/core/base/parameters.dart';
import '../../../../core/base/base_response.dart';
import '../../../../core/base/base_use_case.dart';
import '../../home.dart';

class SearchUseCase extends UseCaseWithParams<BaseResponse<SearchModel>,SearchParameter> {
  final BaseHomeRepository _repo;
  SearchUseCase(this._repo);
  @override
  ResultFuture <BaseResponse<SearchModel>> call(params) async {
    return await _repo.search(params.keyWord,params.isFriend,params.page);
  }
}
