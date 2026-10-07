/*
import 'package:general/src/core/index.dart';

class UserInfoRankWidgetCp extends StatelessWidget {
  // final CpUserRankEntity? userTopEntity;
  final void Function()? onTap;
  final int index;
  final bool? isSender;
  final int? indexTap;
  const UserInfoRankWidgetCp({
    this.onTap,
    // required this.userTopEntity,
    super.key,
    required this.index,
    required this.isSender,
    required this.indexTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorManager.transparent,
      shadowColor: ColorManager.transparent,
      elevation: 0,
      child: InkWell(
        onTap: onTap ??
            () {
              // Methods().userProfileNavigator(
              //   context: context,
              //   userId: '${userTopEntity?.userId}',
              // );
            },
        child: Container(
          padding: context.paddingSymmetric(horizontal: 5, vertical: 5),
          margin: context.paddingSymmetric(vertical: 3.0, horizontal: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget(
                index >= 10 ? '$index' : '0$index',
                style:
                    context.bodyLarge.size(12).w700.colorExt(ColorManager.grey),
              ),
              10.wBox,
              Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Row(
                    children: [
                      UserImage(
                        boxFit: BoxFit.cover,
                        image: userTopEntity?.userOne?.image ?? '',
                        displayName: userTopEntity?.userOne?.name ?? '',
                        imageSize: 40,
                        borderRadius: 90.radius,
                      ),
                      5.wBox,
                      UserImage(
                        boxFit: BoxFit.cover,
                        image: userTopEntity?.userTwo?.image ?? '',
                        displayName: userTopEntity?.userTwo?.name ?? '',
                        imageSize: 40,
                        borderRadius: 90.radius,
                      ),
                    ],
                  ),
                  indexTap == 3
                      ? Image.asset(
                          AssetsManager.friendsCp,
                          height: 30.h,
                          width: 30.h,
                        )
                      : indexTap == 4
                          ? Image.asset(
                              AssetsManager.brother,
                              height: 30.h,
                              width: 30.h,
                            )
                          : Image.asset(
                              AssetsManager.heartCp,
                              height: 20.h,
                              width: 20.h,
                            ),
                ],
              ),
              15.wBox,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IntrinsicHeight(
                      child: TextWidget(
                        userTopEntity?.userOne?.name ?? '',
                        style: context.bodyMedium.w400,
                      ),
                    ),
                    5.hBox,
                    IntrinsicHeight(
                      child: TextWidget(
                        userTopEntity?.userTwo?.name ?? '',
                        style: context.bodyMedium.w400,
                      ),
                    ),
                    // IntrinsicHeight(
                    //   child: Row(
                    //     children: [
                    //       LevelContainer(
                    //         image: isSender==true?userTopEntity?.senderImage ?? '':userTopEntity?.receiverImage,
                    //         //level: userTopEntity?.senderLevel ?? 0,
                    //         height: 10.h,
                    //         width: 30.w,
                    //       ),
                    //       4.5.wBox,
                    //        if(isCp != true)
                    //       VipContainer(
                    //         vip: userTopEntity?.vipLevelImage ?? '',
                    //         //level: userTopEntity?.receiverLevel ?? 0,
                    //         height: 10.h,
                    //         width: 30.w,
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
              Image.asset(
                AssetsManager.diamondIcon,
                scale: 3.5,
              ),
              5.wBox,
              TextWidget(
                '${userTopEntity?.exp ?? 0}',
                style: context.bodyMedium.size(11).w700,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/
