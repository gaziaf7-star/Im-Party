import 'package:general/src/core/index.dart';

class GetBadgesEntity extends Equatable {
  final List<AchievementLevelEntity> levels;

  const GetBadgesEntity({
    required this.levels
  });

  @override
  List<Object?> get props => [levels];
}

class AchievementLevelEntity extends Equatable {
  final int id;
  final int achievementId;
  final int? giftId;
  final String target;
  final String image;
  final String validImage;
  final String descriptionAr;
  final String descriptionEn;
  final int enable;
  final String name;

  const AchievementLevelEntity({
    required this.id,
    required this.achievementId,
    this.giftId,
    required this.target,
    required this.image,
    required this.validImage,
    required this.enable,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.name,
  });

  String get description =>
      HiveManager().getData(KeysManager.USER_BOX, KeysManager.LANG_CODE_KEY) ==
              'ar'
          ? descriptionAr
          : descriptionEn;

  @override
  List<Object?> get props => [
        id,
        achievementId,
        giftId,
        target,
        image,
        enable,
        descriptionAr,
        descriptionEn,
        name,
        validImage,
      ];
}
