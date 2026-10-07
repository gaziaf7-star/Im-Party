
import '../../../../core/utils/methods.dart';
import '../../domain/entities/level_badges_entity.dart';

class LevelsBadgesModel extends LevelBadgesEntity {
  const LevelsBadgesModel({
    super.minlevel,
    super.maxlevel,
    super.badge,
  })  ;

  factory LevelsBadgesModel.fromJson(Map<String, dynamic> json) {
    return LevelsBadgesModel(
      minlevel: parseValue<int>(json['minlevel'], 0),
      maxlevel: parseValue<int>(json['maxlevel'], 0),
      badge: parseValue<String>(json['badge'], ''),
    );
  }

}


class BadgesModel extends BadgesEntity {
  const BadgesModel({
    super.reciver,
    super.sender,
    super.charge,
    super.room,
  })  ;

  factory BadgesModel.fromJson(Map<String, dynamic> json) {
    return BadgesModel(
      sender: json['sender'] is List
          ? (json['sender'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => LevelsBadgesModel.fromJson(e))
          .toList() :[],
      reciver: json['receiver'] is List
          ? (json['receiver'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => LevelsBadgesModel.fromJson(e))
          .toList() :[],
      charge: json['charge'] is List
          ? (json['charge'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => LevelsBadgesModel.fromJson(e))
          .toList() :[],
      room: json['room'] is List
          ? (json['room'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => LevelsBadgesModel.fromJson(e))
          .toList() :[],

    );
  }


}

class RoomLevelBadgesModel {
  final List<RoomLevelBadgeEntity> roomLevel;

  const RoomLevelBadgesModel({
    this.roomLevel = const [],
  });

  factory RoomLevelBadgesModel.fromJson(Map<String, dynamic> json) {
    return RoomLevelBadgesModel(
      roomLevel: json['room_level'] is List
          ? (json['room_level'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => RoomLevelBadgeModel.fromJson(e))
              .toList()
          : [],
    );
  }
}

// Model for room level badge item
class RoomLevelBadgeModel extends RoomLevelBadgeEntity {
  const RoomLevelBadgeModel({
    super.level,
    super.badge,
    super.exp,
  });

  factory RoomLevelBadgeModel.fromJson(Map<String, dynamic> json) {
    return RoomLevelBadgeModel(
      level: json['level'] as int?,
      badge: json['badge'] as String?,
      exp: json['exp'] as int?,
    );
  }
}
