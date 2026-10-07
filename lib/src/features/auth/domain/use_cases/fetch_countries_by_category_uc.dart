import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';

class FetchCountriesByCategoryUc
    extends UseCaseWithParams<BaseResponse<List<CountryModel>>, int> {
  final BaseAuthenticationRepository _repo;

  const FetchCountriesByCategoryUc(this._repo);

  @override
  ResultFuture<BaseResponse<List<CountryModel>>> call(int categoryId) async {
    return await _repo.fetchCountriesByCategory(categoryId);
  }
}
