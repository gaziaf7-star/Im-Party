import 'package:general/src/features/room/domain/entities/get_config_key_entity.dart';

import '../../../../core/utils/methods.dart';

class GetConfigKeyModel extends GetConfigKeyEntity {
  const GetConfigKeyModel({
    super.specialBar,
    super.wapelNum,
    super.userCoin,
    super.userCoinString,
    super.familyPrice,
  });

  factory GetConfigKeyModel.fromJson(Map<String, dynamic> json) {
    return GetConfigKeyModel(
      specialBar: parseValue<String>(json['special_bar_coin'], ''),
      wapelNum: parseValue<int>(json['wapel_num'], 0),
      userCoin: parseValue<int>(json['user_coins'], 0),
      userCoinString: parseValue<String>(json['user_coins_string'], '0'),
      familyPrice: parseValue<String>(json['family_price'], '0'),
    );
  }


  @override
  List<Object?> get props => [specialBar];
}
