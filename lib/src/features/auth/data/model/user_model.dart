import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';

class UserModel extends UserEntity {
  const UserModel({
    super.id,
    super.chatId,
    super.name,
    super.wabbleId,
    super.isFollow,
    super.isFollowingMe,
    super.profile,
    super.nowRoom,
    super.frameType,
    super.room,
    super.level,
    super.colorName,
    super.vip,
    super.frame,
    super.intro,
    super.introType,
    super.frameId,
    super.introId,
    super.bubbleId,
    super.specialId,
    super.idImage,
    super.bubble,
    super.myAgency,
    super.isAgencyRequest,
    super.isFriend,
    super.isFirst,
    super.familyId,
    super.familyData,
    super.uuid,
    super.notificationId,
    super.bio,
    super.country,
    super.userType,
    super.numberOfFans,
    super.numberOfFollowings,
    super.numberOfFriends,
    super.profileVisitors,
    super.totalViews,
    super.lastActiveHidden,
    super.visitHidden,
    super.roomHidden,
    super.hasColorName,
    super.hasAntiBan,
    super.isAnonymous,
    super.onlineTime,
    super.online,
    super.lastSeenAt,
    super.isCountryHidden,
    super.isGold,
    super.visitTime,
    super.isGameAvailable,
    super.showInvitationCode,
    super.managerType,
    super.myType,
    super.soundEffectColor,
    super.chatSettings,
    super.statistic,
    super.myStore,
    super.images,
    super.imagesSupport,
    super.imageColorEntity,
    super.profileFrameId,
    super.userTypes,
    super.myShippingAgency,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        id: parseValue<int>(json['id'], 0),
        chatId: parseValue<String>(json['chat_id'], ''),
        notificationId: parseValue<String>(json['notification_id'], ''),
        name: parseValue<String>(json['name'], ''),
        wabbleId: parseValue<int>(json['wabble_id'], -1),
        frame: parseValue<String>(json['frame'], ''),
        frameType: parseValue<String>(json['frame_type'], ''),
        intro: parseValue<String>(json['intro'], ''),
        introType: parseValue<String>(json['intro_type'], ''),
        isFriend: parseValue<bool>(json['is_friend'], false),
        bubbleId: parseValue<int>(json['bubble_id'], 0),
        idImage: parseValue<String>(json['id_image'], ''),
        specialId: parseValue<int>(json['special_id'], 0),
        bubble: parseValue<String>(json['bubble'], ''),
        frameId: parseValue<int>(json['frame_id'], 0),
        introId: parseValue<int>(json['intro_id'], 0),
        isFirst: parseValue<bool>(json['is_first'], false),
        isAgencyRequest: parseValue<bool>(json['is_agency_request'], false),
        vip: json['vip'] is Map<String, dynamic>
            ? VipCenterModel.fromJson(json['vip'])
            : null,
        familyId: parseValue<int>(json['family_id'], 0),
        uuid: parseValue<String>(json['uuid'], ''),
        isFollow: parseValue<bool>(json['is_follow'], false),
        bio: parseValue<String>(json['bio'], ''),
        numberOfFans: parseValue<int>(json['number_of_fans'], 0),
        numberOfFollowings: parseValue<int>(json['number_of_followings'], 0),
        numberOfFriends: parseValue<int>(json['number_of_friends'], 0),
        profileVisitors: parseValue<int>(json['profile_visitors'], 0),
        totalViews: parseValue<int>(json['total_views'], 0),
        profile: json['profile'] is Map<String, dynamic>
            ? ProfileRoomModel.fromJson(json['profile'] as Map<String, dynamic>)
            : null,
        level: json['level'] is Map<String, dynamic>
            ? LevelModel.fromJson(json['level'] as Map<String, dynamic>)
            : null,
        colorName: parseValue<String>(json['color_name'], ''),
        myStore: json['my_store'] is Map<String, dynamic>
            ? MyStoreModel.fromJson(json['my_store'] as Map<String, dynamic>)
            : null,
        nowRoom: json['now_room'] is Map<String, dynamic>
            ? NowRoomModel.fromJson(json["now_room"] as Map<String, dynamic>)
            : null,
        room: json['room'] is Map<String, dynamic>
            ? NowRoomModel.fromJson(json["room"] as Map<String, dynamic>)
            : null,
        userType: parseValue<int>(json['type_user'], 0),
        profileFrameId: parseValue<String>(json['profile_frame_id'], ''),
        onlineTime: parseValue<String>(json['online_time'], ''),
        online: parseValue<bool>(
          json['online'],
          false,
          customParser: (value) =>
              value == true || value == 1 || value.toString() == '1',
        ),
        lastSeenAt: parseValue<String>(json['last_seen_at'], ''),
        hasColorName: parseValue<bool>(json['has_color_name'], false),
        hasAntiBan: parseValue<bool>(json['has_anti_ban'], false),
        isAnonymous: parseValue<bool>(json['anonymous'], false),
        isCountryHidden: parseValue<bool>(json['country_hidden'], false),
        lastActiveHidden: parseValue<bool>(json['last_active_hidden'], false),
        visitHidden: parseValue<bool>(json['visit_hidden'], false),
        roomHidden: parseValue<bool>(json['room_hidden'], false),
        isGold: parseValue<bool>(json['is_gold_id'], false),
        isFollowingMe: parseValue<bool>(json['is_followed'], false),
        chatSettings: json['chat_setting'] is Map<String, dynamic>
            ? ChatSettingsModel.fromJson(json['chat_setting'])
            : null,
        country: json['country'] == ''
            ? null
            : json['country'] is Map<String, dynamic>
                ? CountryModel.fromJson(json['country'])
                : null,
        familyData: json['family_data'] is Map<String, dynamic>
            ? FamilyModel.fromJson(json['family_data'])
            : null,
        myAgency: json['agency'] is Map<String, dynamic>
            ? MyAgencyModel.fromJson(json["agency"])
            : null,
        visitTime: json['visit_time'] ?? "",
        managerType: json["manger_type"] is Map<String, dynamic>
            ? ManagerTypeModel.fromJson(json["manger_type"])
            : null,
        myType: json['type_user'] ?? 0,
        soundEffectColor: json['sound_effect_color'],
        images: json['multi_images'] != null
            ? parseValue<List<MultiImagesModel>>(
                json['multi_images'],
                [],
                customParser: (value) {
                  if (value is List) {
                    return value
                        .map((item) => MultiImagesModel.fromJson(
                            item as Map<String, dynamic>))
                        .toList();
                  }
                  return [];
                },
              )
            : null,
        statistic: json['statistic'] is Map<String, dynamic>
            ? StatisticModel.fromJson(json['statistic'])
            : null,
        imageColorEntity: json['image_color'] is Map<String, dynamic>
            ? ImageColorModel.fromJson(json['image_color'])
            : null,
        imagesSupport: json['top_three_support'] != null
            ? parseValue<List<MultiImagesModel>>(
                json['top_three_support'],
                [],
                customParser: (value) {
                  if (value is List) {
                    return value
                        .map((item) => MultiImagesModel.fromJson(
                            item as Map<String, dynamic>))
                        .toList();
                  }
                  return [];
                },
              )
            : null,
        myShippingAgency: json['shipping-agency'] is Map<String, dynamic>
            ? MyShippingAgencyModel.fromJson(json["shipping-agency"])
            : null,
        userTypes: json['user_types'] is List
            ? (json['user_types'] as List)
                .map((element) => element as int)
                .toList()
            : null);
  }

  UserModel copyWith({
    int? id,
    String? chatId,
    String? name,
    int? wabbleId,
    bool? isFollow,
    bool? isFollowingMe,
    ProfileRoomModel? profile,
    NowRoomModel? nowRoom,
    NowRoomModel? room,
    LevelModel? level,
    String? colorName,
    VipCenterModel? vip1,
    MyStoreModel? myStore,
    ChatSettingsModel? chatSettings,
    String? frame,
    String? frameType,
    String? intro,
    String? introType,
    int? frameId,
    int? introId,
    int? bubbleId,
    dynamic specialId,
    String? idImage,
    String? bubble,
    MyAgencyModel? myAgencyModel,
    bool? isAgencyRequest,
    bool? isFriend,
    bool? isFirst,
    int? familyId,
    FamilyModel? familyData,
    String? uuid,
    String? notificationId,
    String? bio,
    CountryModel? country,
    int? userType,
    int? numberOfFans,
    int? numberOfFollowings,
    int? numberOfFriends,
    int? profileVisitors,
    int? totalViews,
    bool? lastActiveHidden,
    bool? visitHidden,
    bool? roomHidden,
    bool? hasColorName,
    bool? hasAntiBan,
    bool? isAnonymous,
    String? onlineTime,
    bool? isCountryHidden,
    bool? isGold,
    String? visitTime,
    bool? isGameAvailable,
    bool? showInvitationCode,
    ManagerTypeModel? managerTypeModel,
    int? myType,
    String? soundEffectColor,
    ImageColorModel? imageColorEntity,
    String? profileFrameId,
    List<int>? userTypes,
  }) {
    return UserModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      name: name ?? this.name,
      wabbleId: wabbleId ?? this.wabbleId,
      isFollow: isFollow ?? this.isFollow,
      isFollowingMe: isFollowingMe ?? this.isFollowingMe,
      profile: profile ?? this.profile,
      nowRoom: nowRoom ?? this.nowRoom,
      room: room ?? this.room,
      frameType: frameType ?? this.frameType,
      level: level ?? this.level,
      colorName: colorName ?? this.colorName,
      vip: vip1 ?? vip,
      myStore: myStore ?? this.myStore,
      chatSettings: chatSettings ?? this.chatSettings,
      frame: frame ?? this.frame,
      intro: intro ?? this.intro,
      introType: introType ?? this.introType,
      frameId: frameId ?? this.frameId,
      introId: introId ?? this.introId,
      bubbleId: bubbleId ?? this.bubbleId,
      specialId: specialId ?? this.specialId,
      idImage: idImage ?? this.idImage,
      bubble: bubble ?? this.bubble,
      images: images ?? images,
      myAgency: myAgency ?? myAgency,
      isAgencyRequest: isAgencyRequest ?? this.isAgencyRequest,
      isFriend: isFriend ?? this.isFriend,
      isFirst: isFirst ?? this.isFirst,
      familyId: familyId ?? this.familyId,
      familyData: familyData ?? this.familyData,
      uuid: uuid ?? this.uuid,
      notificationId: notificationId ?? this.notificationId,
      bio: bio ?? this.bio,
      country: country ?? this.country,
      userType: userType ?? this.userType,
      numberOfFans: numberOfFans ?? this.numberOfFans,
      numberOfFollowings: numberOfFollowings ?? this.numberOfFollowings,
      numberOfFriends: numberOfFriends ?? this.numberOfFriends,
      profileVisitors: profileVisitors ?? this.profileVisitors,
      totalViews: totalViews ?? this.totalViews,
      lastActiveHidden: lastActiveHidden ?? this.lastActiveHidden,
      visitHidden: visitHidden ?? this.visitHidden,
      roomHidden: roomHidden ?? this.roomHidden,
      hasColorName: hasColorName ?? this.hasColorName,
      hasAntiBan: hasAntiBan ?? this.hasAntiBan,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      onlineTime: onlineTime ?? this.onlineTime,
      isCountryHidden: isCountryHidden ?? this.isCountryHidden,
      isGold: isGold ?? this.isGold,
      visitTime: visitTime ?? this.visitTime,
      isGameAvailable: isGameAvailable ?? isGameAvailable,
      showInvitationCode: showInvitationCode ?? showInvitationCode,
      managerType: managerType ?? managerType,
      myType: myType ?? this.myType,
      soundEffectColor: soundEffectColor ?? this.soundEffectColor,
      imageColorEntity: imageColorEntity ?? this.imageColorEntity,
      userTypes: userTypes ?? this.userTypes,
    );
  }
}
