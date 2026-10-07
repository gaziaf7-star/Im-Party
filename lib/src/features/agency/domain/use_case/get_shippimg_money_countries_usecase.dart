


import 'package:general/src/features/agency/agency.dart';
import '../../../../core/index.dart';
import '../../../auth/data/model/country_model.dart';
class GetShippingMoneyCountriesUC
    extends UseCaseWithoutParams<BaseResponse<List<CountryModel>>> {
  final AgencyBaseRepository repository;

  const GetShippingMoneyCountriesUC({required this.repository});

  @override
  ResultFuture<BaseResponse<List<CountryModel>>> call() {
    return repository.fetchShippingAgentCountries();
  }
}


