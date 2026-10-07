import 'package:equatable/equatable.dart';
import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/auth/domain/entities/charge_level_entity.dart';
import 'package:general/src/features/auth/domain/entities/room_level_entity.dart';


class UserLevelsEntity extends Equatable {
  final LevelEntity? level;
  final ChargeLevelEntity? chargeLevel;
  final RoomLevelEntity? roomLevel;

  const UserLevelsEntity({
    this.chargeLevel,
    this.level,
    this.roomLevel,
  });

  @override
  List<Object?> get props => [level, chargeLevel, roomLevel];
}

