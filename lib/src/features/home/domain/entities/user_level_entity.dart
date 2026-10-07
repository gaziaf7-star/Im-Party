import 'package:equatable/equatable.dart';

class UserLevelEntity extends Equatable {
  final String? name;
  final String? image;

  const UserLevelEntity({
    required this.name,
    required this.image,
  });

  @override
  List<Object?> get props => [name, image];
}

class LevelEntity extends Equatable {
  final int? nextLevel;
  final int? currentLevel;
  final String? nextLevelImage;
  final String? diamonds;
  final int? remaining;
  final double? progress;

  const LevelEntity({
    required this.nextLevel,
    required this.currentLevel,
    required this.nextLevelImage,
    required this.diamonds,
    required this.remaining,
    required this.progress,
  });

  @override
  List<Object?> get props => [
        nextLevel,
        currentLevel,
        nextLevelImage,
        diamonds,
        remaining,
        progress,
      ];
}

class DataEntity extends Equatable {
  final UserLevelEntity user;
  final LevelEntity level;

  const DataEntity({
    required this.user,
    required this.level,
  });

  @override
  List<Object?> get props => [user, level];
}
