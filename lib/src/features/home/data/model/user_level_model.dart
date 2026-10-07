import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/domain/entities/user_level_entity.dart';

class UserLevelModel extends UserLevelEntity {
  const UserLevelModel({required super.name, required super.image});

  factory UserLevelModel.fromJson(Map<String, dynamic> json) {
    return UserLevelModel(
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
    };
  }
}

class LevelModel extends LevelEntity {
  const LevelModel({
    required super.nextLevel,
    required super.currentLevel,
    required super.nextLevelImage,
    required super.diamonds,
    required super.remaining,
    required super.progress,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      nextLevel: parseValue<int>(json['next_level'], 0),
      currentLevel: parseValue<int>(json['current_level'], 0),
      nextLevelImage: parseValue<String>(json['next_level_image'], ''),
      diamonds: parseValue<String>(json['diamonds'], "0"),
      remaining: parseValue<int>(json['remaining'], 0),
      progress: parseValue<double>(json['progress'], 0.0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'next_level': nextLevel,
      'next_level_image': nextLevelImage,
      'diamonds': diamonds,
      'remaining': remaining,
      'progress': progress,
    };
  }
}

class DataModel extends DataEntity {
  const DataModel({required super.user, required super.level});

  factory DataModel.fromJson(Map<String, dynamic> json) {
    return DataModel(
      user: UserLevelModel.fromJson(
          json['user'] is Map<String, dynamic> ? json['user'] : {}),
      level: LevelModel.fromJson(
          json['level'] is Map<String, dynamic> ? json['level'] : {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': (user as UserLevelModel).toJson(),
      'level': (level as LevelModel).toJson(),
    };
  }
}
