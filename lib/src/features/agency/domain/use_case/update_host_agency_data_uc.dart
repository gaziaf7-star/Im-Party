


import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/features/agency/data/model/information_agency_model.dart';
import '../../../../core/index.dart';



class UpdateHostAgencyDataUc extends UseCaseWithParams<
    BaseResponse<InformationAgencyModel>, UpdateAgencyParam> {
  final AgencyBaseRepository repository;

  const UpdateHostAgencyDataUc(
      this.repository);

  @override
  ResultFuture<BaseResponse<InformationAgencyModel>> call(params) {
    return repository.updateAgencyData(params);
  }
}
