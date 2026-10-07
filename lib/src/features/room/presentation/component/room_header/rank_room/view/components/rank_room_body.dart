part of 'package:general/src/features/room/presentation/component/room_header/rank_room/view/rank_room_page.dart';

class _RankingRoomBody extends StatelessWidget {
  final TabController headerTabController;
  final TabController outerTabController;
  final EnterRoomModel roomData;
  final RankingEntity? dayUsersRank;
  final RequestState dayState;
  final RankingEntity? weekUsersRank;
  final RequestState weekState;
  final RankingEntity? monthUsersRank;
  final RequestState monthState;
  final int index;

  const _RankingRoomBody({
    required this.roomData,
    required this.headerTabController,
    required this.outerTabController,
    required this.dayUsersRank,
    required this.dayState,
    required this.weekUsersRank,
    required this.weekState,
    required this.monthUsersRank,
    required this.monthState,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TabBarBody(
          controller: headerTabController,
          index: index,
        ),
        _UsersBody(
          dataController: headerTabController,
          roomModel: roomData,
          dayState: dayState,
          dayUsersRank: dayUsersRank,
          weekState: weekState,
          weekUsersRank: weekUsersRank,
          monthState: monthState,
          monthUsersRank: monthUsersRank,
          outerTabController: outerTabController,
        ),
      ],
    );
  }
}

class LeaderboardCardWidget extends StatelessWidget {
  final FamilyRankEntity? familyRankEntity;
  final UserTopEntity? userTopEntity;
  final String frameImage;
  final bool isFamily, isUpper;
  final bool? isRoom;
  final bool? isCharm;
  final bool? isWealth;
  final bool? isRoomRank;
  final bool? isCp;

  const LeaderboardCardWidget({
    this.familyRankEntity,
    this.userTopEntity,
    // required this.backgroundImage,
    required this.frameImage,
    this.isFamily = true,
    this.isUpper = false,
    this.isRoom,
    this.isCharm,
    this.isWealth,
    this.isRoomRank,
    this.isCp,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isUpper) (isRoom ?? false) ? 50.hBox : 100.hBox,
        Container(
          width: 104.w,
          margin: context.paddingSymmetric(horizontal: 3),
          padding: context.paddingSymmetric(horizontal: 7),
          clipBehavior: Clip.none,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    (isUpper) ? 110.hBox : 35.hBox,
                    SizedBox(
                      width: 120.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          (isUpper) ? 10.hBox : 80.hBox,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: TextWidget(
                                  isFamily
                                      ? familyRankEntity?.name ?? ''
                                      : userTopEntity?.name ?? '',
                                  style: context.bodyMedium,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          3.hBox,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if ((userTopEntity?.flag ?? '') != '')
                                CountryIcon(country: userTopEntity!.flag!),
                              5.wBox,
                              LevelContainer(
                                //level: userTopEntity?.senderLevel ?? 0,
                                image: isCharm == true
                                    ? userTopEntity?.senderImage
                                    : userTopEntity?.receiverImage,
                                isComment: true,
                                // height: 10.h,
                                // width: 30.w,
                              ),
                              5.wBox,
                              if (userTopEntity?.vipLevelImage != null &&
                                  userTopEntity?.vipLevelImage != '' &&
                                  isCp != true)
                                VipContainer(
                                  //level: userTopEntity?.senderLevel ?? 0,
                                  vip: userTopEntity?.vipLevelImage,
                                  isComment: true,
                                  height: 10.h,
                                  width: 30.w,
                                ),
                            ],
                          ),
                          3.hBox,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: TextWidget(
                                  userTopEntity?.exp.toString()??'',
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: context.bodyMedium
                                      .size(12)
                                      .w700,
                                ),
                              ),
                            isWealth??false ? ImageWidget(height: 20.h, width: 20.w, image: AssetsManager.coinIcon):
                            ImageWidget(height: 20.h, width: 20.w, image: AssetsManager.diamondIcon)
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              Positioned(
                top: isRoom ?? false ? 10.w : -50.w,
                right: 0,
                left: 0,
                child: GestureDetector(
                  onTap: () {
                    if (isFamily) {
                      if (familyRankEntity != null &&
                          familyRankEntity?.id != 0) {
                        Navigator.pushNamed(context, Routes.familyScreen,
                            arguments: familyRankEntity!.id.toString());
                      }
                    } else {
                      if (userTopEntity != null && userTopEntity?.userId != 0) {
                        Methods().userProfileNavigator(
                          context: context,
                          userId: '${userTopEntity?.userId}',
                        );
                      }
                    }
                  },
                  child: UserImage(
                    image: isFamily
                        ? '${familyRankEntity?.img}'
                        : '${userTopEntity?.avatar}',
                    displayName: isFamily
                        ? (familyRankEntity?.name ?? '')
                        : (userTopEntity?.name ?? ''),
                    frame: frameImage,
                    imageSize: 65.w,
                    uniquId: isFamily
                        ? '${familyRankEntity?.id}'
                        : '${userTopEntity?.userId}',
                    frameSize: 110.w,
                    isAsset: true,
                    boxFit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
