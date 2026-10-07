import 'package:general/src/features/agency/agency.dart';

import '../../../../core/index.dart';
class ChargeCoinForUserUC
    extends UseCaseWithParams<String, ChargeToParam> {
  final AgencyBaseRepository repository;

  const ChargeCoinForUserUC({required this.repository});

  @override
  ResultFuture<String> call(params) {
    return repository.chargeCoinForUsers(params);
  }
}


