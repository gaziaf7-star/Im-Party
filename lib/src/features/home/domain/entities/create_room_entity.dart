import 'package:equatable/equatable.dart';

class CreateRoomEntity extends Equatable {
  final int id;
  final int ownerId;
  final String ownerUuid;
  final String ownerName;
  final String ownerImage;
  final String roomId;
  final String ownerSpecialId;
  final String name;
  final int mode;
  final int visitorsCount;
  final String cover;
  final int isHot;
  final String session;
  final String giftPrice;
  final int isPopular;
  final dynamic roomStatus;
  final bool passwordStatus;
  final String roomIntro;
  final String maxAdmin;
  final int isRecommended;
  final String lang;
  final bool isPk;
  final bool isParty;
  final dynamic roomBackground;
  final String streamType;
  final bool isLive;
  final bool isLuckyBox;
  final bool haveLuckBox;
  final bool countryHidden;
  final String roomUsers;
  final dynamic background;
  final int isMicsFree;
  final dynamic classType;
  final dynamic type;
  final dynamic mics;
  final Map<String, dynamic> ownerImageColor;
  final Map<String, dynamic> country;
  final String createdAt;

  const CreateRoomEntity({
    required this.id,
    required this.ownerId,
    required this.ownerUuid,
    required this.ownerName,
    required this.ownerImage,
    required this.roomId,
    required this.ownerSpecialId,
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
    required this.haveLuckBox,
    required this.countryHidden,
    required this.roomUsers,
    required this.background,
    required this.isMicsFree,
    required this.classType,
    required this.type,
    required this.mics,
    required this.ownerImageColor,
    required this.country,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        ownerId,
        ownerUuid,
        ownerName,
        ownerImage,
        roomId,
        ownerSpecialId,
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
        haveLuckBox,
        countryHidden,
        roomUsers,
        background,
        isMicsFree,
        classType,
        type,
        mics,
        ownerImageColor,
        country,
        createdAt,
      ];
}
