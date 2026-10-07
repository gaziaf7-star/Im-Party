import 'package:general/src/features/profile/domain/entities/exchange_settings_entity.dart';
import '../../../../core/utils/methods.dart';

class ExchangeSettingsModel extends ExchangeSettingsEntity {
  const ExchangeSettingsModel({required super.rate, required super.diamonds});

  factory ExchangeSettingsModel.fromJson(Map<String, dynamic> json) {
    // The backend's exact field names for this v2 settings endpoint weren't
    // part of the spec shared for this feature (only "exchange percentage +
    // user's current diamond info" was described), and some endpoints in
    // this app wrap their payload in a `data` object while others don't --
    // so this checks both shapes and accepts several likely key spellings
    // rather than assuming one exact response format.
    //
    // Confirmed live response shape (GET /api/exchange/v2/list):
    // {"exchange_coin_percentage": 50, "usr_diamond": 10029000} -- neither
    // key was in the original guess list, so `rate`/`diamonds` always fell
    // through to their defaults (1 / 0), which is why the app always showed
    // a flat "1 Diamond = 1 Coin" no matter what the server actually sent.
    final Map<String, dynamic> data =
    (json['data'] is Map) ? Map<String, dynamic>.from(json['data']) : json;
    // The server ships this as a PERCENTAGE (50 == 50%, i.e. 2 diamonds ->
    // 1 coin), not a direct per-diamond multiplier -- divide by 100 here so
    // every caller of `rate` can just do `diamonds * rate` and get coins.
    final num percentage = parseValue<num>(
      data['exchange_coin_percentage'] ??
          data['percentage'] ??
          data['rate'] ??
          data['exchange_rate'] ??
          data['exchange_percentage'] ??
          data['coin_per_diamond'],
      100,
    );
    return ExchangeSettingsModel(
      rate: percentage / 100,
      diamonds: parseValue<num>(
        data['usr_diamond'] ??
            data['diamonds'] ??
            data['diamond'] ??
            data['my_diamonds'] ??
            data['user_diamonds'] ??
            data['current_diamonds'],
        0,
      ),
    );
  }
}