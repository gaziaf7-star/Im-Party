import 'package:general/src/core/widgets/id_with_copy.dart';
import 'package:general/src/core/widgets/level_container.dart';
import 'package:general/src/core/widgets/show_svga.dart';

import '../../../../../../core/index.dart';
import '../../../../domain/entity/information_agency_entity.dart';

class ItemRankTopThreeAgency extends StatelessWidget {
  final StarEntity? userTopEntity;
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

  const ItemRankTopThreeAgency({
    this.userTopEntity,
    required this.frameImage,
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
                Methods().userProfileNavigator(
                  context: context,
                  userId: '${userTopEntity?.uuid}',
                );
              },
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              UserImage(
                image: userTopEntity?.image ?? '',
                displayName: userTopEntity?.name ?? '',
                imageSize: isUpper ? 75.h : 65.h,
                uniquId: '${userTopEntity?.uuid}',
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
              isUpper ? 170.hBox : 170.hBox,
              SizedBox(
                width: 270.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    20.hBox,
                    GradientTextVip(
                      isVip: false,
                      width: 130.w,
                      text: userTopEntity?.name ?? '',
                      color: (userTopEntity?.coloredName ?? '').isNotEmpty &&
                              userTopEntity?.coloredName != "NULL"
                          ? Color(
                              int.parse(
                                userTopEntity!.coloredName!
                                    .replaceAll('#', '0xFF'),
                              ),
                            )
                          : ColorManager.textPrimary,
                      mainAxisAlignment: MainAxisAlignment.center,
                      textAlign: TextAlign.center,
                      textStyle: context.bodyMedium.size(14).w600.colorExt(
                            (userTopEntity?.coloredName ?? '') != ""
                                ? Color((int.parse(userTopEntity!.coloredName!
                                    .replaceAll('#', '0xff'))))
                                : ColorManager.textPrimary,
                          ),
                    ),
                    if (userTopEntity?.uuid != null &&
                        userTopEntity?.uuid != '')
                      IdWithCopyIcon(
                          userId: (userTopEntity?.uuid ?? ""),
                          specialImg: userTopEntity?.idImage ?? ''),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LevelContainer(
                            image: userTopEntity?.levels?.receiverImg ?? '',
                            isComment: true,
                            height: 13.h,
                            width: 30.w,
                          ),
                          5.wBox,
                          LevelContainer(
                            image: userTopEntity?.levels?.senderImg ?? '',
                            isComment: true,
                            height: 12.h,
                            width: 30.w,
                          ),
                        ],
                      ),
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
