import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/profile.dart';

import '../../data/model/exchange_log_model.dart';

class GetExchangeLogsUC extends UseCaseWithParams<ExchangeLogModel, int> {
  final ProfileBaseRepository _repo;
  GetExchangeLogsUC(this._repo);

  @override
  ResultFuture<ExchangeLogModel> call(int type) async {
    return _repo.getExchangeLogs(type: type);
  }
}