import 'package:general/src/features/profile/domain/entities/get_user_badges_entity.dart';

import '../../../../core/utils/methods.dart';

class GetBadgesModel extends GetBadgesEntity {
  const GetBadgesModel({required super.levels});

  factory GetBadgesModel.fromJson(Map<String, dynamic> json) {
    return GetBadgesModel(
      levels: List<AchievementLevelModel>.from(
        (json["levels"] is List ? json["levels"] as List : const [])
            .whereType<Map<String, dynamic>>()
            .map(
              (element) => AchievementLevelModel.fromJson(element),
            ),
      ),
    );
  }
}

class AchievementLevelModel extends AchievementLevelEntity {
  const AchievementLevelModel({
    required super.id,
    required super.achievementId,
    super.giftId,
    required super.target,
    required super.image,
    required super.enable,
    required super.name,
    required super.descriptionAr,
    required super.descriptionEn,
    required super.validImage,
  });

  factory AchievementLevelModel.fromJson(Map<String, dynamic> json) {
    return AchievementLevelModel(
      id: parseValue<int>(json["id"], 0),
      image: parseValue<String>(json["image"], ''),
      validImage: parseValue<String>(json["valid_image"], ''),
      achievementId: parseValue<int>(json["achievement_id"], 0),
      target: parseValue<String>(json["target"], ''),
      enable: parseValue<int>(json["enable"], 0),
      descriptionAr: parseValue<String>(json["description"], ''),
      descriptionEn: parseValue<String>(json["description_en"], ''),
      name: parseValue<String>(json['name'], ''),
      giftId: parseValue<int>(json['gift_id'], 0),
    );
  }
}
