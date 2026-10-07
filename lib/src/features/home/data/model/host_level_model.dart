import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/domain/entities/host_level_entity.dart';

class RewardModel extends RewardEntity {
  const RewardModel({
    required super.name,
    required super.image,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      name: parseValue<String>(json['name'], ''),
      image: parseValue<String>(json['image'], ''),
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
    required super.id,
    required super.stage,
    required super.name,
    required super.img,
    required super.diamond,
    required super.isPickedStage,
    required super.remaining,
    required super.progress,
    required super.rewards,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      id: parseValue<int>(json['id'], 0),
      stage: parseValue<int>(json['level'], 0),
      name: parseValue<String>(json['name'], ''),
      img: parseValue<String>(json['img'], ''),
      diamond: parseValue<num>(json['diamond'], 0),
      isPickedStage: parseValue<bool>(json['picked_level'], false),
      remaining: parseValue<num>(json['remaining'], 0),
      progress: parseValue<num>(json['progress'], 0),
      rewards: (json['rewards'] is List ? json['rewards'] as List : const [])
              .whereType<Map<String, dynamic>>()
              .map((element) => RewardModel.fromJson(element))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'level': stage,
      'name': name,
      'img': img,
      'diamond': diamond,
      'picked_level': isPickedStage,
      'remaining': remaining,
      'progress': progress,
      'rewards':
          rewards?.map((element) => (element as RewardModel).toJson()).toList(),
    };
  }
}

class UserModel extends UserEntity {
  const UserModel({
    required super.name,
    required super.image,
    required super.currentStage,
    required super.nextStage,
    required super.lastStage,
    required super.diamonds,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: parseValue<String>(json['name'], ''),
      image: parseValue<String>(json['image'], ''),
      currentStage: parseValue<int>(json['current_level'], 0),
      nextStage: parseValue<int>(json['next_level'], 0),
      lastStage: parseValue<int>(json['last_level'], 0),
      diamonds: parseValue<String>(json['diamonds'], "0"),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'current_level': currentStage,
      'next_level': nextStage,
      'last_level': lastStage,
      'diamonds': diamonds,
    };
  }
}

class HostLevelsModel extends HostLevelsEntity {
  const HostLevelsModel({
    required super.stages,
    required super.roles,
    required super.eventType,
    required super.user,
  });

  factory HostLevelsModel.fromJson(Map<String, dynamic> json) {
    return HostLevelsModel(
      stages: (json['levels'] is List ? json['levels'] as List : const [])
              .whereType<Map<String, dynamic>>()
              .map((element) => LevelModel.fromJson(element))
              .toList(),
      roles: parseValue<String>(json['roles'], ''),
      eventType: parseValue<String>(json['event_type'], ''),
      user: UserModel.fromJson(
          json['user'] is Map<String, dynamic> ? json['user'] : const {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'levels':
          stages?.map((element) => (element as LevelModel).toJson()).toList(),
      'roles': roles,
      'user': (user as UserModel).toJson(),
    };
  }
}
