import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/domain/entities/my_data_entity.dart';

class RoomEntity extends Equatable {
  final int? id;
  final String? roomId;
  final String? name;
  final int? visitorsCount;
  final String? cover;
  final String? roomBackground;
  final String? type;
  final int? isHot;
  final int? isPopular;
  final String? roomIntro;
  final int? isRecommended;
  final int? ownerId;
  final String? mode;
  final String? lang;
  final CountryRoomEntity? country;
  final AgencyEntity? agency;
  final GameEntity? game;
  final bool? passwordStatus;
  final bool? isPK;
  final bool? isBoxLucky;
  final List<String>? visitorsImages;
  final String? giftPrice;
  final String? uuidOwnerRoom;
  final List<String>? achievementImages;
  final String? ownerSpecialId;
  final ImageColorEntity? ownerImageColor;
  final bool? hasLuckyBox;
  final bool? isCountryHidden;
  final String? streamType;
  final bool? isLive;
  final String? ownerName;
  final String? ownerImage;
  final String? roomType;
  final String? roomRule;
  final String? roomLevelImage;
  final String? luckyGiftCoins;

  const RoomEntity({
    this.id,
    this.roomId,
    this.type,
    this.name,
    this.visitorsCount,
    this.cover,
    this.isBoxLucky,
    this.isHot,
    this.isPK,
    this.isPopular,
    this.roomIntro,
    this.isRecommended,
    this.ownerId,
    this.country,
    this.lang,
    this.mode,
    this.roomBackground,
    this.passwordStatus,
    this.game,
    this.visitorsImages,
    this.giftPrice,
    this.uuidOwnerRoom,
    this.achievementImages,
    this.ownerSpecialId,
    this.ownerImageColor,
    this.hasLuckyBox,
    this.isCountryHidden,
    this.streamType,
    this.isLive,
    this.ownerName,
    this.ownerImage,
    this.agency,
    this.roomType,
    this.roomRule,
    this.roomLevelImage,
    this.luckyGiftCoins,
  });

  @override
  List<Object?> get props => [
        id,
        roomId,
        name,
        visitorsCount,
        cover,
        type,
        isHot,
        isPopular,
        roomIntro,
        isRecommended,
        ownerId,
        lang,
        mode,
        country,
        passwordStatus,
        isPK,
        isBoxLucky,
        game,
        roomBackground,
        visitorsImages,
        giftPrice,
        uuidOwnerRoom,
        achievementImages,
        ownerSpecialId,
        ownerImageColor,
        hasLuckyBox,
        isCountryHidden,
        streamType,
        isLive,
        ownerImage,
        agency,
        ownerName,
        roomType,
        roomRule,
        roomLevelImage,
        luckyGiftCoins,
      ];
}

class CountryRoomEntity extends Equatable {
  final int id;
  final String name;
  final String flag;
  final String phoneCode;
  final String lang;

  const CountryRoomEntity({
    required this.id,
    required this.phoneCode,
    required this.lang,
    required this.name,
    required this.flag,
  });

  @override
  List<Object?> get props => [id, name, flag, phoneCode, lang];
}

class GameEntity extends Equatable {
  final int? id;
  final String? name;
  final String? image;
  final String? url;
  final bool? webViewConfig;
  final int? highSafety;

  const GameEntity({
    this.id,
    this.name,
    this.image,
    this.url,
    this.webViewConfig,
    this.highSafety,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        image,
        url,
        webViewConfig,
        highSafety,
      ];
}

class AgencyEntity extends Equatable {
  final int id;
  final String name;

  const AgencyEntity({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}
