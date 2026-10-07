import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/profile.dart';

import '../../data/model/exchange_settings_model.dart';

class GetExchangeSettingsUC extends UseCaseWithoutParams<ExchangeSettingsModel> {
  final ProfileBaseRepository _repo;
  GetExchangeSettingsUC(this._repo);

  @override
  ResultFuture<ExchangeSettingsModel> call() async {
    return _repo.getExchangeSettings();
  }
}