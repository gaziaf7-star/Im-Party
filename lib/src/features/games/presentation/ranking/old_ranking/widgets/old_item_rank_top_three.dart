part of '../old_rank_screen.dart';

class OldItemRankTopThree extends StatelessWidget {
  final FamilyRankEntity? familyRankEntity;
  final UserTopEntity? userTopEntity;
  final String frameImage;
  final bool isFamily, isUpper;
  final bool? isRoom;
  final bool? isCharm;
  final bool? isWealth;
  final bool? isNeedSmallIcon;
  final Color? nameColor;
  final bool? isRoomRank;
  final bool? isCp;
  final void Function()? onTapImage;
  final bool isPhoto;
  final String? assetImage;

  const OldItemRankTopThree({
    this.familyRankEntity,
    this.userTopEntity,
    required this.frameImage,
    required this.isPhoto,
    required this.assetImage,
    this.isFamily = true,
    this.isUpper = false,
    this.isRoom,
    this.isCharm,
    this.nameColor,
    this.isNeedSmallIcon = true,
    this.isWealth,
    this.isRoomRank,
    this.isCp,
    this.onTapImage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        GestureDetector(
          onTap: onTapImage ??
              () {
                if (isFamily) {
                  if (familyRankEntity != null && familyRankEntity!.id != 0) {
                    Navigator.pushNamed(context, Routes.familyScreen,
                        arguments: familyRankEntity!.id.toString());
                  }
                } else {
                  if (userTopEntity != null && userTopEntity!.userId != 0) {
                    if (isRoomRank ?? false) {
                      if (userTopEntity?.roomEntity != null) {
                        di<RoomStateManager>().navigateToRoom(
                          RoomEntryRequest(
                            context: context,
                            roomData: RoomEntity(
                              passwordStatus:
                                  userTopEntity?.roomEntity?.passwordStatus ??
                                      false,
                              ownerId: userTopEntity?.userId,
                              id: userTopEntity?.roomEntity?.id ?? 0,
                              name: userTopEntity?.roomEntity?.name ?? "",
                              cover: userTopEntity?.roomEntity?.cover ?? "",
                              roomBackground:
                                  userTopEntity?.roomEntity?.background ?? "",
                              mode: userTopEntity?.roomEntity?.mode.toString() ??
                                  '',
                              uuidOwnerRoom:
                                  userTopEntity?.roomEntity?.ownerUuid ?? "",
                              giftPrice:
                                  userTopEntity?.roomEntity?.giftPrice ?? "",
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
                  }
                }
              },
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              UserImage(
                image: isFamily
                    ? familyRankEntity?.img ?? ''
                    : userTopEntity?.avatar ?? '',
                displayName: isFamily
                    ? familyRankEntity?.name ?? ''
                    : userTopEntity?.name ?? '',
                imageSize: isUpper ? 75.h : 65.h,
                uniquId: isFamily
                    ? '${familyRankEntity?.id}'
                    : '${userTopEntity?.userId}',
                borderRadius:
                    isRoomRank == true ? BorderRadius.circular(2) : null,
                frameSize: 110.w,
                isAsset: true,
                boxFit: BoxFit.cover,
              ),
              ShowSVGA(
                svgaAssetPath: frameImage,
                height: isUpper ? 220.h : 180,
                width: isUpper ? 380.w : 200.w,
                fit: BoxFit.fill,
                isPhoto: isPhoto,
                pngImg: assetImage,
              ),
            ],
          ),
        ),
        Container(
          width: 150.w,
          margin: context.paddingSymmetric(horizontal: 3),
          clipBehavior: Clip.none,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              isUpper ? 185.hBox : 180.hBox,
              SizedBox(
                width: 270.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GradientTextVip(
                        isVip: (userTopEntity?.colorName ?? '').isNotEmpty,
                        width: 130.w,
                        text: userTopEntity?.name ?? '',
                        color: userTopEntity?.colorName != null &&
                                userTopEntity?.colorName != "NULL" &&
                                (userTopEntity?.colorName ?? '').isNotEmpty
                            ? Color((int.parse(userTopEntity!.colorName!
                                .replaceAll('#', '0xff'))))
                            : nameColor ?? ColorManager.black,
                        mainAxisAlignment: MainAxisAlignment.center,
                        textAlign: TextAlign.center,
                        textStyle: context.bodyMedium.size(15).w500.colorExt(
                              userTopEntity?.colorName != null &&
                                      userTopEntity?.colorName != "NULL" &&
                                      (userTopEntity?.colorName ?? '')
                                          .isNotEmpty
                                  ? Color((int.parse(userTopEntity!.colorName!
                                      .replaceAll('#', '0xff'))))
                                  : nameColor ?? ColorManager.white,
                            )),
                    if (nameColor != null)
                      TextWidget((userTopEntity?.userId ?? "").toString()),
                    if (isRoomRank == true) 5.hBox,
                    if (isRoomRank != true)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onHorizontalDragStart: (_) {},
                        onHorizontalDragUpdate: (_) {},
                        onHorizontalDragEnd: (_) {},
                        child: SingleChildScrollView(
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
                                  userTopEntity?.vipLevelImage != '' &&
                                  isCp != true)
                                VipContainer(
                                  vip: userTopEntity?.vipLevelImage,
                                  isComment: true,
                                  boxFit: BoxFit.fill,
                                  height: 25.h,
                                  width: 25.w,
                                ),
                              3.wBox,
                              if ((userTopEntity?.dataAchievement ?? [])
                                  .isNotEmpty)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    (userTopEntity?.dataAchievement ?? [])
                                        .length,
                                    (index) {
                                      return Padding(
                                        padding: context.paddingSymmetric(
                                            horizontal: 2),
                                        child: (userTopEntity
                                                        ?.dataAchievement?[
                                                            index]
                                                        .image ??
                                                    '')
                                                .contains('.svga')
                                            ? CacheSvgaWidget(
                                                url: userTopEntity
                                                        ?.dataAchievement?[
                                                            index]
                                                        .image ??
                                                    '',
                                                height: 25.h,
                                                width: 25.w,
                                              )
                                            : ImageViewWidget(
                                                url: userTopEntity
                                                        ?.dataAchievement?[
                                                            index]
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
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: TextWidget(
                            userTopEntity?.exp.toString() ?? '',
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: context.bodyMedium.w500
                                .colorExt(ColorManager.white),
                          ),
                        ),
                        3.wBox,
                        if (isNeedSmallIcon == true)
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
                                  : isRoomRank == true
                                      ? ImageWidget(
                                          height: 20.h,
                                          width: 17.w,
                                          image: AssetsManager.roomRankCoin,
                                        )
                                      : ImageWidget(
                                          height: 22.h,
                                          width: 19.w,
                                          image: AssetsManager.gameIconRank,
                                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
