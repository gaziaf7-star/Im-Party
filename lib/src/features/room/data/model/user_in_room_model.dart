import 'dart:convert';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';

class UserInRoomModel extends Equatable {
  final String? name;
  final int? id;
  final int? wabbleId;
  final String? image;
  final String? receiverExp;
  final String? frame;
  final String? frameType;
  final int? vipLevel;
  final String? vipImage;
  final String? vipColor;
  final String? vipColorName;
  final String? senderLevelImage;
  final String? receiverLevelImage;
  final String? bio;
  final String? profileFrameId;
  final String? uuid;
  final int? gender;
  final int? age;
  final String? countryImage;
  final String? countryName;
  final String? bubble;
  final int? bubbleId;
  final int? numberOfFriends;
  final int? profileVisitors;
  final int? numberOfFollowings;
  final List<String>? achievementImages;
  final List<int>? userTypes;
  final String? coloredName;
  final num? specialId;
  final String? idImage;
  final bool? isCountryHidden;
  final ImageColorEntity? imageColorEntity;
  final MyHostsAgencyEntity? myAgency;

  const UserInRoomModel({
    this.name,
    this.id,
    this.receiverExp,
    this.wabbleId,
    this.image,
    this.frame,
    this.frameType,
    this.vipLevel,
    this.vipImage,
    this.vipColor,
    this.vipColorName,
    this.senderLevelImage,
    this.receiverLevelImage,
    this.bio,
    this.profileFrameId,
    this.uuid,
    this.gender,
    this.age,
    this.countryImage,
    this.countryName,
    this.bubble,
    this.bubbleId,
    this.numberOfFriends,
    this.profileVisitors,
    this.numberOfFollowings,
    this.achievementImages,
    this.coloredName,
    this.userTypes,
    this.specialId,
    this.idImage,
    this.isCountryHidden,
    this.imageColorEntity,
    this.myAgency,
  });

  UserInRoomModel copyWith({
    String? name,
    int? id,
    String? receiverExp,
    int? wabbleId,
    String? image,
    String? frame,
    String? frameType,
    int? vipLevel,
    String? vipImage,
    String? vipColor,
    String? vipColorName,
    String? senderLevelImage,
    String? receiverLevelImage,
    String? bio,
    String? profileFrameId,
    String? uuid,
    int? gender,
    int? age,
    String? countryImage,
    String? countryName,
    String? bubble,
    int? bubbleId,
    int? numberOfFriends,
    int? profileVisitors,
    int? numberOfFollowings,
    List<String>? achievementImages,
    List<int>? userTypes,
    String? coloredName,
    num? specialId,
    String? idImage,
    bool? isCountryHidden,
    ImageColorEntity? imageColorEntity,
    MyHostsAgencyEntity? myAgency,
  }) {
    return UserInRoomModel(
      name: name ?? this.name,
      id: id ?? this.id,
      receiverExp: receiverExp ?? this.receiverExp,
      wabbleId: wabbleId ?? this.wabbleId,
      image: image ?? this.image,
      frame: frame ?? this.frame,
      frameType: frameType ?? this.frameType,
      vipLevel: vipLevel ?? this.vipLevel,
      vipImage: vipImage ?? this.vipImage,
      vipColor: vipColor ?? this.vipColor,
      vipColorName: vipColorName ?? this.vipColorName,
      senderLevelImage: senderLevelImage ?? this.senderLevelImage,
      receiverLevelImage: receiverLevelImage ?? this.receiverLevelImage,
      bio: bio ?? this.bio,
      profileFrameId: profileFrameId ?? this.profileFrameId,
      uuid: uuid ?? this.uuid,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      countryImage: countryImage ?? this.countryImage,
      countryName: countryName ?? this.countryName,
      bubble: bubble ?? this.bubble,
      bubbleId: bubbleId ?? this.bubbleId,
      numberOfFriends: numberOfFriends ?? this.numberOfFriends,
      profileVisitors: profileVisitors ?? this.profileVisitors,
      numberOfFollowings: numberOfFollowings ?? this.numberOfFollowings,
      achievementImages: achievementImages ?? this.achievementImages,
      userTypes: userTypes ?? this.userTypes,
      coloredName: coloredName ?? this.coloredName,
      specialId: specialId ?? this.specialId,
      idImage: idImage ?? this.idImage,
      isCountryHidden: isCountryHidden ?? this.isCountryHidden,
      imageColorEntity: imageColorEntity ?? this.imageColorEntity,
      myAgency: myAgency ?? this.myAgency,
    );
  }

  /// Create from a [UserEntity] (or [UserModel]) returned by the batch
  /// `/users/details` API. Eliminates 30+ field manual mapping at call sites.
  factory UserInRoomModel.fromUserEntity(UserEntity entity) {
    return UserInRoomModel(
      id: entity.id ?? 0,
      name: entity.name ?? '',
      image: entity.profile?.image ?? '',
      receiverExp: entity.level?.expReceiver ?? '',
      bio: entity.bio ?? '',
      uuid: entity.uuid ?? '',
      countryImage: entity.country?.photo ?? '',
      countryName: entity.country?.name ?? '',
      frame: entity.frame ?? '',
      frameType: entity.frameType ?? '',
      gender: entity.profile?.gender ?? 0,
      numberOfFollowings: entity.numberOfFollowings ?? 0,
      numberOfFriends: entity.numberOfFriends ?? 0,
      profileFrameId: (entity.profileFrameId ?? 0).toString(),
      profileVisitors: entity.profileVisitors ?? 0,
      receiverLevelImage: entity.level?.receiverImage ?? '',
      senderLevelImage: entity.level?.senderImage ?? '',
      vipLevel: entity.vip?.level ?? 0,
      vipImage: entity.vip?.img1 ?? '',
      vipColorName: entity.vip?.colorName ?? '',
      bubbleId: entity.bubbleId ?? 0,
      bubble: entity.bubble ?? '',
      userTypes: entity.userTypes ?? [],
      idImage: entity.idImage ?? '',
      imageColorEntity: entity.imageColorEntity ?? const ImageColorEntity(),
      specialId: entity.specialId ?? 0,
      coloredName: entity.imageColorEntity?.color ?? '',
      isCountryHidden: entity.isCountryHidden ?? false,
      myAgency: entity.myAgency,
    );
  }

  /// Create from [MyDataEntity] (or [MyDataModel]) — the current user's data.
  /// Field names differ from [UserEntity] (e.g. `vip1` vs `vip`,
  /// `specialIdImage` vs `idImage`).
  factory UserInRoomModel.fromMyData(MyDataEntity data) {
    return UserInRoomModel(
      id: data.id ?? -1,
      name: data.name ?? '',
      image: data.profile?.image ?? '',
      receiverExp: data.level?.expReceiver ?? '',
      bio: data.bio ?? '',
      uuid: data.uuid ?? '',
      countryImage: data.country?.photo ?? '',
      countryName: data.country?.nameEn ?? '',
      frame: data.frame ?? '',
      frameType: data.frameType ?? '',
      gender: data.profile?.gender ?? 0,
      age: data.profile?.age ?? 0,
      numberOfFollowings: data.numberOfFollowings ?? 0,
      numberOfFriends: data.numberOfFriends ?? 0,
      profileFrameId: data.profileFrameId ?? '',
      profileVisitors: data.profileVisitors ?? 0,
      receiverLevelImage: data.level?.receiverImage ?? '',
      senderLevelImage: data.level?.senderImage ?? '',
      vipLevel: data.vip1?.level ?? 0,
      vipImage: data.vip1?.img1 ?? '',
      vipColor: data.vip1?.color ?? '',
      vipColorName: data.vip1?.colorName ?? '',
      bubbleId: data.bubbleId ?? 0,
      bubble: data.bubble ?? '',
      achievementImages: data.achievementImages ?? [],
      userTypes: data.userTypes ?? [],
      wabbleId: data.wabbleId ?? -1,
      idImage: data.specialIdImage ?? '',
      imageColorEntity: data.imageColorEntity ?? const ImageColorEntity(),
      specialId: data.specialId ?? 0,
      coloredName: data.imageColorEntity?.color ?? '',
      isCountryHidden: data.isCountryHidden ?? false,
      myAgency: data.myAgencyModel,
    );
  }

  factory UserInRoomModel.fromMap(Map<String, dynamic> map) {
    final imageColorMap = map['image_color'] is Map
        ? Map<String, dynamic>.from(map['image_color'] as Map)
        : null;

    return UserInRoomModel(
      name: parseValue<String>(map['name'], ''),
      id: parseValue<int>(map['id'], 0),
      wabbleId: parseValue<int>(map['wabble_id'], 0),
      image: parseValue<String>(map['image'], ''),
      receiverExp: parseValue<String>(map['receiver_exp'], ''),
      frame: parseValue<String>(map['frame'], ''),
      frameType: parseValue<String>(map['frame_type'], ''),
      vipLevel: parseValue<int>(map['vip'], 0),
      vipColor: parseValue<String>(map['vnc'], ''),
      vipColorName: parseValue<String>(map['vipColorName'], ''),
      vipImage: parseValue<String>(map['vipImage'], ''),
      senderLevelImage: parseValue<String>(map['sl'], ''),
      receiverLevelImage: parseValue<String>(map['rl'], ''),
      bio: parseValue<String>(map['bio'], ''),
      profileFrameId: parseValue<String>(map['pf'], ''),
      uuid: parseValue<String>(map['uuid'], ''),
      gender: parseValue<int>(map['g'], 0),
      age: parseValue<int>(map['age'], 0),
      countryImage: parseValue<String>(map['cf'], ''),
      countryName: parseValue<String>(map['cn'], ''),
      bubble: parseValue<String>(map['bubble'], ''),
      bubbleId: parseValue<int>(map['bubble_id'], 0),
      numberOfFriends: parseValue<int>(map['nf'], 0),
      profileVisitors: parseValue<int>(map['nv'], 0),
      numberOfFollowings: parseValue<int>(map['nf2'], 0),
      achievementImages: map['achievement_images'] != null
          ? parseValue<List<String>>(map['achievement_images'], [])
          : [],
      userTypes: map['user_types'] != null
          ? parseValue<List<int>>(map['user_types'], [])
          : [],
      coloredName: parseValue<String>(
        map.containsKey('colored_name') ? map['colored_name'] : null,
        '',
      ),
      imageColorEntity: imageColorMap != null && imageColorMap['color'] != null
          ? ImageColorModel.fromJson(imageColorMap)
          : null,
      idImage: parseValue<String>(map['id_image'], ''),
      isCountryHidden: parseValue<bool>(map['country_hidden'], false),
      specialId: parseValue<int>(map['special_id'], 0),
      myAgency: map['my_agency'] is Map
          ? MyAgencyModel.fromJson(
              Map<String, dynamic>.from(map['my_agency'] as Map))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'id': id,
      'wabble_id': wabbleId,
      'bubble_id': bubbleId,
      'receiver_exp': receiverExp,
      'image': image,
      'frame': frame,
      'frame_type': frameType,
      'vip': vipLevel,
      'vipImage': vipImage,
      'vnc': vipColor,
      'vipColorName': vipColorName,
      'sl': senderLevelImage,
      'rl': receiverLevelImage,
      'bio': bio,
      'pf': profileFrameId,
      'uuid': uuid,
      'g': gender,
      'age': age,
      'cf': countryImage,
      'cn': countryName,
      'bubble': bubble,
      'nf': numberOfFriends,
      'nv': profileVisitors,
      'nf2': numberOfFollowings,
      'achievement_images': achievementImages,
      'colored_name': coloredName,
      'user_types': userTypes,
      'country_hidden': isCountryHidden,
      'id_image': idImage,
      'my_agency': myAgency != null
          ? {
              'id': myAgency?.id,
              'image': myAgency?.img,
              'name': myAgency?.name,
              'notice': myAgency?.notice,
              'member_count': myAgency?.memberCount,
            }
          : null,
      'image_color': {
        'color': imageColorEntity?.color,
      },
    };
  }

  @override
  List<Object?> get props => [
        name,
        id,
        wabbleId,
        receiverExp,
        image,
        frame,
        frameType,
        vipLevel,
        vipImage,
        vipColor,
        vipColorName,
        senderLevelImage,
        receiverLevelImage,
        bio,
        profileFrameId,
        uuid,
        gender,
        age,
        countryImage,
        countryName,
        bubble,
        bubbleId,
        numberOfFriends,
        profileVisitors,
        numberOfFollowings,
        achievementImages,
        userTypes,
        coloredName,
        specialId,
        idImage,
        isCountryHidden,
        imageColorEntity,
        myAgency,
      ];

  /// Save as String JSON
  String toRawJson() => jsonEncode(toMap());

  /// Convert back from String JSON
  factory UserInRoomModel.fromRawJson(String str) =>
      UserInRoomModel.fromMap(jsonDecode(str));
}
