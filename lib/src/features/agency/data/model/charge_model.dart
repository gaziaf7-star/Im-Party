import 'package:general/src/features/agency/agency.dart';
import '../../../../../reels_viewer/reels_viewer.dart';

class ChargeModel extends ChargeEntity {
  const ChargeModel({
    super.coins,
    super.usd,
  });

  factory ChargeModel.fromJson(Map<String, dynamic> json) {
    return ChargeModel(
      coins:parseValue<String>(json['coins']?.toString(),'') ,
      usd: parseValue<String>(json['usd'],''),
    );
  }
}
