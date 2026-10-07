part of '../rank_screen.dart';

class TopThreeWidget extends StatelessWidget {
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

  const TopThreeWidget({
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
    if (usersEntity.isEmpty) {
      return const EmptyStateWidget();
    }
    return SizedBox(
        height: 350.h,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: AlignmentDirectional.center,
          children: [
            // 🥇 Rank 1 (top center)
            Positioned(
              top: 20.h,
              child: ItemRankTopThree(
                userTopEntity: usersEntity.isNotEmpty ? usersEntity[0] : null,
                frameImage: AssetsManager.top1Frame,
                background: AssetsManager.top1Bg,
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

            // 🥈 and 🥉 Rank 2 & 3
            Positioned(
              bottom: -30.h,
              child: SizedBox(
                width: ScreenUtil().screenWidth - 50,
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    // 🥈 Left side (Rank 2)
                    Align(
                      alignment: AlignmentDirectional.topStart,
                      child: ItemRankTopThree(
                        userTopEntity:
                            usersEntity.length > 1 ? usersEntity[1] : null,
                        frameImage: AssetsManager.top2Frame,
                        background: AssetsManager.top2Bg,
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

                    // 🥉 Right side (Rank 3)
                    Align(
                      alignment: AlignmentDirectional.topEnd,
                      child: ItemRankTopThree(
                        userTopEntity:
                            usersEntity.length > 2 ? usersEntity[2] : null,
                        frameImage: AssetsManager.top3Frame,
                        background: AssetsManager.top3Bg,
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
        ));
  }
}
