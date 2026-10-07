import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/auth/data/model/un_read_counter_model.dart';
import 'package:general/src/features/auth/domain/entities/un_read_counter_entity.dart';

class MyDataModel extends MyDataEntity {
  const MyDataModel({
    super.id,
    super.uid,
    super.chatId,
    super.notificationId,
    super.name,
    super.specialId,
    super.specialIdImage,
    super.specialIdColor,
    super.email,
    super.phone,
    super.frame,
    super.frameType,
    super.intro,
    super.introType,
    super.bubbleId,
    super.bubble,
    super.isCountryHidden,
    super.hasColorName,
    super.hasAntiBan,
    super.frameId,
    super.vipTargetId,
    super.introId,
    super.isFirst,
    super.isAgencyRequest,
    super.hasRoom,
    super.isAnonymous,
    super.isFacebook,
    super.isGoogle,
    super.isPhone,
    super.vip1,
    super.familyId,
    super.uuid,
    super.bio,
    super.companyNumber,
    super.numberOfFans,
    super.numberOfFollowings,
    super.numberOfFriends,
    super.profileVisitors,
    super.totalViews,
    super.nowRoom,
    super.profile,
    super.level,
    super.myStore,
    super.country,
    super.myAgencyModel,
    super.myShippingAgencyEntity,
    super.familyDataModel,
    super.isGold,
    super.myType,
    super.unReadMessageCount,
    super.isGameAvailable,
    super.showInvitationCode,
    super.roomEffects,
    super.managerTypeModel,
    super.soundEffectColor,
    super.viewInvitation,
    super.isHideRoom,
    super.onlineTime,
    super.lastActiveHidden,
    super.visitHidden,
    super.authToken,
    super.familyPrice,
    super.userAgencyStates,
    super.multiImages,
    super.myRoomData,
    super.unreadCounterEntity,
    super.achievementImages,
    super.userTypes,
    super.profileFrame,
    super.profileFrameId,
    super.imageColorEntity,
    super.newGift,
    super.wabbleEntity,
    super.wabbleId,
  });

  static MyDataModel? _instance;

  void clearInstance() => _instance = null;

  static MyDataModel getInstance() {
    return _instance ?? const MyDataModel();
  }


  factory MyDataModel.fromJson(Map<String, dynamic> map) {
    // Methods.printLog("intro ====> ${map['intro']}");
    // Methods.printLog("intro type ====> ${map['intro_type']}");
    // DEBUG (on request): dump the FULL raw "my data" API response to the
    // console every time it's fetched (app start, profile refresh, etc).
    // This is the RAW json the backend actually sends -- including any
    // field this app doesn't parse into MyDataEntity yet (e.g. a real
    // administrator/BD/super-admin role flag), so it's the fastest way to
    // find the exact field name for those roles: run the app, open a
    // terminal/logcat, go to the Profile tab, and read this line.
    Methods.printLog('👤 [MyDataModel] raw "my data" JSON ===> $map');
    _instance = const MyDataModel()._update(map);
    return _instance!;
  }
  // user_agency_status, 2=> owner, 1 => for admin, 3=> for normal user
  MyDataModel _update(Map<String, dynamic> map) {
    StringManager.userType.updateAll((key, value) => false);

    if (map['user_types'] != null && map['user_types'] != []) {
      for (var type in map['user_types']) {
        if (StringManager.userType.containsKey(type)) {
          StringManager.userType[type] = true;
        }
      }
    }

    // Coin Seller (reseller) role flag -- backend sends this as `coin_seller`
    // on the my-data/login response. Kept as a standalone StringManager flag
    // (same pattern as userType right above) rather than a new
    // MyDataEntity/MyDataModel field, since this model's constructor and its
    // several copyWith call sites below are large and easy to leave one out
    // of by mistake.
    StringManager.isCoinSeller = parseValue<bool>(map['coin_seller'], false);

    return MyDataModel(
      id: parseValue<int>(map['id'], 0),
      chatId: parseValue<String>(map['chat_id'], ''),
      uid: parseValue<String>(map['firebase_uuid'], ''),
      notificationId: parseValue<String>(map['notification_id'], ''),
      name: parseValue<String>(map['name'], ''),
      wabbleId: parseValue<int>(map['wabble_id'], 0),
      specialId: parseValue<int>(map['special_id'], 0),
      specialIdImage: parseValue<String>(map['special_id_image'], ''),
      specialIdColor: parseValue<String>(map['special_color'], ''),
      email: parseValue<String>(map['email'], ''),
      phone: parseValue<String>(map['phone'], ''),
      frame: parseValue<String>(map['frame'], ''),
      frameType: parseValue<String>(map['frame_type'], ''),
      intro: parseValue<String>(map['intro'], ''),
      introType: parseValue<String>(map['intro_type'], ''),
      bubbleId: parseValue<int>(map['bubble_id'], 0),
      bubble: parseValue<String>(map['bubble'], ''),
      isCountryHidden: parseValue<bool>(map['country_hidden'], false),
      hasColorName: parseValue<bool>(map['has_color_name'], false),
      hasAntiBan: parseValue<bool>(map['has_anti_ban'], false),
      frameId: parseValue<int>(map['frame_id'], 0),
      vipTargetId: parseValue<String>(map['vip_target_id'], ''),
      introId: parseValue<int>(map['intro_id'], 0),
      isFirst: parseValue<bool>(map['is_first'], false),
      isAgencyRequest: parseValue<bool>(map['is_agency_request'], false),
      hasRoom: parseValue<bool>(map['has_room'], false),
      isAnonymous: parseValue<bool>(map['anonymous'], false),
      isFacebook: parseValue<bool>(map['is_facebook'], false),
      isGoogle: parseValue<bool>(map['google_bind'], false),
      isPhone: parseValue<bool>(map['phone_bind'], false),
      familyId: parseValue<int>(map['family_id'], 0),
      uuid: parseValue<String>(map['uuid'], ''),
      bio: parseValue<String>(map['bio'], ''),
      companyNumber: parseValue<String>(map['company_number'], ''),
      numberOfFans: parseValue<int>(map['number_of_fans'], 0),
      numberOfFollowings: parseValue<int>(map['number_of_followings'], 0),
      numberOfFriends: parseValue<int>(map['number_of_friends'], 0),
      profileVisitors: parseValue<int>(map['profile_visitors'], 0),
      totalViews: parseValue<int>(map['total_views'], 0),
      unReadMessageCount: parseValue<int>(map['unread_message_count'], 0),
      isGameAvailable: parseValue<bool>(map['game_available'], false),
      showInvitationCode: parseValue<bool>(map['show_invite_code'], false),
      soundEffectColor: parseValue<String>(map['sound_effect_color'], ''),
      viewInvitation: parseValue<bool>(map['view_invitation'], false),
      visitHidden: parseValue<bool>(map['visit_hidden'], false),
      isHideRoom: parseValue<bool>(map['is_hide_room'], false),
      onlineTime: parseValue<String>(map['online_time'], ''),
      authToken: parseValue<String>(map['auth_token'], ''),
      familyPrice: parseValue<String>(map['family_price'], ''),
      profileFrame: parseValue<String>(map['profile_frame'], ''),
      profileFrameId: parseValue<String>(map['profile_frame_id'], ''),
      imageColorEntity: map['image_color'] is Map<String, dynamic>
          ? ImageColorModel.fromJson(map['image_color'])
          : null,
      myType: parseValue<int>(map[''], 0),
      vip1: map['vip'] is Map<String, dynamic> ? VipCenterModel.fromJson(map['vip']) : vip1,
      nowRoom: map['now_room'] is Map<String, dynamic>
          ? NowRoomModel.fromJson(map['now_room'])
          : nowRoom,
      profile: map['profile'] is Map<String, dynamic>
          ? ProfileRoomModel.fromJson(map['profile'])
          : profile,
      level: map['level'] is Map<String, dynamic> ? LevelModel.fromJson(map['level']) : level,
      myStore: map['my_store'] is Map<String, dynamic>
          ? MyStoreModel.fromJson(map['my_store'])
          : myStore,
      country: map['country'] is Map<String, dynamic>
          ? CountryModel.fromJson(map['country'])
          : country,
      myAgencyModel: map['agency'] is Map<String, dynamic> && map['agency'].isNotEmpty
          ? MyAgencyModel.fromJson(map['agency'])
          : myAgencyModel,
      myShippingAgencyEntity:
      map['shipping-agency'] is Map<String, dynamic> && map['shipping-agency'].isNotEmpty
          ? MyShippingAgencyModel.fromJson(map['shipping-agency'])
          : myShippingAgencyEntity,
      familyDataModel: map['family_data'] is Map<String, dynamic>
          ? FamilyModel.fromJson(map['family_data'])
          : familyDataModel,
      userAgencyStates: parseValue<int>(map['user_agency_status'], 0),
      newGift: parseValue<bool>(map['new_gift'], false),
      multiImages: map['multi_images'] != null
          ? parseValue<List<MultiImagesModel>>(
        map['multi_images'],
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
      achievementImages:
      parseValue<List<String>>(map['achievement_images'], []),
      userTypes: parseValue<List<int>>(map['user_types'], []),
      roomEffects: map['change_room_effect'] is Map<String, dynamic>
          ? CloseEffectModel.fromJson(map['change_room_effect'])
          : roomEffects,
      myRoomData:
      map['room'] is Map<String, dynamic> ? MyRoomModel.fromJson(map['room']) : myRoomData,
      unreadCounterEntity: map["unread_counter"] is Map<String, dynamic>
          ? UnreadCounterModel.fromJson(map["unread_counter"])
          : null,
      wabbleEntity: map['wabble'] is Map<String, dynamic>
          ? WappelModel.fromJson(map['wabble'])
          : wabbleEntity,
    );
  }

  static void updateInstance({
    int? id,
    String? chatId,
    String? notificationId,
    String? name,
    int? wabbleId,
    String? idImage,
    String? email,
    String? phone,
    String? frame,
    String? frameType,
    String? intro,
    String? introType,
    int? bubbleId,
    String? bubble,
    bool? isCountryHidden,
    bool? hasColorName,
    bool? hasAntiBan,
    int? frameId,
    String? vipTargetId,
    int? introId,
    bool? isFirst,
    bool? isAgencyRequest,
    bool? hasRoom,
    bool? isAnonymous,
    bool? isFacebook,
    bool? isGoogle,
    bool? isPhone,
    VipCenterEntity? vip1,
    int? familyId,
    String? uuid,
    String? bio,
    String? companyNumber,
    int? numberOfFans,
    int? numberOfFollowings,
    int? numberOfFriends,
    int? profileVisitors,
    NowRoomModel? nowRoom,
    ProfileRoomModel? profile,
    LevelModel? level,
    MyStoreModel? myStore,
    CountryModel? country,
    MyAgencyModel? myAgencyModel,
    FamilyModel? familyDataModel,
    bool? isGold,
    int? myType,
    int? unReadMessageCount,
    bool? isGameAvailable,
    bool? showInvitationCode,
    CloseEffectModel? roomEffects,
    ManagerTypeModel? managerTypeModel,
    String? soundEffectColor,
    bool? viewInvitation,
    bool? isHideRoom,
    String? onlineTime,
    bool? lastActiveHidden,
    bool? visitHidden,
    String? authToken,
    String? familyPrice,
    String? specialIdImage,
    String? specialIdColor,
    int? specialId,
    int? userAgencyStates,
    List<MultiImagesModel>? multiImages,
    MyRoomModel? myRoomData,
    UnreadCounterEntity? unreadCounterEntity,
    List<String>? achievementImages,
    List<int>? userTypes,
    String? profileFrame,
    String? profileFrameId,
    ImageColorModel? imageColorEntity,
    bool? newGift,
  }) {
    if (_instance != null) {
      _instance = _instance!.copyWith(
        id: id ?? _instance!.id,
        chatId: chatId ?? _instance!.chatId ?? '',
        notificationId: notificationId ?? _instance!.notificationId,
        name: name ?? _instance!.name,
        wabbleId: wabbleId ?? _instance!.wabbleId,
        specialId: specialId ?? _instance!.specialId,
        specialIdColor: specialIdColor ?? _instance!.specialIdColor,
        specialIdImage: specialIdImage ?? _instance!.specialIdImage,
        email: email ?? _instance!.email,
        phone: phone ?? _instance!.phone,
        frame: frame ?? _instance!.frame,
        frameType: frameType ?? _instance!.frameType,
        intro: intro ?? _instance!.intro,
        introType: introType ?? _instance!.introType,
        bubbleId: bubbleId ?? _instance!.bubbleId,
        bubble: bubble ?? _instance!.bubble,
        isCountryHidden: isCountryHidden ?? _instance!.isCountryHidden,
        hasColorName: hasColorName ?? _instance!.hasColorName,
        hasAntiBan: hasAntiBan ?? _instance!.hasAntiBan,
        frameId: frameId ?? _instance!.frameId,
        vipTargetId: vipTargetId ?? _instance!.vipTargetId,
        introId: introId ?? _instance!.introId,
        isFirst: isFirst ?? _instance!.isFirst,
        isAgencyRequest: isAgencyRequest ?? _instance!.isAgencyRequest,
        hasRoom: hasRoom ?? _instance!.hasRoom,
        isAnonymous: isAnonymous ?? _instance!.isAnonymous,
        isFacebook: isFacebook ?? _instance!.isFacebook,
        isGoogle: isGoogle ?? _instance!.isGoogle,
        isPhone: isPhone ?? _instance!.isPhone,
        vip1: vip1 ?? _instance!.vip1,
        familyId: familyId ?? _instance!.familyId,
        uuid: uuid ?? _instance!.uuid,
        bio: bio ?? _instance!.bio,
        companyNumber: companyNumber ?? _instance!.companyNumber,
        numberOfFans: numberOfFans ?? _instance!.numberOfFans,
        numberOfFollowings: numberOfFollowings ?? _instance!.numberOfFollowings,
        numberOfFriends: numberOfFriends ?? _instance!.numberOfFriends,
        profileVisitors: profileVisitors ?? _instance!.profileVisitors,
        nowRoom: nowRoom ?? _instance!.nowRoom,
        profile: profile ?? _instance!.profile,
        level: level ?? _instance!.level,
        myStore: myStore ?? _instance!.myStore,
        country: country ?? _instance!.country,
        myAgencyModel: myAgencyModel ?? _instance!.myAgencyModel,
        familyDataModel: familyDataModel ?? _instance!.familyDataModel,
        isGold: isGold ?? _instance!.isGold,
        myType: myType ?? _instance!.myType,
        unReadMessageCount: unReadMessageCount ?? _instance!.unReadMessageCount,
        isGameAvailable: isGameAvailable ?? _instance!.isGameAvailable,
        showInvitationCode: showInvitationCode ?? _instance!.showInvitationCode,
        roomEffects: roomEffects ?? _instance!.roomEffects,
        managerTypeModel: managerTypeModel ?? _instance!.managerTypeModel,
        soundEffectColor: soundEffectColor ?? _instance!.soundEffectColor,
        viewInvitation: viewInvitation ?? _instance!.viewInvitation,
        isHideRoom: isHideRoom ?? _instance!.isHideRoom,
        onlineTime: onlineTime ?? _instance!.onlineTime,
        lastActiveHidden: lastActiveHidden ?? _instance!.lastActiveHidden,
        visitHidden: visitHidden ?? _instance!.visitHidden,
        authToken: authToken ?? _instance!.authToken,
        familyPrice: familyPrice ?? _instance!.familyPrice,
        userAgencyStates: userAgencyStates ?? _instance!.userAgencyStates,
        multiImages: multiImages ?? _instance!.multiImages,
        myRoomData: myRoomData ?? _instance!.myRoomData,
        achievementImages: achievementImages ?? _instance!.achievementImages,
        userTypes: userTypes ?? _instance!.userTypes,
        profileFrame: profileFrame ?? _instance!.profileFrame,
        profileFrameId: profileFrameId ?? _instance!.profileFrameId,
        imageColorEntity: imageColorEntity ?? _instance!.imageColorEntity,
        newGift: newGift ?? _instance!.newGift,
        unreadCounterEntity:
        unreadCounterEntity ?? _instance!.unreadCounterEntity,
      );
    }
  }

  MyDataModel copyWith({
    int? id,
    int? userAgencyStates,
    bool? viewInvitation,
    String? chatId,
    String? name,
    int? wabbleId,
    String? email,
    String? phone,
    int? numberOfFans,
    int? numberOfFollowings,
    int? numberOfFriends,
    int? profileVisitors,
    int? totalViews,
    String? bio,
    String? companyNumber,
    int? familyId,
    String? uuid,
    String? frameType,
    bool? hasRoom,
    bool? isFacebook,
    bool? isGoogle,
    bool? isPhone,
    int? myType,
    bool? isHideRoom,
    String? onlineTime,
    bool? isCountryHidden,
    bool? lastActiveHidden,
    bool? visitHidden,
    bool? hasColorName,
    bool? hasAntiBan,
    bool? isAnonymous,
    bool? isGold,
    int? unReadMessageCount,
    bool? isGameAvailable,
    bool? showInvitationCode,
    ProfileRoomEntity? profile,
    LevelEntity? level,
    VipCenterEntity? vip1,
    FamilyEntity? familyDataModel,
    MyStoreEntity? myStore,
    String? frame,
    String? intro,
    String? introType,
    int? frameId,
    String? vipTargetId,
    int? introId,
    int? bubbleId,
    String? idImage,
    String? bubble,
    MyHostsAgencyEntity? myAgencyModel,
    bool? isAgencyRequest,
    bool? isFirst,
    String? notificationId,
    NowRoomEntity? nowRoom,
    CountryEntity? country,
    CloseEffectEntity? roomEffects,
    ManagerTypeEntity? managerTypeModel,
    String? soundEffectColor,
    String? authToken,
    String? familyPrice,
    int? specialId,
    String? specialIdColor,
    String? specialIdImage,
    final List<MultiImagesEntity>? multiImages,
    UnreadCounterEntity? unreadCounterEntity,
    MyRoomEntity? myRoomData,
    List<String>? achievementImages,
    List<int>? userTypes,
    String? profileFrame,
    String? profileFrameId,
    ImageColorEntity? imageColorEntity,
    bool? newGift,
  }) {
    return MyDataModel(
      id: id ?? this.id,
      viewInvitation: viewInvitation ?? this.viewInvitation,
      chatId: chatId ?? this.chatId,
      name: name ?? this.name,
      wabbleId: wabbleId ?? this.wabbleId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      frameType: frameType ?? this.frameType,
      numberOfFans: numberOfFans ?? this.numberOfFans,
      numberOfFollowings: numberOfFollowings ?? this.numberOfFollowings,
      numberOfFriends: numberOfFriends ?? this.numberOfFriends,
      profileVisitors: profileVisitors ?? this.profileVisitors,
      totalViews: totalViews ?? this.totalViews,
      bio: bio ?? this.bio,
      familyId: familyId ?? this.familyId,
      uuid: uuid ?? this.uuid,
      hasRoom: hasRoom ?? this.hasRoom,
      isFacebook: isFacebook ?? this.isFacebook,
      isGoogle: isGoogle ?? this.isGoogle,
      isPhone: isPhone ?? this.isPhone,
      myType: myType ?? this.myType,
      isHideRoom: isHideRoom ?? this.isHideRoom,
      onlineTime: onlineTime ?? this.onlineTime,
      isCountryHidden: isCountryHidden ?? this.isCountryHidden,
      lastActiveHidden: lastActiveHidden ?? this.lastActiveHidden,
      visitHidden: visitHidden ?? this.visitHidden,
      hasColorName: hasColorName ?? this.hasColorName,
      hasAntiBan: hasAntiBan ?? this.hasAntiBan,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isGold: isGold ?? this.isGold,
      unReadMessageCount: unReadMessageCount ?? this.unReadMessageCount,
      isGameAvailable: isGameAvailable ?? this.isGameAvailable,
      showInvitationCode: showInvitationCode ?? this.showInvitationCode,
      profile: profile ?? this.profile,
      level: level ?? this.level,
      companyNumber: companyNumber ?? this.companyNumber,
      vip1: vip1 ?? this.vip1,
      familyDataModel: familyDataModel ?? this.familyDataModel,
      myStore: myStore ?? this.myStore,
      frame: frame ?? this.frame,
      intro: intro ?? this.intro,
      introType: introType ?? this.introType,
      frameId: frameId ?? this.frameId,
      vipTargetId: vipTargetId ?? this.vipTargetId,
      introId: introId ?? this.introId,
      bubbleId: bubbleId ?? this.bubbleId,
      specialId: specialId ?? this.specialId,
      specialIdImage: specialIdImage ?? this.specialIdImage,
      specialIdColor: specialIdColor ?? this.specialIdColor,
      bubble: bubble ?? this.bubble,
      myAgencyModel: myAgencyModel ?? this.myAgencyModel,
      isAgencyRequest: isAgencyRequest ?? this.isAgencyRequest,
      isFirst: isFirst ?? this.isFirst,
      notificationId: notificationId ?? this.notificationId,
      nowRoom: nowRoom ?? this.nowRoom,
      country: country ?? this.country,
      roomEffects: roomEffects ?? this.roomEffects,
      managerTypeModel: managerTypeModel ?? this.managerTypeModel,
      soundEffectColor: soundEffectColor ?? this.soundEffectColor,
      authToken: authToken ?? this.authToken,
      familyPrice: familyPrice ?? this.familyPrice,
      multiImages: multiImages ?? this.multiImages,
      myRoomData: myRoomData ?? this.myRoomData,
      userAgencyStates: userAgencyStates ?? this.userAgencyStates,
      unreadCounterEntity: unreadCounterEntity ?? this.unreadCounterEntity,
      achievementImages: achievementImages ?? this.achievementImages,
      userTypes: userTypes ?? this.userTypes,
      profileFrame: profileFrame ?? this.profileFrame,
      profileFrameId: profileFrameId ?? this.profileFrameId,
      imageColorEntity: imageColorEntity ?? this.imageColorEntity,
      newGift: newGift ?? this.newGift,
    );
  }

  UserEntity convertMyDataEntityToUserEntity(MyDataEntity myDataModel) {
    return UserEntity(
        id: myDataModel.id,
        chatId: myDataModel.chatId,
        notificationId: myDataModel.notificationId,
        name: myDataModel.name,
        wabbleId: myDataModel.wabbleId,
        specialId: myDataModel.specialId,
        idImage: myDataModel.specialIdImage,
        imageColorEntity: myDataModel.imageColorEntity,
        frame: myDataModel.frame,
        intro: myDataModel.intro,
        frameType: myDataModel.frameType,
        bubbleId: myDataModel.bubbleId,
        bubble: myDataModel.bubble,
        isCountryHidden: myDataModel.isCountryHidden,
        hasColorName: myDataModel.hasColorName,
        hasAntiBan: myDataModel.hasAntiBan,
        frameId: myDataModel.frameId,
        introId: myDataModel.introId,
        isFirst: myDataModel.isFirst,
        isAgencyRequest: myDataModel.isAgencyRequest,
        isAnonymous: myDataModel.isAnonymous,
        vip: myDataModel.vip1,
        familyId: myDataModel.familyId,
        uuid: myDataModel.uuid,
        bio: myDataModel.bio,
        companyNumber: myDataModel.companyNumber,
        numberOfFans: myDataModel.numberOfFans,
        numberOfFollowings: myDataModel.numberOfFollowings,
        numberOfFriends: myDataModel.numberOfFriends,
        profileVisitors: myDataModel.profileVisitors,
        nowRoom: myDataModel.nowRoom,
        profile: myDataModel.profile,
        level: myDataModel.level,
        myStore: myDataModel.myStore,
        country: myDataModel.country,
        myAgency: myDataModel.myAgencyModel,
        familyData: myDataModel.familyDataModel,
        isGold: myDataModel.isGold,
        myType: myDataModel.myType,
        isGameAvailable: myDataModel.isGameAvailable,
        showInvitationCode: myDataModel.showInvitationCode,
        managerType: myDataModel.managerTypeModel,
        soundEffectColor: myDataModel.soundEffectColor,
        roomHidden: myDataModel.isHideRoom,
        onlineTime: myDataModel.onlineTime,
        lastActiveHidden: myDataModel.lastActiveHidden,
        visitHidden: myDataModel.visitHidden,
        images: myDataModel.multiImages,
        introType: myDataModel.introType,
        achievementImages: myDataModel.achievementImages,
        userTypes: myDataModel.userTypes,
        myShippingAgency: myDataModel.myShippingAgencyEntity,
        profileFrameId: myDataModel.profileFrameId);
  }
}

class MyRoomModel extends MyRoomEntity {
  const MyRoomModel({
    required super.id,
    required super.name,
    required super.cover,
    required super.background,
    required super.giftPrice,
    required super.mode,
    required super.ownerUuid,
    required super.isPk,
    required super.showPk,
    required super.passwordStatus,
    required super.typeName,
    required super.typeImg,
  });

  factory MyRoomModel.fromJson(Map<String, dynamic> json) {
    final typeField = json["type"];

    String typeName = '';
    String typeImg = '';

    if (typeField is Map<String, dynamic>) {
      typeName = parseValue<String>(typeField["name"], '');
      typeImg = parseValue<String>(typeField["img"], '');
    } else if (typeField is String) {
      typeName = typeField; // e.g. "app"
      typeImg = ''; // no image if string
    }

    return MyRoomModel(
      id: parseValue<int>(json['id'], 0),
      name: parseValue<String>(json['room_name'], ''),
      cover: parseValue<String>(json['room_cover'], ''),
      background: parseValue<String>(json['room_background'], ''),
      giftPrice: parseValue<String>(json['giftPrice'], '0'),
      mode: parseValue<int>(json['mode'], 0),
      ownerUuid: parseValue<String>(json['owner_uuid'], ''),
      isPk: parseValue<int>(json['is_pk'], 0),
      showPk: parseValue<int>(json['show_pk'], 0),
      passwordStatus: parseValue<bool>(json['password_status'], false),
      typeName: typeName,
      typeImg: typeImg,
    );
  }
}

class ImageColorModel extends ImageColorEntity {
  const ImageColorModel({
    super.id,
    super.name,
    super.image,
    super.color,
    super.createdAt,
    super.updatedAt,
  });

  factory ImageColorModel.fromJson(Map<String, dynamic> json) {
    return ImageColorModel(
      id: parseValue<int>(json['id'], 0),
      name: parseValue<String>(json['name'], ''),
      image: parseValue<String>(json['image'], ''),
      color: parseValue<String>(json['color'], ''),
      createdAt: parseValue<String>(json['created_at'], ''),
      updatedAt: parseValue<String>(json['updated_at'], ''),
    );
  }
}

class WappelModel extends WabbleEntity {
  const WappelModel({
    super.id,
    super.image,
    super.imageType,
    super.key,
  });

  factory WappelModel.fromJson(Map<String, dynamic> json) {
    return WappelModel(
      id: parseValue<int>(json['id'], 0),
      image: parseValue<String>(json['image'], ''),
      imageType: parseValue<String>(json['image_type'], ''),
      key: parseValue<String>(json['key'], ''),
    );
  }
}