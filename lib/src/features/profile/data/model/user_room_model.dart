import 'package:equatable/equatable.dart';
import 'package:general/src/core/utils/methods.dart';

class UserRoomsModel extends Equatable {
  final MyRoom? audio;
  final MyRoom? live;
  final MyRoom? nowRoom;

  const UserRoomsModel({
    this.audio,
    this.live,
    this.nowRoom,
  });

  factory UserRoomsModel.fromJson(Map<String, dynamic> json) {
    return UserRoomsModel(
      audio: json['audio'] is Map<String, dynamic> ? MyRoom.fromJson(json['audio']) : null,
      live: json['live'] is Map<String, dynamic> ? MyRoom.fromJson(json['live']) : null,
      nowRoom:
          json['now_room'] is Map<String, dynamic> ? MyRoom.fromJson(json['now_room']) : null,
    );
  }

  @override
  List<Object?> get props => [
        audio,
        live,
        nowRoom,
      ];
}

class MyRoom extends Equatable {
  final int id;
  final int ownerId;
  final String ownerUuid;
  final String ownerName;
  final String ownerImage;
  final String roomId;
  final String ownerSpecialId;
  final OwnerImageColorModel? ownerImageColor;
  final String name;
  final int mode;
  final int visitorsCount;
  final String cover;
  final int isHot;
  final String session;
  final String giftPrice;
  final int isPopular;
  final String roomStatus;
  final bool passwordStatus;
  final String roomIntro;
  final String? maxAdmin;
  final int isRecommended;
  final String lang;
  final bool isPk;
  final bool isParty;
  final String roomBackground;
  final String streamType;
  final bool isLive;
  final bool isLuckyBox;
  final CountryModel? country;
  final bool haveLuckBox;
  final List<String> visitorsImages;
  final bool countryHidden;

  const MyRoom({
    required this.id,
    required this.ownerId,
    required this.ownerUuid,
    required this.ownerName,
    required this.ownerImage,
    required this.roomId,
    required this.ownerSpecialId,
    required this.ownerImageColor,
    required this.name,
    required this.mode,
    required this.visitorsCount,
    required this.cover,
    required this.isHot,
    required this.session,
    required this.giftPrice,
    required this.isPopular,
    required this.roomStatus,
    required this.passwordStatus,
    required this.roomIntro,
    required this.maxAdmin,
    required this.isRecommended,
    required this.lang,
    required this.isPk,
    required this.isParty,
    required this.roomBackground,
    required this.streamType,
    required this.isLive,
    required this.isLuckyBox,
    required this.country,
    required this.haveLuckBox,
    required this.visitorsImages,
    required this.countryHidden,
  });

  factory MyRoom.fromJson(Map<String, dynamic> json) {
    return MyRoom(
      id: parseValue<int>(json['id'], 0),
      ownerId: parseValue<int>(json['owner_id'], 0),
      ownerUuid: parseValue<String>(json['owner_uuid'], ""),
      ownerName: parseValue<String>(json['owner_name'], ""),
      ownerImage: parseValue<String>(json['owner_image'], ""),
      roomId: parseValue<String>(json['room_id'], ""),
      ownerSpecialId: parseValue<String>(json['owner_special_id'], ""),
      ownerImageColor: json['owner_image_color'] is Map<String, dynamic>
          ? OwnerImageColorModel.fromJson(json['owner_image_color'])
          : null,
      name: parseValue<String>(json['name'], ""),
      mode: parseValue<int>(json['mode'], 0),
      visitorsCount: parseValue<int>(json['visitors_count'], 0),
      cover: parseValue<String>(json['cover'], ""),
      isHot: parseValue<int>(json['is_hot'], 0),
      session: parseValue<String>(json['session'], ""),
      giftPrice: parseValue<String>(json['giftPrice'], ""),
      isPopular: parseValue<int>(json['is_popular'], 0),
      roomStatus: parseValue<String>(json['room_status'], ""),
      passwordStatus: parseValue<bool>(json['password_status'], false),
      roomIntro: parseValue<String>(json['room_intro'], ""),
      maxAdmin: json['max_admin']?.toString(),
      isRecommended: parseValue<int>(json['is_recommended'], 0),
      lang: parseValue<String>(json['lang'], ""),
      isPk: parseValue<bool>(json['is_pk'], false),
      isParty: parseValue<bool>(json['is_party'], false),
      roomBackground: parseValue<String>(json['room_background'], ""),
      streamType: parseValue<String>(json['stream_type'], ""),
      isLive: parseValue<bool>(json['is_live'], false),
      isLuckyBox: parseValue<bool>(json['is_lucky_box'], false),
      country: json['country'] is Map<String, dynamic>
          ? CountryModel.fromJson(json['country'])
          : null,
      haveLuckBox: parseValue<bool>(json['have_luck_box'], false),
      visitorsImages:
          parseValue<List<String>>(json['visitors_images'], <String>[]),
      countryHidden: parseValue<bool>(json['country_hidden'], false),
    );
  }

  @override
  List<Object?> get props => [
        id,
        ownerId,
        ownerUuid,
        ownerName,
        ownerImage,
        roomId,
        ownerSpecialId,
        ownerImageColor,
        name,
        mode,
        visitorsCount,
        cover,
        isHot,
        session,
        giftPrice,
        isPopular,
        roomStatus,
        passwordStatus,
        roomIntro,
        maxAdmin,
        isRecommended,
        lang,
        isPk,
        isParty,
        roomBackground,
        streamType,
        isLive,
        isLuckyBox,
        country,
        haveLuckBox,
        visitorsImages,
        countryHidden,
      ];
}

class OwnerImageColorModel extends Equatable {
  final int id;
  final String name;
  final String image;
  final String color;
  final String createdAt;
  final String updatedAt;

  const OwnerImageColorModel({
    required this.id,
    required this.name,
    required this.image,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OwnerImageColorModel.fromJson(Map<String, dynamic> json) {
    return OwnerImageColorModel(
      id: parseValue<int>(json['id'], 0),
      name: parseValue<String>(json['name'], ""),
      image: parseValue<String>(json['image'], ""),
      color: parseValue<String>(json['color'], ""),
      createdAt: parseValue<String>(json['created_at'], ""),
      updatedAt: parseValue<String>(json['updated_at'], ""),
    );
  }

  @override
  List<Object?> get props => [id, name, image, color, createdAt, updatedAt];
}

class CountryModel extends Equatable {
  final int id;
  final String name;
  final String flag;
  final String lang;
  final String phoneCode;
  final String iso;

  const CountryModel({
    required this.id,
    required this.name,
    required this.flag,
    required this.lang,
    required this.phoneCode,
    required this.iso,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: parseValue<int>(json['id'], 0),
      name: parseValue<String>(json['name'], ""),
      flag: parseValue<String>(json['flag'], ""),
      lang: parseValue<String>(json['lang'], ""),
      phoneCode: parseValue<String>(json['phone_code'], ""),
      iso: parseValue<String>(json['iso'], ""),
    );
  }

  @override
  List<Object?> get props => [id, name, flag, lang, phoneCode, iso];
}
