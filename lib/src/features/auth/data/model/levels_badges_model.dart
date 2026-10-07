import 'package:general/src/core/index.dart';

import '../../../profile/domain/entities/level_badges_entity.dart';

class LevelsBadgesModel extends LevelBadgesEntity {
  const LevelsBadgesModel({
    super.minlevel,
    super.maxlevel,
    super.badge,
  });

  factory LevelsBadgesModel.fromJson(Map<String, dynamic> json) {
    return LevelsBadgesModel(
      minlevel: parseValue<int>(json['minlevel'], 0),
      maxlevel: parseValue<int>(json['maxlevel'], 0),
      badge: parseValue<String>(json['badge'], ''),
    );
  }

  // Converts the model instance back to JSON
  Map<String, dynamic> toJson() {
    return {
      'data': [
        {
          'minlevel': minlevel,
          'maxlevel': maxlevel,
          'badge': badge,
        }
      ],
    };
  }
}
