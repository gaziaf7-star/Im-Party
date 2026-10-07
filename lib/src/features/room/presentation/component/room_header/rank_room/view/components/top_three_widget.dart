part of '../rank_room_page.dart';

class TopThreeWidget extends StatelessWidget {
  final List<UserTopEntity> usersEntity;
  final String imageRank;
  final bool? isRoom;
  final bool? isCharm;
  final bool? isWealth;
  final bool? isRoomank;
  final bool? isCp;

  const TopThreeWidget({
    super.key,
    this.usersEntity = const [],
    required this.imageRank,
    this.isRoom,
    this.isCharm,
    this.isWealth,
    this.isRoomank,
    this.isCp,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 275.h,
      child: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 5.h),
            child: ItemRankTopThree(
              userEntity: usersEntity.isNotEmpty ? usersEntity[0] : null,
              frameImage: AssetsManager.helRoomRank1,
              isUpper: true,
              isFamily: false,
              isRoom: true,
              isRoomRank: isRoomank,
              isCharm: isCharm,
              isCp: isCp,
              isWealth: isWealth,
            ),
          ),
          Positioned(
            left: -15.h,
            bottom: 10.h,
            child: ItemRankTopThree(
              userEntity: usersEntity.length > 2 ? usersEntity[1] : null,
              frameImage: AssetsManager.helRoomRank2,
              isFamily: false,
              isRoom: true,
              isRoomRank: isRoomank,
              isCharm: isCharm,
              isCp: isCp,
              isWealth: isWealth,
            ),
          ),
          Positioned(
            right: -15.h,
            bottom: 10.h,
            child: ItemRankTopThree(
              userEntity: usersEntity.length > 2 ? usersEntity[2] : null,
              frameImage: AssetsManager.helRoomRank3,
              isFamily: false,
              isRoom: true,
              isRoomRank: isRoomank,
              isCharm: isCharm,
              isCp: isCp,
              isWealth: isWealth,
            ),
          ),
        ],
      ),
    );
  }
}/*  Align(
                    alignment: AlignmentDirectional.topStart,
                    child: ItemRankTopThree(
                      userTopEntity:
                          usersEntity.length > 2 ? usersEntity[1] : null,
                      frameImage: isCharm==true
                          ? AssetsManager.charmRank2Frame
                          : isWealth==true
                          ? AssetsManager.wealthRank2Frame
                          : AssetsManager.roomRank2Frame,
                      isFamily: false,
                      isRoom: true,
                      isRoomRank: isRoomank,
                      isCharm: isCharm,
                      isCp: isCp,
                      isWealth: isWealth,
                    ),
                  ),

                  ),*/