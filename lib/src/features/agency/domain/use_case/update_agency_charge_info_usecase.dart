
import 'package:general/src/features/agency/agency.dart';
import '../../../../core/index.dart';
class UpdateAgencyInfoUC extends UseCaseWithParams<
    BaseResponse<ChargeAgencyInfoModel>, UpdateChargeAgencyParam> {
  final AgencyBaseRepository repository;

  const UpdateAgencyInfoUC(
      {required this.repository});

  @override
  ResultFuture<BaseResponse<ChargeAgencyInfoModel>> call(params) {
    return repository.updateChargeAgency(params);
  }
}
