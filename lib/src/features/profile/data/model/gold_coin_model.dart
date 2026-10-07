import 'package:general/src/features/profile/domain/entities/gold_coins_entity.dart';

import '../../../../core/utils/methods.dart';

class GoldCoinsModel extends GoldCoinsEntity {
  const GoldCoinsModel(
      {required super.id, required super.coin, required super.usd});
  factory GoldCoinsModel.fromJson(Map<String, dynamic> json) {
    return GoldCoinsModel(
      coin: parseValue<int>(json['coin'], 0),
      id: parseValue<int>(json['id'], 0),
      usd: parseValue<String>(json['usd'], ''),
    );
  }
}
