part of '../rank_screen.dart';

class UserInfoRankWidget extends StatelessWidget {
  final UserTopEntity? userTopEntity;
  final void Function()? onTap;
  final int index;
  final bool? isSender;
  final bool? isWealth;
  final bool? isCharm;
  final bool? isRoom;

  const UserInfoRankWidget({
    this.onTap,
    required this.userTopEntity,
    super.key,
    required this.index,
    required this.isSender,
    required this.isRoom,
    this.isWealth,
    this.isCharm,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: 5.radius,
      onTap: onTap ??
          () {
            if (isRoom ?? false) {
              if (userTopEntity?.roomEntity != null) {
                di<RoomStateManager>().navigateToRoom(
                  RoomEntryRequest(
                    context: context,
                    roomData: RoomEntity(
                      passwordStatus:
                          userTopEntity?.roomEntity?.passwordStatus ?? false,
                      ownerId: userTopEntity?.userId,
                      id: userTopEntity?.roomEntity?.id ?? 0,
                      name: userTopEntity?.roomEntity?.name ?? "",
                      cover: userTopEntity?.roomEntity?.cover ?? "",
                      roomBackground: userTopEntity?.roomEntity?.background ?? "",
                      mode: userTopEntity?.roomEntity?.mode.toString() ?? '',
                      uuidOwnerRoom: userTopEntity?.roomEntity?.ownerUuid ?? "",
                      giftPrice: userTopEntity?.roomEntity?.giftPrice ?? "",
                    ),
                    isLive: false,
                  ),
                );
              }
            } else {
              Methods().userProfileNavigator(
                context: context,
                userId: '${userTopEntity?.userId}',
              );
            }
          },
      child: Container(
        padding: context.paddingSymmetric(
          horizontal: 10,
          vertical: 10,
        ),
        margin: context.paddingOnly(
          bottom: 6.0,
        ),
        decoration: BoxDecoration(
          borderRadius: 5.radius,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget(
              '$index',
              style:
                  context.bodyMedium.w700.colorExt(ColorManager.textPrimary),
            ),
            10.wBox,
            UserImage(
              boxFit: BoxFit.cover,
              image: userTopEntity?.avatar ?? "",
              displayName: userTopEntity?.name ?? '',
              imageSize: 55,
              borderRadius: isRoom == true ? 8.radius : null,
            ),
            15.wBox,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GradientTextVip(
                    isVip: (userTopEntity?.colorName ?? '').isNotEmpty,
                    width: 150.w,
                    text: '${userTopEntity?.name}',
                    color: _getColor(userTopEntity?.colorName),
                    mainAxisAlignment: MainAxisAlignment.center,
                    textAlign: TextAlign.center,
                    textStyle: context.bodyMedium
                        .size(14)
                        .bold
                        .colorExt(
                          _getColor(userTopEntity?.colorName),
                        )
                        .copyWith(overflow: TextOverflow.ellipsis),
                  ),
                  5.hBox,
                  if (isRoom != true)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LevelContainer(
                            image: userTopEntity?.receiverImage,
                            isComment: true,
                          ),
                          5.wBox,
                          LevelContainer(
                            image: userTopEntity?.senderImage,
                            isComment: true,
                          ),
                          5.wBox,
                          if (userTopEntity?.vipLevelImage != null &&
                              userTopEntity?.vipLevelImage != '')
                            VipContainer(
                              vip: userTopEntity?.vipLevelImage,
                              isComment: true,
                              boxFit: BoxFit.fill,
                              height: 25.h,
                              width: 25.w,
                            ),
                          3.wBox,
                          if ((userTopEntity?.dataAchievement ?? []).isNotEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                (userTopEntity?.dataAchievement ?? []).length,
                                (index) {
                                  return Padding(
                                    padding:
                                        context.paddingSymmetric(horizontal: 2),
                                    child: (userTopEntity
                                                    ?.dataAchievement?[index]
                                                    .image ??
                                                '')
                                            .contains('.svga')
                                        ? CacheSvgaWidget(
                                            url: userTopEntity
                                                    ?.dataAchievement?[index]
                                                    .image ??
                                                '',
                                            height: 25.h,
                                            width: 25.w,
                                          )
                                        : ImageViewWidget(
                                            url: userTopEntity
                                                    ?.dataAchievement?[index]
                                                    .image ??
                                                '',
                                            height: 25.h,
                                            width: 25.w,
                                          ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            5.wBox,
            TextWidget(
              '${userTopEntity?.exp ?? 0}',
              style: context.bodySmall.bold
                  .colorExt(isRoom == true
                      ? const Color(0xffFAAE51)
                      : isWealth == true
                          ? const Color(0xffFEB04C)
                          : const Color(0xffF54E77))
                  .size(13),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            5.wBox,
            isWealth == true
                ? ImageWidget(
                    height: 20.h,
                    width: 20.w,
                    image: AssetsManager.rankWealthIcon,
                  )
                : isCharm == true
                    ? ImageWidget(
                        height: 20.h,
                        width: 17.w,
                        image: AssetsManager.rankHeartIcon,
                      )
                    : isRoom == true
                        ? ImageWidget(
                            height: 25.h,
                            width: 23.w,
                            image: AssetsManager.roomRankCoin,
                          )
                        : ImageWidget(
                            height: 22.h,
                            width: 19.w,
                            image: AssetsManager.gameIconRank,
                          ),
          ],
        ),
      ),
    );
  }

  Color _getColor(String? colorName) {
    return Methods.safeHexColor(colorName) ?? ColorManager.white;
  }
}
