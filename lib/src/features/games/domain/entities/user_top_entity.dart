import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';


class UserTopEntity extends Equatable {
  final dynamic exp;
  final int? userId;
  final int? senderLevel;
  final int? receiverLevel;
  final String? avatar;
  final String? name;
  final String? frame;
  final dynamic frameId;
  final String? senderImage;
  final String? flag;
  final String? receiverImage;
  final String? gender;
  final int? vipLevel;
  final String? vipLevelImage;
  final int? userType;
  final int? levelVip;
  final String? colorName;
  final ManagerTypeEntity? managerTypeEntity;
  final MyRoomEntity? roomEntity;
  final List<AchievementDataEntity>? dataAchievement;

  const UserTopEntity({
    this.exp,
    this.userId,
    this.colorName,
    this.flag,
    this.avatar,
    this.levelVip,
    this.dataAchievement,
    this.senderLevel,
    this.receiverLevel,
    this.name,
    this.frame,
    this.frameId,
    this.userType,
    this.managerTypeEntity,
    this.vipLevel,
    this.senderImage,
    this.gender,
    this.receiverImage,
    this.vipLevelImage,
    this.roomEntity,
  });

  @override
  List<Object?> get props => [
        exp,
        userId,
        colorName,
        flag,
        avatar,
        levelVip,
        dataAchievement,
        senderLevel,
        receiverLevel,
        name,
        frame,
        frameId,
        userType,
        managerTypeEntity,
        vipLevel,
        senderImage,
        gender,
        receiverImage,
        vipLevelImage,
        vipLevelImage,
        roomEntity
      ];
}

class AchievementDataEntity extends Equatable {
  final String? image;

  const AchievementDataEntity({this.image});

  @override
  List<Object?> get props => [image];
}
