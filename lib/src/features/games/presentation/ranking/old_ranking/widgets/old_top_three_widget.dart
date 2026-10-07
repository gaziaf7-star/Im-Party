part of '../old_rank_screen.dart';

class OldTopThreeWidget extends StatelessWidget {
  final List<UserTopEntity> usersEntity;
  final String imageRank;
  final bool? isRoom;
  final bool? isCharm;
  final bool? isWealth;
  final bool? isRoomRank;
  final bool? isCp;
  final bool? isNeedSmallIcon;
  final void Function()? onTapImage;
  final Color? nameColor;
  final bool isPhoto;

  const OldTopThreeWidget({
    super.key,
    this.usersEntity = const [],
    required this.imageRank,
    required this.isPhoto,
    this.isRoom,
    this.nameColor,
    this.isNeedSmallIcon,
    this.isCharm,
    this.isWealth,
    this.isRoomRank,
    this.isCp,
    this.onTapImage,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 420.h,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: AlignmentDirectional.center,
        children: [
          Positioned(
            top: -15.h,
            child: OldItemRankTopThree(
              userTopEntity: usersEntity.isNotEmpty ? usersEntity[0] : null,
              frameImage: isCharm == true
                  ? AssetsManager.charmRank1Frame
                  : isWealth == true
                      ? AssetsManager.wealthRank1Frame
                      : isRoomRank == true
                          ? AssetsManager.roomRank1Frame
                          : AssetsManager.gameRank1Frame,
              assetImage: isCharm == true
                  ? AssetsManager.rankCharmFrame1
                  : isWealth == true
                      ? AssetsManager.rankWealthFrame1
                      : isRoomRank == true
                          ? AssetsManager.rankRoomFrame1
                          : AssetsManager.rankGamesFrame1,
              isUpper: true,
              isFamily: false,
              isRoom: true,
              isRoomRank: isRoomRank,
              isCharm: isCharm,
              isCp: isCp,
              isWealth: isWealth,
              isNeedSmallIcon: isNeedSmallIcon,
              onTapImage: onTapImage,
              nameColor: nameColor,
              isPhoto: isPhoto,
            ),
          ),
          Positioned(
            bottom: 0.h,
            child: SizedBox(
              width: ScreenUtil().screenWidth,
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Align(
                    alignment: AlignmentDirectional.topStart,
                    child: OldItemRankTopThree(
                      userTopEntity:
                          usersEntity.length > 1 ? usersEntity[1] : null,
                      frameImage: isCharm == true
                          ? AssetsManager.charmRank2Frame
                          : isWealth == true
                              ? AssetsManager.wealthRank2Frame
                              : isRoomRank == true
                                  ? AssetsManager.roomRank2Frame
                                  : AssetsManager.gameRank2Frame,
                      assetImage: isCharm == true
                          ? AssetsManager.rankCharmFrame2
                          : isWealth == true
                              ? AssetsManager.rankWealthFrame2
                              : isRoomRank == true
                                  ? AssetsManager.rankRoomFrame2
                                  : AssetsManager.rankGamesFrame2,
                      isFamily: false,
                      isRoom: true,
                      isRoomRank: isRoomRank,
                      isCharm: isCharm,
                      isCp: isCp,
                      isWealth: isWealth,
                      isNeedSmallIcon: isNeedSmallIcon,
                      onTapImage: onTapImage,
                      nameColor: nameColor,
                      isPhoto: isPhoto,
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: OldItemRankTopThree(
                      userTopEntity:
                          usersEntity.length > 2 ? usersEntity[2] : null,
                      frameImage: isCharm == true
                          ? AssetsManager.charmRank3Frame
                          : isWealth == true
                              ? AssetsManager.wealthRank3Frame
                              : isRoomRank == true
                                  ? AssetsManager.roomRank3Frame
                                  : AssetsManager.gameRank3Frame,
                      assetImage: isCharm == true
                          ? AssetsManager.rankCharmFrame3
                          : isWealth == true
                              ? AssetsManager.rankWealthFrame3
                              : isRoomRank == true
                                  ? AssetsManager.rankRoomFrame3
                                  : AssetsManager.rankGamesFrame3,
                      isFamily: false,
                      isRoom: true,
                      isRoomRank: isRoomRank,
                      isCharm: isCharm,
                      isCp: isCp,
                      isWealth: isWealth,
                      isNeedSmallIcon: isNeedSmallIcon,
                      onTapImage: onTapImage,
                      nameColor: nameColor,
                      isPhoto: isPhoto,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
