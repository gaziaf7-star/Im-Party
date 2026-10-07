import 'package:general/src/features/auth/data/model/charge_level_model.dart';
import 'package:general/src/features/auth/data/model/room_level_model.dart';
import 'package:general/src/features/auth/domain/entities/user_levels_entity.dart';

import '../../auth.dart';

class UserLevelsModel extends UserLevelsEntity {
  const UserLevelsModel({
    super.level,
    super.chargeLevel,
    super.roomLevel,
  });

  factory UserLevelsModel.fromJson(Map<String, dynamic> json) =>
      UserLevelsModel(
        chargeLevel: json["charge_level"] is Map<String, dynamic>
            ? ChargeLevelModel.fromJson(json["charge_level"])
            : null,
        level: json["gift_level"] is Map<String, dynamic>
            ? LevelModel.fromJson(json["gift_level"])
            : null,
        roomLevel: json["room_level"] is Map<String, dynamic>
            ? RoomLevelModel.fromJson(json["room_level"])
            : null,
      );
}
