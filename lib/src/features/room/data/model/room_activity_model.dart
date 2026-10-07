
import 'package:general/src/features/room/domain/entities/room_activity_entity.dart';

import '../../../../../reels_viewer/reels_viewer.dart';
class RoomRewardModel extends RoomRewardEntity {
  const RoomRewardModel({
    super.roomReward,
    super.trophies,
    super.room,
    super.link,
  });

  factory RoomRewardModel.fromJson(Map<String, dynamic> json) {
    return RoomRewardModel(
      roomReward: parseValue<RoomRewardModelInner?>(
        json['room_reward'],
        null,
        customParser: (v) => RoomRewardModelInner.fromJson(v),
      ),
      trophies: parseValue<TrophiesModel?>(
        json['trophies'],
        null,
        customParser: (v) => TrophiesModel.fromJson(v),
      ),
      room: parseValue<RoomModel?>(
        json['room'],
        null,
        customParser: (v) => RoomModel.fromJson(v),
      ),
      link: parseValue<String>(json['link'], ''),
    );
  }
}

/// ------------------
/// Inner Models
/// ------------------

class RoomRewardModelInner extends RoomReward {
  const RoomRewardModelInner({
    super.owner,
    super.admins,
  });

  factory RoomRewardModelInner.fromJson(Map<String, dynamic> json) {
    return RoomRewardModelInner(
      owner: parseValue<int>(json['owner'], 0),
      admins: parseValue<int>(json['admins'], 0),
    );
  }
}

class TrophiesModel extends Trophies {
  const TrophiesModel({
    super.level,
    super.type,
    super.current,
    super.last,
  });

  factory TrophiesModel.fromJson(Map<String, dynamic> json) {
    return TrophiesModel(
      level: parseValue<int>(json['level'], 0),
      type: parseValue<String>(json['type'], ''),
      current: parseValue<TrophyStatsModel?>(
        json['current'],
        null,
        customParser: (v) => TrophyStatsModel.fromJson(v),
      ),
      last: parseValue<TrophyLastModel?>(
        json['last'],
        null,
        customParser: (v) => TrophyLastModel.fromJson(v),
      ),
    );
  }
}

class TrophyStatsModel extends TrophyStats {
  const TrophyStatsModel({
    super.totalCurrent,
    super.totalVisitors,
  });

  factory TrophyStatsModel.fromJson(Map<String, dynamic> json) {
    return TrophyStatsModel(
      totalCurrent: parseValue<int>(json['total_current'], 0),
      totalVisitors: parseValue<int>(json['total_visitors'], 0),
    );
  }
}

class TrophyLastModel extends TrophyLast {
  const TrophyLastModel({
    super.totalCurrent,
  });

  factory TrophyLastModel.fromJson(Map<String, dynamic> json) {
    return TrophyLastModel(
      totalCurrent: parseValue<int>(json['total_current'], 0),
    );
  }
}

class RoomModel extends Room {
  const RoomModel({
    super.adminCount,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      adminCount: parseValue<int>(json['admin_count'], 0),
    );
  }
}













//
//
//
// class RoomRewardModel extends RoomRewardEntity {
//   const RoomRewardModel({
//     super.roomReward,
//     super.trophies,
//     super.room,
//     super.link,
//   });
//
//   factory RoomRewardModel.fromJson(Map<String, dynamic> json) {
//     return RoomRewardModel(
//       roomReward: json['room_reward'] != null
//           ? RoomRewardModelInner.fromJson(json['room_reward'])
//           : null,
//       trophies: json['trophies'] != null
//           ? TrophiesModel.fromJson(json['trophies'])
//           : null,
//       room: json['room'] != null ? RoomModel.fromJson(json['room']) : null,
//       link: json['link'] as String?,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'room_reward': (roomReward as RoomRewardModelInner?)?.toJson(),
//       'trophies': (trophies as TrophiesModel?)?.toJson(),
//       'room': (room as RoomModel?)?.toJson(),
//       'link': link,
//     };
//   }
// }
//
// class RoomRewardModelInner extends RoomReward {
//   const RoomRewardModelInner({
//     super.owner,
//     super.admins,
//   });
//
//   factory RoomRewardModelInner.fromJson(Map<String, dynamic> json) {
//     return RoomRewardModelInner(
//       owner: json['owner'] as int?,
//       admins: json['admins'] as int?,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'owner': owner,
//       'admins': admins,
//     };
//   }
// }
//
// class TrophiesModel extends Trophies {
//   const TrophiesModel({
//     super.level,
//     super.type,
//     super.current,
//     super.last,
//   });
//
//   factory TrophiesModel.fromJson(Map<String, dynamic> json) {
//     return TrophiesModel(
//       level: json['level'] as int?,
//       type: json['type'] as String?,
//       current: json['current'] != null
//           ? TrophyStatsModel.fromJson(json['current'])
//           : null,
//       last: json['last'] != null
//           ? TrophyLastModel.fromJson(json['last'])
//           : null,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'level': level,
//       'type': type,
//       'current': (current as TrophyStatsModel?)?.toJson(),
//       'last': (last as TrophyLastModel?)?.toJson(),
//     };
//   }
// }
//
// class TrophyStatsModel extends TrophyStats {
//   const TrophyStatsModel({
//     super.totalCurrent,
//     super.totalVisitors,
//   });
//
//   factory TrophyStatsModel.fromJson(Map<String, dynamic> json) {
//     return TrophyStatsModel(
//       totalCurrent: json['total_current'] as int?,
//       totalVisitors: json['total_visitors'] as int?,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'total_current': totalCurrent,
//       'total_visitors': totalVisitors,
//     };
//   }
// }
//
// class TrophyLastModel extends TrophyLast {
//   const TrophyLastModel({
//     super.totalCurrent,
//   });
//
//   factory TrophyLastModel.fromJson(Map<String, dynamic> json) {
//     return TrophyLastModel(
//       totalCurrent: json['total_current'] as int?,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'total_current': totalCurrent,
//     };
//   }
// }
//
// class RoomModel extends Room {
//   const RoomModel({
//     super.adminCount,
//   });
//
//   factory RoomModel.fromJson(Map<String, dynamic> json) {
//     return RoomModel(
//       adminCount: json['admin_count'] as int?,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'admin_count': adminCount,
//     };
//   }
// }
