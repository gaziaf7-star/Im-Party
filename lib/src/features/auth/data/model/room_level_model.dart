import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/domain/entities/room_level_entity.dart';

class RoomLevelModel extends RoomLevelEntity {
  const RoomLevelModel({
    super.currentLevel,
    super.currentExp,
    super.currentImg,
    super.nextLevel,
    super.nextExp,
    super.nextImg,
    super.remaining,
    super.progress,
  });

  factory RoomLevelModel.fromJson(Map<String, dynamic> map) {
    return RoomLevelModel(
      currentLevel: parseValue<int>(map['current_level'], 0),
      currentExp: parseValue<int>(map['current_exp'], 0),
      currentImg: parseValue<String>(map['current_img'], ''),
      nextLevel: parseValue<int>(map['next_level'], 0),
      nextExp: parseValue<int>(map['next_exp'], 0),
      nextImg: parseValue<String>(map['next_img'], ''),
      remaining: parseValue<dynamic>(map['remaining'], null),
      progress: parseValue<num>(map['progress'], 0),
    );
  }

  RoomLevelEntity toEntity() {
    return RoomLevelEntity(
      currentLevel: currentLevel,
      currentExp: currentExp,
      currentImg: currentImg,
      nextLevel: nextLevel,
      nextExp: nextExp,
      nextImg: nextImg,
      remaining: remaining,
      progress: progress,
    );
  }
}
