import 'package:general/src/features/agency/agency.dart';

import '../../../../core/index.dart';
class GetChargeAgencyDetailsUC
    extends UseCaseWithParams<BaseResponse<List<DetailsChargeAgencyModel>>,FetchChargeAgencyDetailsParam> {
  final AgencyBaseRepository repository;

  const GetChargeAgencyDetailsUC({required this.repository});

  @override
  ResultFuture<BaseResponse<List<DetailsChargeAgencyModel>>> call(params) {
    return repository.fetchChargeAgencyDetails(params);
  }
}


