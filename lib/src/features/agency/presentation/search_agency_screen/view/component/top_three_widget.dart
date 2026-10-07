

import 'package:general/src/core/index.dart';

import '../../../../domain/entity/information_agency_entity.dart';
import 'item_rank_top_three.dart';

class TopThreeWidgetAgency extends StatelessWidget {
  final List<StarEntity> usersEntity;
  final String imageRank;
  final bool? isRoom;
  final bool? isCharm;
  final bool? isWealth;
  final bool? isRoomank;
  final bool? isCp;
  final bool? isNeedSmallIcon;
  final void Function()? onTapImage;
  final Color? nameColor;

  const TopThreeWidgetAgency({
    super.key,
    this.usersEntity = const [],
    required this.imageRank,
    this.isRoom,
    this.nameColor,
    this.isNeedSmallIcon,
    this.isCharm,
    this.isWealth,
    this.isRoomank,
    this.isCp,
    this.onTapImage,
  });

  @override
  Widget build(BuildContext context) {
    if (usersEntity.isEmpty) {
      return const EmptyStateWidget();
    }
    return SizedBox(
      height: isRoomank == true ? 420.h : 420.h,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: AlignmentDirectional.center,
        children: [
          Positioned(
            top: -30.h,
            child: ItemRankTopThreeAgency(
              userTopEntity: usersEntity.isNotEmpty ? usersEntity[0] : null,
              frameImage: isCharm == true
                  ? AssetsManager.charmRank1Frame
                  : isWealth == true
                      ? AssetsManager.wealthRank1Frame
                      : isRoomank == true
                          ? AssetsManager.roomRank1Frame
                          : AssetsManager.gameRank1Frame,
              isUpper: true,
              isFamily: false,
              isRoom: true,
              isRoomRank: isRoomank,
              isCharm: isCharm,
              isCp: isCp,
              isWealth: isWealth,
              isNeedSmallIcon: isNeedSmallIcon,
              onTapImage: onTapImage,
              nameColor: nameColor,
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
                    child: ItemRankTopThreeAgency(
                      userTopEntity:
                          usersEntity.length > 1 ? usersEntity[1] : null,
                      frameImage: isCharm == true
                          ? AssetsManager.charmRank2Frame
                          : isWealth == true
                              ? AssetsManager.wealthRank2Frame
                              : isRoomank == true
                                  ? AssetsManager.roomRank2Frame
                                  : AssetsManager.gameRank2Frame,
                      isFamily: false,
                      isRoom: true,
                      isRoomRank: isRoomank,
                      isCharm: isCharm,
                      isCp: isCp,
                      isWealth: isWealth,
                      isNeedSmallIcon: isNeedSmallIcon,
                      onTapImage: onTapImage,
                      nameColor: nameColor,
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: ItemRankTopThreeAgency(
                      userTopEntity:
                          usersEntity.length > 2 ? usersEntity[2] : null,
                      frameImage: isCharm == true
                          ? AssetsManager.charmRank3Frame
                          : isWealth == true
                              ? AssetsManager.wealthRank3Frame
                              : isRoomank == true
                                  ? AssetsManager.roomRank3Frame
                                  : AssetsManager.gameRank3Frame,
                      isFamily: false,
                      isRoom: true,
                      isRoomRank: isRoomank,
                      isCharm: isCharm,
                      isCp: isCp,
                      isWealth: isWealth,
                      isNeedSmallIcon: isNeedSmallIcon,
                      onTapImage: onTapImage,
                      nameColor: nameColor,
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
