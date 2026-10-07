import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';

class FetchCountryCategoriesUc
    extends UseCaseWithoutParams<BaseResponse<List<CountryCategoryModel>>> {
  final BaseAuthenticationRepository _repo;

  const FetchCountryCategoriesUc(this._repo);

  @override
  ResultFuture<BaseResponse<List<CountryCategoryModel>>> call() async {
    return await _repo.fetchCountryCategories();
  }
}
