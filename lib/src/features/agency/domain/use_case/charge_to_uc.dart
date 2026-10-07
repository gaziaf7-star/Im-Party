import 'package:general/src/features/agency/agency.dart';

import '../../../../core/index.dart';
class ChargeToUC
    extends UseCaseWithParams<BaseResponse<ChargeModel>, ChargeToParam> {
  final AgencyBaseRepository repository;

  const ChargeToUC({required this.repository});

  @override
  ResultFuture<BaseResponse<ChargeModel>> call(params) {
    return repository.chargeTo(params);
  }
}
