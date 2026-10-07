part of '../family_rank_page.dart';

class TopThreeUsersItem extends StatelessWidget {
  final FamilyRankEntity? familyRankEntity;
  final UserTopEntity? userTopEntity;
  final bool isUpper;
  final String backImageAsset;
  final String frameImageAsset;
  final Widget? child;
  final double imageSize;
  final bool isFamily;

  const TopThreeUsersItem({
    this.familyRankEntity,
    this.userTopEntity,
    required this.isUpper,
    required this.backImageAsset,
    required this.frameImageAsset,
    required this.imageSize,
    this.isFamily = true,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (familyRankEntity != null && isFamily) {
          Navigator.pushNamed(context, Routes.familyScreen,
              arguments: (familyRankEntity!.id).toString());
        } else {
          Methods().userProfileNavigator(
              context: context,
              userId: (userTopEntity?.userId ?? 0).toString());
        }
      },
      child: Column(
        children: [
          !isUpper ? 80.hBox : 0.hBox,
          Stack(
            children: [
              SizedBox(
                width: ScreenUtil().screenWidth / 3,
                child: Column(
                  children: [
                    95.hBox,
                    Image.asset(
                      backImageAsset,
                      scale: 4,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 10,
                child: isFamily
                    ? Column(
                        children: [
                          child ?? const SizedBox(),
                          UserImage(
                            image: familyRankEntity?.img ?? "",
                            displayName: familyRankEntity?.name ?? '',
                            frame: frameImageAsset,
                            imageSize: 85.w,
                            frameSize: 120.w,
                            positionedLeft: 15,
                            positionedTop: 20,
                            positionedRight: 10,
                            boxFit: BoxFit.fill,
                            isAsset: true,
                          ),
                          5.hBox,
                          SizedBox(
                            width: 80.w,
                            child: Center(
                              child: TextWidget(
                                familyRankEntity?.name ?? '',
                                style: context.bodyMedium
                                    .colorExt(ColorManager.primary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          5.hBox,
                          familyRankEntity?.rank != ''
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Image.asset(
                                    //   AssetsManager.coinss,
                                    //   scale: 4,
                                    // ),
                                    SizedBox(
                                      width: 55.w,
                                      child: TextWidget(
                                        familyRankEntity?.rank ?? '',
                                        style: context.bodyLarge
                                            .colorExt(ColorManager.primary),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          child ?? const SizedBox(),
                          UserImage(
                            // image: 'images/a9df2e6ba68a5693743b8f6fe646ced4.jpg',
                            image: userTopEntity?.avatar ?? '',
                            displayName: userTopEntity?.name ?? '',
                            frame: frameImageAsset,
                            imageSize: 85.w,
                            frameSize: 120.w,
                            positionedLeft: 15,
                            positionedTop: 20,
                            positionedRight: 10,
                            boxFit: BoxFit.fill,
                            isAsset: true,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 10.wBox,
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: 60.w,
                                  // minWidth: 1.w,
                                ),
                                child: GradientName(child: Text(
                                  userTopEntity?.name ?? "",
                                  style: context.bodyMedium
                                      .colorExt(ColorManager.primary)
                                      .bold
                                      .size(16),
                                  overflow: TextOverflow.ellipsis,
                                )),
                              ),
                              1.hBox,
                              SizedBox(
                                width: 5.w,
                              ),
                              (userTopEntity?.flag != null &&
                                      userTopEntity?.flag != '')
                                  ? ImageViewWidget(
                                      url: userTopEntity?.flag ?? '',
                                      height: 25.h,
                                      width: 25.w,
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                          3.hBox,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              (userTopEntity?.vipLevel != null &&
                                      userTopEntity?.vipLevel != 0)
                                  ? VipContainer(
                                      vip: userTopEntity?.vipLevelImage ?? '',
                                    )
                                  : const SizedBox(),
                              SizedBox(
                                width: 5.w,
                              ),
                              (userTopEntity?.senderLevel != null &&
                                      userTopEntity?.senderLevel != 0)
                                  ? LevelContainer(
                                      level: userTopEntity?.senderLevel ?? 0,
                                      image: userTopEntity?.senderImage ?? '',
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                          5.hBox,
                          (userTopEntity?.exp != null &&
                                  userTopEntity?.exp != 0 &&
                                  userTopEntity?.exp != '')
                              ? SizedBox(
                                  width: 100.w,
                                  child: FittedBox(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Image.asset(
                                        //   AssetsManager.coinss,
                                        //   scale: 4,
                                        // ),
                                        3.wBox,
                                        Text(
                                          //'125.258M',
                                          (userTopEntity?.exp ?? '').toString(),
                                          style: context.bodyMedium
                                              .colorExt(ColorManager.primary)
                                              .w600
                                              .size(12),

                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                        ],
                      ),
              ),
            ],
          ),
          isUpper ? 120.hBox : 0.hBox,
        ],
      ),
    );
  }
}
