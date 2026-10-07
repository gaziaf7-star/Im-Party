import 'package:equatable/equatable.dart';
import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/auth/domain/entities/un_read_counter_entity.dart';

class MyDataEntity extends Equatable {
  final int? id;
  final String? chatId;
  final String? uid;
  final String? name;
  final String? email;
  final String? phone;
  final int? numberOfFans;
  final int? numberOfFollowings;
  final int? numberOfFriends;
  final int? profileVisitors;
  final int? totalViews;
  final ProfileRoomEntity? profile;
  final LevelEntity? level;
  final VipCenterEntity? vip1;
  final FamilyEntity? familyDataModel;
  final MyStoreEntity? myStore;
  final String? frame;
  final String? frameType;
  final String? intro;
  final String? introType;
  final int? frameId;
  final String? vipTargetId;
  final int? introId;
  final int? bubbleId;
  final int? userAgencyStates;
  final String? specialIdImage;
  final String? specialIdColor;
  final String? bubble;
  final MyHostsAgencyEntity? myAgencyModel;
  final MyShippingAgencyEntity? myShippingAgencyEntity;
  final bool? isAgencyRequest;
  final bool? isFirst;
  final int? familyId;
  final int? specialId;
  final String? uuid;
  final String? notificationId;
  final String? bio;
  final bool? hasRoom;
  final bool? isFacebook;
  final bool? isGoogle;
  final bool? isPhone;
  final int? myType;
  final bool? isHideRoom;
  final String? onlineTime;
  final bool? isCountryHidden;
  final bool? lastActiveHidden;
  final bool? visitHidden;
  final bool? hasColorName;
  final bool? hasAntiBan;
  final bool? isAnonymous;
  final NowRoomEntity? nowRoom;
  final bool? isGold;
  final int? unReadMessageCount;
  final CountryEntity? country;
  final bool? isGameAvailable;
  final bool? showInvitationCode;
  final CloseEffectEntity? roomEffects;
  final ManagerTypeEntity? managerTypeModel;
  final String? soundEffectColor;
  final bool? viewInvitation;
  final String? authToken;
  final String? familyPrice;
  final String? companyNumber;
  final String? profileFrame;
  final String? profileFrameId;
  final MyRoomEntity? myRoomData;
  final List<MultiImagesEntity>? multiImages;
  final List<String>? achievementImages;
  final UnreadCounterEntity? unreadCounterEntity;
  final ImageColorEntity? imageColorEntity;
  final bool? newGift;
  final WabbleEntity? wabbleEntity;
  final List<int>? userTypes;
  final int? wabbleId;

  const MyDataEntity(
      {this.id,
      this.chatId,
      this.uid,
      this.name,
      this.email,
      this.phone,
      this.userTypes,
      this.numberOfFans,
      this.numberOfFollowings,
      this.numberOfFriends,
      this.profileVisitors,
      this.totalViews,
      this.profile,
      this.level,
      this.vip1,
      this.familyDataModel,
      this.userAgencyStates,
      this.myStore,
      this.frame,
      this.frameType,
      this.intro,
      this.introType,
      this.frameId,
      this.vipTargetId,
      this.introId,
      this.bubbleId,
      this.bubble,
      this.myAgencyModel,
      this.myShippingAgencyEntity,
      this.isAgencyRequest,
      this.isFirst,
      this.familyId,
      this.uuid,
      this.notificationId,
      this.bio,
      this.hasRoom,
      this.isFacebook,
      this.isGoogle,
      this.isPhone,
      this.companyNumber,
      this.myType,
      this.isHideRoom,
      this.onlineTime,
      this.isCountryHidden,
      this.lastActiveHidden,
      this.visitHidden,
      this.hasColorName,
      this.hasAntiBan,
      this.isAnonymous,
      this.nowRoom,
      this.isGold,
      this.unReadMessageCount,
      this.country,
      this.isGameAvailable,
      this.showInvitationCode,
      this.roomEffects,
      this.managerTypeModel,
      this.soundEffectColor,
      this.viewInvitation,
      this.authToken,
      this.familyPrice,
      this.multiImages,
      this.myRoomData,
      this.unreadCounterEntity,
      this.achievementImages,
      this.specialId,
      this.specialIdImage,
      this.specialIdColor,
      this.profileFrame,
      this.profileFrameId,
      this.imageColorEntity,
      this.newGift,
      this.wabbleEntity,
      this.wabbleId});

  @override
  List<Object?> get props => [
        viewInvitation,
        id,uid,
        chatId,
        name,
        email,
        phone,
        userTypes,
        numberOfFans,
        numberOfFollowings,
        numberOfFriends,
        profileVisitors,
        totalViews,
        profile,
        level,
        vip1,
        familyDataModel,
        myStore,
        companyNumber,
        frame,
        frameType,
        intro,
        userAgencyStates,
        introType,
        frameId,
        vipTargetId,
        introId,
        bubbleId,
        specialId,
        specialIdImage,
        specialIdColor,
        bubble,
        myAgencyModel,
        myShippingAgencyEntity,
        isAgencyRequest,
        isFirst,
        familyId,
        uuid,
        notificationId,
        bio,
        hasRoom,
        isFacebook,
        isGoogle,
        isPhone,
        myType,
        isHideRoom,
        onlineTime,
        isCountryHidden,
        lastActiveHidden,
        visitHidden,
        hasColorName,
        hasAntiBan,
        isAnonymous,
        nowRoom,
        isGold,
        unReadMessageCount,
        country,
        isGameAvailable,
        showInvitationCode,
        roomEffects,
        managerTypeModel,
        soundEffectColor,
        authToken,
        familyPrice,
        multiImages,
        myRoomData,
        unreadCounterEntity,
        achievementImages,
        profileFrame,
        profileFrameId,
        imageColorEntity,
        newGift,
        wabbleEntity,
        wabbleId
      ];
}

class MyRoomEntity extends Equatable {
  final int id;
  final String name;
  final String cover;
  final String background;
  final String giftPrice;
  final int mode;
  final dynamic ownerUuid;
  final int isPk;
  final int showPk;
  final bool passwordStatus;
  final String typeName;
  final String typeImg;

  const MyRoomEntity({
    required this.id,
    required this.name,
    required this.cover,
    required this.background,
    required this.giftPrice,
    required this.mode,
    required this.ownerUuid,
    required this.isPk,
    required this.showPk,
    required this.passwordStatus,
    required this.typeName,
    required this.typeImg,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        cover,
        background,
        giftPrice,
        mode,
        ownerUuid,
        isPk,
        showPk,
        passwordStatus,
        typeName,
        typeImg,
      ];
}

class ImageColorEntity extends Equatable {
  final int? id;
  final String? name;
  final String? image;
  final String? color;
  final String? createdAt;
  final String? updatedAt;

  const ImageColorEntity({
    this.id,
    this.name,
    this.image,
    this.color,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        image,
        color,
        createdAt,
        updatedAt,
      ];
}

class WabbleEntity extends Equatable {
  final int? id;
  final String? image;
  final String? imageType;
  final String? key;

  const WabbleEntity({
    this.id,
    this.image,
    this.imageType,
    this.key,
  });

  @override
  List<Object?> get props => [id, image, imageType, key];
}
