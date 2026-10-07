import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';

class FetchCountriesUc extends UseCaseWithoutParams<BaseResponse<List<CountryModel>>> {
  final BaseAuthenticationRepository _repo;

  const FetchCountriesUc(this._repo);

  @override
  ResultFuture<BaseResponse<List<CountryModel>>> call() async {
    return await _repo.fetchCountries();
  }
}
