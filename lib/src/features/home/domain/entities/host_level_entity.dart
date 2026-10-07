import 'package:equatable/equatable.dart';

class RewardEntity extends Equatable {
  final String? name;
  final String? image;

  const RewardEntity({
    this.name,
    this.image,
  });

  @override
  List<Object?> get props => [name, image];
}

class LevelEntity extends Equatable {
  final int? id;
  final int? stage;
  final String? name;
  final String? img;
  final num? diamond;
  final bool? isPickedStage;
  final num? remaining;
  final num? progress;
  final List<RewardEntity>? rewards;

  const LevelEntity({
    this.id,
    this.stage,
    this.name,
    this.img,
    this.diamond,
    this.isPickedStage,
    this.remaining,
    this.progress,
    this.rewards,
  });

  @override
  List<Object?> get props => [
        id,
        stage,
        name,
        img,
        diamond,
        isPickedStage,
        remaining,
        progress,
        rewards,
      ];
}

class UserEntity extends Equatable {
  final String? name;
  final String? image;
  final int? currentStage;
  final int? nextStage;
  final int? lastStage;
  final String? diamonds;

  const UserEntity({
    this.name,
    this.image,
    this.currentStage,
    this.nextStage,
    this.lastStage,
    this.diamonds,
  });

  @override
  List<Object?> get props => [
        name,
        image,
        currentStage,
        nextStage,
        lastStage,
        diamonds,
      ];
}

class HostLevelsEntity extends Equatable {
  final List<LevelEntity>? stages;
  final String? roles;
  final String? eventType;
  final UserEntity? user;

  const HostLevelsEntity({
    this.stages,
    this.roles,
    this.eventType,
    this.user,
  });

  @override
  List<Object?> get props => [stages, eventType, roles, user];
}
