import 'package:general/src/features/games/domain/entities/game_room_entity.dart';

import '../../../../core/utils/methods.dart';

class GameRoomModel extends GameRoomEntity {
  const GameRoomModel({
    super.id,
    super.ownerId,
    super.roomId,
    super.name,
    super.visitorsCount,
    super.cover,
    super.isHot,
    super.isPopular,
    super.roomStatus,
    super.passwordStatus,
    super.roomIntro,
    super.maxAdmin,
    super.isRecommended,
    super.lang,
    super.isPk,
    super.lastVisitTime,
    super.profile,
    super.country,
    super.haveLuckBox,
  });

  factory GameRoomModel.fromJson(Map<String, dynamic> json) {
    return GameRoomModel(
      id: parseValue<int>(json['id'], 0),
      ownerId: parseValue<int>(json['owner_id'], 0),
      roomId: parseValue<String>(json['room_id'], ''),
      name: parseValue<String>(json['name'], ''),
      visitorsCount: parseValue<int>(json['visitors_count'], 0),
      cover: parseValue<String>(json['cover'], ''),
      isHot: parseValue<int>(json['is_hot'], 0),
      isPopular: parseValue<int>(json['is_popular'], 0),
      roomStatus: parseValue<String>(json['room_status'], ''),
      passwordStatus: parseValue<bool>(json['password_status'], false),
      roomIntro: parseValue<String>(json['room_intro'], ''),
      maxAdmin: parseValue<int>(json['max_admin'], 0),
      isRecommended: parseValue<int>(json['is_recommended'], 0),
      lang: parseValue<String>(json['lang'], ''),
      isPk: parseValue<bool>(json['is_pk'], false),
      lastVisitTime: parseValue<String>(json['last_visit_time'], ''),
      profile: json['profile'], // You can wrap this in a model if needed
      country:parseValue<String>(json['country'], '') ,
      haveLuckBox: parseValue<bool>(json['have_luck_box'], false),
    );
  }


}
