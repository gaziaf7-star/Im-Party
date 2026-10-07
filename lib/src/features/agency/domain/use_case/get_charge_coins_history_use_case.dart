import 'package:general/src/features/agency/agency.dart';

import '../../../../core/index.dart';
class GetChargeCoinsHistoryUC extends UseCaseWithoutParams<
    BaseResponse<List<UerChargeCoinsHistoryModel>>> {
  final AgencyBaseRepository repository;

  GetChargeCoinsHistoryUC({required this.repository});

  @override
  ResultFuture<BaseResponse<List<UerChargeCoinsHistoryModel>>> call() {
    return repository.fetchChargeCoinsHistory();
  }
}
