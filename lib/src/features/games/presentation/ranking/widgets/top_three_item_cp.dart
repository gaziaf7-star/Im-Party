/*


import 'package:general/src/features/games/domain/entities/cp_entity.dart';
import '../../../../../core/index.dart';

class TopThreeItemCp extends StatelessWidget {
  final CpUserRankEntity? userTopEntity;
  final String frameImage;
  final bool  isUpper;
  final int  indexTap;

  const TopThreeItemCp({
    this.userTopEntity,
    required this.frameImage,
    required this.indexTap,
    this.isUpper = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Methods.printLog(';;llslslslslsllslslslls$userTopEntity');
    return Column(
      children: [
        if (!isUpper) 90.hBox,
        Container(
          width: 110.w,
          height: 125.h,
          margin: context.paddingSymmetric(horizontal: 3),
          padding: context.paddingSymmetric(horizontal: 7,vertical: 7),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: 10.radiusCircular,
                topRight: 10.radiusCircular,
              ),
              gradient: LinearGradient(
                  begin: AlignmentDirectional.topCenter,
                  end: AlignmentDirectional.bottomCenter,
                  colors: [
                    ColorManager.white,
                    ColorManager.white.withValues(alpha:0),
                  ])
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              IntrinsicHeight(
                child: Container(
                  height: 170.h,
                  width: 120.w,
                  padding: context.paddingSymmetric(horizontal: 7.5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      10.hBox,
                      SizedBox(
                        width: 120.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            47.hBox,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: TextWidget(
                                    userTopEntity?.userOne?.name??'',
                                    style: context.bodySmall.colorExt(ColorManager.textPrimary),
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                10.wBox,
                                Flexible(
                                  child: TextWidget(
                                    userTopEntity?.userTwo?.name??'',
                                    style: context.bodySmall,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            // 3.hBox,
                            // LevelContainer(
                            //   //level: userTopEntity?.senderLevel ?? 0,
                            //   image: userTopEntity?.senderImage,
                            //   isComment: true,
                            //   height: 10.h,
                            //   width: 30.w,
                            // ),
                            3.hBox,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: IntrinsicHeight(
                                    child: IntrinsicWidth(
                                      child: TextWidget(
                                        userTopEntity?.exp.toString()??'',
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        style: context.bodyMedium
                                            .size(12)
                                            .w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10.w,
                right: 0,
                left: 0,
                child: GestureDetector(
                  onTap: () {

                      // if (userTopEntity != null && userTopEntity!.u != 0) {
                      //   Methods().userProfileNavigator(
                      //     context: context,
                      //     userId: '${userTopEntity?.userId}',
                      //   );
                      // }

                  },
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          UserImage(
                            image: userTopEntity?.userOne?.image??'',
                            displayName: userTopEntity?.userOne?.name ?? '',
                            frame: frameImage,
                            imageSize: 30.w,
                            uniquId:  '${userTopEntity?.userOne?.uid}',
                            frameSize: 47.w,
                            // positionedLeft: 15,
                            // positionedTop: 20,
                            // positionedRight: 10,
                            isAsset: true,
                            boxFit: BoxFit.cover,
                          ),
                          UserImage(
                            image: userTopEntity?.userTwo?.image??'',
                            displayName: userTopEntity?.userTwo?.name ?? '',
                            frame: frameImage,
                            imageSize: 30.w,
                            uniquId:  '${userTopEntity?.userTwo?.uid}',
                            frameSize: 47.w,
                            // positionedLeft: 15,
                            // positionedTop: 20,
                            // positionedRight: 10,
                            isAsset: true,
                            boxFit: BoxFit.cover,
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
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
*/
