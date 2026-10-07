import 'package:general/src/features/agency/agency.dart';

import '../../../../core/index.dart';
class ChargeDollarsForUserUC
    extends UseCaseWithParams<BaseResponse<ChargeModel>, ChargeToParam> {
  final AgencyBaseRepository repository;

  const ChargeDollarsForUserUC({required this.repository});

  @override
  ResultFuture<BaseResponse<ChargeModel>> call(params) {
    return repository.chargeDollarsForUsers(params);
  }
}

