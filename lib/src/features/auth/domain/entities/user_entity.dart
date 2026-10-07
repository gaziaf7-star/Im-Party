import 'package:equatable/equatable.dart';
import 'package:general/src/features/auth/auth.dart';

class UserEntity extends Equatable {
  final int? id;
  final String? chatId;
  final String? name;
  final int? wabbleId;
  final bool? isFollow;
  final bool? isFollowingMe;
  final ProfileRoomEntity? profile;
  final NowRoomEntity? nowRoom;
  final NowRoomEntity? room;
  final LevelEntity? level;
  final VipCenterEntity? vip;
  final String? frame;
  final String? frameType;
  final String? intro;
  final String? introType;
  final int? frameId;
  final int? introId;
  final int? bubbleId;
  final num? specialId;
  final String? idImage;
  final String? bubble;
  final MyHostsAgencyEntity? myAgency;
  final MyShippingAgencyEntity? myShippingAgency;
  final bool? isAgencyRequest;
  final bool? isFriend;
  final bool? isFirst;
  final int? familyId;
  final FamilyEntity? familyData;
  final String? uuid;
  final String? notificationId;
  final String? bio;
  final String? colorName;
  final String? companyNumber;
  final CountryEntity? country;
  final int? userType;
  final int? numberOfFans;
  final int? numberOfFollowings;
  final int? numberOfFriends;
  final int? profileVisitors;
  final int? totalViews;
  final String? profileFrameId;
  final bool? lastActiveHidden;
  final bool? visitHidden;
  final bool? roomHidden;
  final bool? hasColorName;
  final bool? hasAntiBan;
  final bool? isAnonymous;
  final String? onlineTime;
  final bool? online;
  final String? lastSeenAt;
  final bool? isCountryHidden;
  final bool? isGold;
  final String? visitTime;
  final bool? isGameAvailable;
  final bool? showInvitationCode;
  final ManagerTypeEntity? managerType;
  final int? myType;
  final String? soundEffectColor;
  final ChatSettingsEntity? chatSettings;
  final StatisticEntity? statistic;
  final MyStoreEntity? myStore;
  final List<MultiImagesEntity>? images;
  final List<MultiImagesEntity>? imagesSupport;
  final List<String>? achievementImages;
  final List<int>? userTypes;
  final ImageColorEntity? imageColorEntity;

  const UserEntity({
    this.id,
    this.chatId,
    this.name,
    this.wabbleId,
    this.isFollow,
    this.isFollowingMe,
    this.profile,
    this.nowRoom,
    this.room,
    this.level,
    this.colorName,
    this.vip,
    this.frame,
    this.frameType,
    this.intro,
    this.introType,
    this.frameId,
    this.introId,
    this.bubbleId,
    this.specialId,
    this.idImage,
    this.bubble,
    this.myAgency,
    this.myShippingAgency,
    this.isAgencyRequest,
    this.isFriend,
    this.isFirst,
    this.familyId,
    this.familyData,
    this.uuid,
    this.notificationId,
    this.bio,
    this.companyNumber,
    this.country,
    this.userType,
    this.numberOfFans,
    this.numberOfFollowings,
    this.numberOfFriends,
    this.profileVisitors,
    this.totalViews,
    this.lastActiveHidden,
    this.visitHidden,
    this.roomHidden,
    this.hasColorName,
    this.hasAntiBan,
    this.isAnonymous,
    this.onlineTime,
    this.online,
    this.lastSeenAt,
    this.isCountryHidden,
    this.isGold,
    this.visitTime,
    this.isGameAvailable,
    this.showInvitationCode,
    this.managerType,
    this.myType,
    this.soundEffectColor,
    this.chatSettings,
    this.statistic,
    this.myStore,
    this.images,
    this.imagesSupport,
    this.achievementImages,
    this.userTypes,
    this.imageColorEntity,
    this.profileFrameId,
  });

  @override
  List<Object?> get props => [
        id,
        chatId,
        name,
        wabbleId,
        isFollow,
        isFollowingMe,
        profile,
        nowRoom,
        room,
        level,
        colorName,
        vip,
        frame,
        intro,
        introType,
        frameId,
        frameType,
        introId,
        bubbleId,
        specialId,
        idImage,
        bubble,
        myAgency,
        myShippingAgency,
        isAgencyRequest,
        isFriend,
        isFirst,
        familyId,
        familyData,
        uuid,
        notificationId,
        bio,
        companyNumber,
        country,
        userType,
        numberOfFans,
        numberOfFollowings,
        numberOfFriends,
        profileVisitors,
        totalViews,
        lastActiveHidden,
        visitHidden,
        roomHidden,
        hasColorName,
        hasAntiBan,
        isAnonymous,
        onlineTime,
        online,
        lastSeenAt,
        isCountryHidden,
        isGold,
        visitTime,
        isGameAvailable,
        showInvitationCode,
        managerType,
        myType,
        soundEffectColor,
        chatSettings,
        statistic,
        myStore,
        images,
        imagesSupport,
        achievementImages,
        userTypes,
        imageColorEntity,
        profileFrameId,
      ];
}
