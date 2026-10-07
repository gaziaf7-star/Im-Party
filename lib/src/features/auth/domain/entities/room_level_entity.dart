import 'package:equatable/equatable.dart';

class RoomLevelEntity extends Equatable {
  final int? currentLevel;
  final int? currentExp;
  final String? currentImg;
  final int? nextLevel;
  final int? nextExp;
  final String? nextImg;
  final num? remaining;
  final num? progress;

  const RoomLevelEntity({
    this.currentLevel,
    this.currentExp,
    this.currentImg,
    this.nextLevel,
    this.nextExp,
    this.nextImg,
    this.remaining,
    this.progress,
  });

  @override
  List<Object?> get props => [
        currentLevel,
        currentExp,
        currentImg,
        nextLevel,
        nextExp,
        nextImg,
        remaining,
        progress,
      ];
}
