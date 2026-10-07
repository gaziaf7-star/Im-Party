import 'package:general/src/features/home/domain/entities/room_entity.dart';

import '../../../../../reels_viewer/reels_viewer.dart';

class RoomModel extends RoomEntity {
  const RoomModel({
    super.id,
    super.roomId,
    super.type,
    super.name,
    super.visitorsCount,
    super.cover,
    super.isBoxLucky,
    super.isHot,
    super.isPK,
    super.isPopular,
    super.roomIntro,
    super.isRecommended,
    super.ownerId,
    super.country,
    super.agency,
    super.lang,
    super.passwordStatus,
    super.game,
    super.mode,
    super.roomBackground,
    super.visitorsImages,
    super.giftPrice,
    super.uuidOwnerRoom,
    super.achievementImages,
    super.ownerImageColor,
    super.ownerSpecialId,
    super.hasLuckyBox,
    super.isCountryHidden,
    super.streamType,
    super.isLive,
    super.ownerName,
    super.ownerImage,
    super.roomType,
    super.roomRule,
    super.roomLevelImage,
  });
  factory RoomModel.fromJson(Map<String, dynamic> map) {
    return RoomModel(
      hasLuckyBox: parseValue<bool>(map['is_lucky_box'], false),
      roomBackground: parseValue<String>(map['room_background'], ''),
      id: parseValue<int>(map['id'], 0),
      roomId: parseValue<String>(map['room_id'], ''),
      name: (parseValue<String>(map['name'], '').isNotEmpty)
          ? parseValue<String>(map['name'], '')
          : parseValue<String>(map['room_name'], ''),
      type: map['type'] == null || (map['type'] as Map).isEmpty
          ? ''
          : map['type']['name'] ?? '',
      visitorsCount: parseValue<int>(map['visitors_count'], 0),
      cover: parseValue<String>(map['cover'], ''),
      isHot: parseValue<int>(map['is_hot'], 0),
      isPopular: parseValue<int>(map['is_popular'], 0),
      uuidOwnerRoom: map['owner_uuid'] == 0 || map['owner_uuid'] == null
          ? ""
          : map['owner_uuid'],
      passwordStatus: parseValue<bool>(map['password_status'], false),
      roomIntro: parseValue<String>(map['room_intro'], ''),
      isRecommended: parseValue<int>(map['is_recommended'], 0),
      lang: parseValue<String>(map['lang'], ''),
      country: map['country'] is Map<String, dynamic>
          ? CountryRoomModel.fromJson(map['country'])
          : null,
      agency: map['agency'] is Map<String, dynamic>
          ? AgencyModel.fromJson(map['agency'])
          : null,
      game: map['game'] is Map<String, dynamic>
          ? GameModel.fromJson(map['game'])
          : null,
      ownerId: parseValue<int>(map['owner_id'], 0),
      mode: parseValue<String>(map['mode'].toString(), ''),
      isPK: parseValue<bool>(map['is_pk'], false),
      isBoxLucky: parseValue<bool>(map['have_luck_box'], false),
      isCountryHidden: parseValue<bool>(map['country_hidden'], false),
      achievementImages: parseValue<List<String>>(
          map['achievement_images']?.cast<String>(), []),
      visitorsImages: map['visitors_images'] != null
          ? (map['visitors_images'] as List<dynamic>?)
              ?.where((element) => element != null)
              .map((element) => element as String)
              .toList()
          : [],
      giftPrice: parseValue<String>(map["giftPrice"], ''),
      ownerSpecialId: parseValue<String>(map["owner_special_id"], ''),
      ownerImageColor: map['owner_image_color'] is Map<String, dynamic>
          ? ImageColorModel.fromJson(map['owner_image_color'])
          : null,
      isLive: parseValue<bool>(map['is_live'], false),
      ownerName: parseValue<String>(map['owner_name'], ''),
      ownerImage: parseValue<String>(map['owner_image'], ''),
      streamType: parseValue<String>(map['stream_type'], ''),
      roomType: parseValue<String>(map['room_type'], ''),
      roomRule: parseValue<String>(map['room_rule'], ''),
      roomLevelImage: parseValue<String>(map['room_level_image'], ''),
    );
  }
}

class CountryRoomModel extends CountryRoomEntity {
  const CountryRoomModel({
    required super.id,
    required super.name,
    required super.flag,
    required super.phoneCode,
    required super.lang,
  });

  factory CountryRoomModel.fromJson(Map<String, dynamic> data) {
    return CountryRoomModel(
      id: parseValue<int>(data['id'], 0),
      name: parseValue<String>(data['name'], ''),
      flag: parseValue<String>(data['flag'], ''),
      phoneCode: parseValue<String>(data['phone_code'], ''),
      lang: parseValue<String>(data['lang'], ''),
    );
  }
}

class GameModel extends GameEntity {
  const GameModel({
    super.id,
    super.name,
    super.image,
    super.url,
    super.webViewConfig,
    super.highSafety,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: parseValue<int>(json['id'], 0),
      name: parseValue<String>(json['name'], ''),
      image: parseValue<String>(json['image'], ''),
      url: parseValue<String>(json['url'], ''),
      webViewConfig: parseValue<bool>(json['webView_config'], false),
      highSafety: parseValue<int>(json['high_safety'], 0),
    );
  }
}

class AgencyModel extends AgencyEntity {
  const AgencyModel({
    required super.id,
    required super.name,
  });

  factory AgencyModel.fromJson(Map<String, dynamic> json) {
    return AgencyModel(
      id: parseValue<int>(json['id'], 0),
      name: parseValue<String>(json['name'], StringManager.noAgen.tr()),
    );
  }
}
