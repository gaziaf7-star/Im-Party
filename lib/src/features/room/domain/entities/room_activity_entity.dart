import 'package:equatable/equatable.dart';

class RoomRewardEntity extends Equatable {
  final RoomReward? roomReward;
  final Trophies? trophies;
  final Room? room;
  final String? link;

  const RoomRewardEntity({
    this.roomReward,
    this.trophies,
    this.room,
    this.link,
  });

  @override
  List<Object?> get props => [roomReward, trophies, room, link];
}

class RoomReward extends Equatable {
  final int? owner;
  final int? admins;

  const RoomReward({
    this.owner,
    this.admins,
  });

  @override
  List<Object?> get props => [owner, admins];
}

class Trophies extends Equatable {
  final int? level;
  final String? type;
  final TrophyStats? current;
  final TrophyLast? last;

  const Trophies({
    this.level,
    this.type,
    this.current,
    this.last,
  });

  @override
  List<Object?> get props => [level, type, current, last];
}

class TrophyStats extends Equatable {
  final int? totalCurrent;
  final int? totalVisitors;

  const TrophyStats({
    this.totalCurrent,
    this.totalVisitors,
  });

  @override
  List<Object?> get props => [totalCurrent, totalVisitors];
}

class TrophyLast extends Equatable {
  final int? totalCurrent;

  const TrophyLast({
    this.totalCurrent,
  });

  @override
  List<Object?> get props => [totalCurrent];
}

class Room extends Equatable {
  final int? adminCount;

  const Room({
    this.adminCount,
  });

  @override
  List<Object?> get props => [adminCount];
}
