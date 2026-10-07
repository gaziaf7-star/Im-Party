import 'package:general/src/features/agency/agency.dart';

import '../../../../core/index.dart';
class GetAgencyInfoUC
    extends UseCaseWithParams<BaseResponse<ChargeAgencyInfoModel>,int? > {
  final AgencyBaseRepository repository;

  const GetAgencyInfoUC({required this.repository});

  @override
  ResultFuture<BaseResponse<ChargeAgencyInfoModel>> call(int? params) {
    return repository.fetchChargeAgency(params);
  }
}


