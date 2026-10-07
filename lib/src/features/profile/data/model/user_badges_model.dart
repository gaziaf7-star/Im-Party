import 'package:general/src/features/profile/domain/entities/user_badges_entity.dart';
import '../../../../core/utils/methods.dart';

class UserBadgesModel extends UserBadgesEntity {
  const UserBadgesModel({
    required super.top,
    required super.regular,
  });

  factory UserBadgesModel.fromJson(Map<String, dynamic> json) {
    return UserBadgesModel(
      top: List<BadgeModel>.from(
        (json["top"] is List ? json["top"] as List : const [])
            .whereType<Map<String, dynamic>>()
            .map((e) => BadgeModel.fromJson(e)),
      ),
      regular: List<BadgeModel>.from(
        (json["regular"] is List ? json["regular"] as List : const [])
            .whereType<Map<String, dynamic>>()
            .map((e) => BadgeModel.fromJson(e)),
      ),
    );
  }
}

class BadgeModel extends BadgeEntity {
  const BadgeModel({
    required super.image,
    required super.imageType,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      image: parseValue<String>(json["image"], ""),
      imageType: parseValue<String>(json["image_type"], ""),
    );
  }
}
