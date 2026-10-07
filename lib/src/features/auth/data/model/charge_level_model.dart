import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/domain/entities/charge_level_entity.dart';

class ChargeLevelModel extends ChargeLevelEntity {
  const ChargeLevelModel({
    super.currentLevel,
    super.currentExp,
    super.currentImg,
    super.nextLevel,
    super.nextExp,
    super.nextImg,
    super.remaining,
    super.progress,
  });

  factory ChargeLevelModel.fromJson(Map<String, dynamic> map) {
    return ChargeLevelModel(
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

  ChargeLevelEntity toEntity() {
    return ChargeLevelEntity(
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
