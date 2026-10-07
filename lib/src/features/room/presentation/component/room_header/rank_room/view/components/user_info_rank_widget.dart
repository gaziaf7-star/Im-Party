part of '../rank_room_page.dart';

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
            Methods().userProfileNavigator(
              context: context,
              userId: '${userTopEntity?.userId}',
            );
          },
      child: Container(
        padding: context.paddingSymmetric(horizontal: 5, vertical: 5),
        margin: context.paddingOnly(
          bottom: 6.0,
        ),
        decoration: BoxDecoration(
            //color: ColorManager.white.withValues(alpha:0.15),
            borderRadius: 5.radius),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget(
              '$index',
              textAlign: TextAlign.center,
              style: context.bodyMedium.w700.colorExt(ColorManager.textPrimary),
            ),

            7.wBox,
            UserImage(
              boxFit: BoxFit.cover,
              image: userTopEntity?.avatar ?? "",
              displayName: userTopEntity?.name ?? "",
              imageSize: 44,
              borderRadius: isRoom == true ? 50.radius : null,
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
                    color: userTopEntity?.colorName != null &&
                            (userTopEntity?.colorName ?? '').isNotEmpty
                        ? Color((int.parse(
                            userTopEntity!.colorName!.replaceAll('#', '0xff'))))
                        : ColorManager.white,
                    mainAxisAlignment: MainAxisAlignment.center,
                    textAlign: TextAlign.center,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                      color: userTopEntity?.colorName != null &&
                              (userTopEntity?.colorName ?? '').isNotEmpty
                          ? Color((int.parse(userTopEntity!.colorName!
                              .replaceAll('#', '0xff'))))
                          : ColorManager.white,
                      fontSize: 14.sp,
                    ),
                  ),
                  // IntrinsicHeight(
                  //   child: Row(
                  //     children: [
                  //       SizedBox(
                  //         width: 150.w,
                  //         child: TextWidget(
                  //           userTopEntity?.name ?? "",
                  //           style: context.bodyMedium.bold,
                  //           overflow: TextOverflow.ellipsis,
                  //           maxLines: 1,
                  //         ),
                  //       ),
                  //       // GenderWidget(age: userTopEntity.,
                  //       //     gender: userTopEntity?.gender??''=='female'??0:1)
                  //     ],
                  //   ),
                  // ),
                  5.hBox,
                  if (isRoom != true)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // if ((userTopEntity?.flag ?? '') != '')
                          //   CountryIcon(country: userTopEntity!.flag!),
                          // 5.wBox,
                          LevelContainer(
                            //level: userTopEntity?.senderLevel ?? 0,
                            image: userTopEntity?.receiverImage,
                            isComment: true,
                            // height: 13.h,
                            // width: 30.w,
                          ),
                          5.wBox,
                          LevelContainer(
                            //level: userTopEntity?.senderLevel ?? 0,
                            image: userTopEntity?.senderImage,
                            isComment: true,
                            // height: 12.h,
                            // width: 30.w,
                          ),
                          5.wBox,
                          if (userTopEntity?.vipLevelImage != null &&
                              userTopEntity?.vipLevelImage != '')
                            VipContainer(
                              //level: userTopEntity?.senderLevel ?? 0,
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
                                  child: (userTopEntity?.dataAchievement?[index]
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
                                          //level: userTopEntity?.senderLevel ?? 0,
                                          url: userTopEntity
                                                  ?.dataAchievement?[index]
                                                  .image ??
                                              '',
                                          height: 25.h,
                                          width: 25.w,
                                        ),
                                );
                              }),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            //Image.asset(AssetsManager.rankHeart, scale: 3.5,),
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
                    height: 15.h, width: 15.w, image: AssetsManager.fire2)
                : isCharm == true
                    ? ImageWidget(
                        height: 15.h, width: 15.w, image: AssetsManager.fire2)
                    : ImageWidget(
                        height: 15.h, width: 15.w, image: AssetsManager.fire2),
          ],
        ),
      ),
    );
  }
}
