import 'package:general/src/features/room/domain/entities/room_boom_theme_entity.dart';
import '../../../../core/utils/methods.dart';

class RoomBoomThemeModel extends RoomBoomThemeEntity {
  const RoomBoomThemeModel({
    required super.levels,
    required super.progressAnimations,
  });

  Map<String, dynamic> toJson() {
    return {
      'levels': (levels as List<RoomBoomLevelThemeModel>)
          .map((e) => e.toJson())
          .toList(),
      'progress_animations':
          (progressAnimations as List<RoomBoomProgressAnimationModel>)
              .map((e) => e.toJson())
              .toList(),
    };
  }

  factory RoomBoomThemeModel.fromJson(Map<String, dynamic> json) {
    return RoomBoomThemeModel(
      levels: json['levels'] is List
          ? List<RoomBoomLevelThemeModel>.from(
              (json['levels'] as List).whereType<Map<String, dynamic>>().map(
                (element) => RoomBoomLevelThemeModel.fromJson(element),
              ),
            )
          : <RoomBoomLevelThemeModel>[],
      progressAnimations: json['progress_animations'] is List
          ? List<RoomBoomProgressAnimationModel>.from(
              (json['progress_animations'] as List).whereType<Map<String, dynamic>>().map(
                (element) => RoomBoomProgressAnimationModel.fromJson(element),
              ),
            )
          : <RoomBoomProgressAnimationModel>[],
    );
  }
}

class RoomBoomLevelThemeModel extends RoomBoomLevelThemeEntity {
  const RoomBoomLevelThemeModel({
    required super.level,
    required super.background,
    required super.boom,
  });

  factory RoomBoomLevelThemeModel.fromJson(Map<String, dynamic> json) {
    return RoomBoomLevelThemeModel(
      level: parseValue<int>(json['level'], 0),
      background: json['background'] is Map<String, dynamic>
          ? RoomBoomAssetModel.fromJson(json['background'])
          : const RoomBoomAssetModel(type: '', url: ''),
      boom: json['boom'] is Map<String, dynamic>
          ? RoomBoomAssetModel.fromJson(json['boom'])
          : const RoomBoomAssetModel(type: '', url: ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'background': (background as RoomBoomAssetModel).toJson(),
      'boom': (boom as RoomBoomAssetModel).toJson(),
    };
  }
}

class RoomBoomAssetModel extends RoomBoomAssetEntity {
  const RoomBoomAssetModel({
    required super.type,
    required super.url,
  });

  factory RoomBoomAssetModel.fromJson(Map<String, dynamic> json) {
    return RoomBoomAssetModel(
      type: parseValue<String>(json['type'], ''),
      url: parseValue<String>(json['url'], ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'url': url,
    };
  }
}

class RoomBoomProgressAnimationModel extends RoomBoomProgressAnimationEntity {
  const RoomBoomProgressAnimationModel({
    required super.percentage,
    required super.image,
    required super.imageType,
  });

  factory RoomBoomProgressAnimationModel.fromJson(Map<String, dynamic> json) {
    return RoomBoomProgressAnimationModel(
      percentage: parseValue<int>(json['percentage'], 0),
      image: parseValue<String>(json['image'], ''),
      imageType: parseValue<String>(json['image_type'], ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'percentage': percentage,
      'image': image,
      'image_type': imageType,
    };
  }
}
