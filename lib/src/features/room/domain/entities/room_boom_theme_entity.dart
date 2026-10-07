import 'package:equatable/equatable.dart';

class RoomBoomThemeEntity extends Equatable {
  final List<RoomBoomLevelThemeEntity> levels;
  final List<RoomBoomProgressAnimationEntity> progressAnimations;

  const RoomBoomThemeEntity({
    required this.levels,
    required this.progressAnimations,
  });

  @override
  List<Object?> get props => [levels, progressAnimations];
}

class RoomBoomLevelThemeEntity extends Equatable {
  final int level;
  final RoomBoomAssetEntity background;
  final RoomBoomAssetEntity boom;

  const RoomBoomLevelThemeEntity({
    required this.level,
    required this.background,
    required this.boom,
  });

  @override
  List<Object?> get props => [level, background, boom];
}

class RoomBoomAssetEntity extends Equatable {
  final String type;
  final String url;

  const RoomBoomAssetEntity({
    required this.type,
    required this.url,
  });

  @override
  List<Object?> get props => [type, url];
}

class RoomBoomProgressAnimationEntity extends Equatable {
  final int percentage;
  final String image;
  final String imageType;

  const RoomBoomProgressAnimationEntity({
    required this.percentage,
    required this.image,
    required this.imageType,
  });

  @override
  List<Object?> get props => [percentage, image, imageType];
}
