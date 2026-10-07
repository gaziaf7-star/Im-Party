import 'package:equatable/equatable.dart';

class LevelBadgesEntity extends Equatable {
  final int? minlevel;
  final int? maxlevel;
  final String? badge;

  const LevelBadgesEntity(
      { this.minlevel,
       this.maxlevel,
       this.badge,
       });

  @override
  // 
  List<Object?> get props => [minlevel,maxlevel,badge];
}

// Room Level Badge Entity for /rooms/level-badges endpoint
class RoomLevelBadgeEntity extends Equatable {
  final int? level;
  final String? badge;
  final int? exp;

  const RoomLevelBadgeEntity({
    this.level,
    this.badge,
    this.exp,
  });

  @override
  List<Object?> get props => [level, badge, exp];
}

class BadgesEntity extends Equatable {
  final List <LevelBadgesEntity> sender;
  final List <LevelBadgesEntity> reciver;
  final List <LevelBadgesEntity> charge;
  final List <LevelBadgesEntity> room;

  const BadgesEntity(
      {
        this.sender= const [],
        this.reciver=const [],
        this.charge=const [],
        this.room=const [],

      });

  @override
  List<Object?> get props => [sender,reciver,charge,room];
}