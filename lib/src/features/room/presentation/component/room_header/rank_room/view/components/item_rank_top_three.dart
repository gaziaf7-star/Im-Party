part of '../rank_room_page.dart';

class ItemRankTopThree extends StatelessWidget {
  final FamilyRankEntity? rankFamilyEntity;
  final UserTopEntity? userEntity;
  final String frameImage;
  final bool isFamily, isUpper;
  final bool? isRoom;
  final bool? isCharm;
  final bool? isWealth;
  final bool? isRoomRank;
  final bool? isCp;

  const ItemRankTopThree({
    this.rankFamilyEntity,
    this.userEntity,
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
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        GestureDetector(
          onTap: () {
            if (isFamily) {
              if (rankFamilyEntity != null && rankFamilyEntity?.id != 0) {
                Navigator.pushNamed(context, Routes.familyScreen,
                    arguments: rankFamilyEntity?.id.toString(),);
              }
            } else {
              if (userEntity != null && userEntity?.userId != 0) {
                Methods().userProfileNavigator(
                  context: context,
                  userId: '${userEntity?.userId}',
                );
              }
            }
          },
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              UserImage(
                key: ValueKey('${isFamily ? rankFamilyEntity?.id : userEntity?.userId}'),
                image: isFamily
                    ? '${rankFamilyEntity?.img}'
                    : '${userEntity?.avatar}',
                displayName: isFamily
                    ? (rankFamilyEntity?.name ?? '')
                    : (userEntity?.name ?? ''),
                imageSize: isUpper ? 65.h : 60.h,
                borderRadius: 30.radius,
                frameSize: 110.w,
                isAsset: true,
                boxFit: BoxFit.cover,
              ),
              ShowSVGA(
                svgaAssetPath: frameImage,
                height: isUpper ? 160.h : 100,
                width: isUpper ? 320.w : 130.w,
                fit: BoxFit.fill,
              ),
            ],
          ),
        ),
        Container(
          width: 170.w,
          margin: context.paddingSymmetric(horizontal: 3),
          padding: context.paddingSymmetric(horizontal: 7),
          clipBehavior: Clip.none,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              isUpper ? 130.hBox : 105.hBox,
              SizedBox(
                width: 270.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GradientTextVip(
                        isVip: (userEntity?.colorName ?? '').isNotEmpty,
                        width: 130.w,
                        text: userEntity?.name ?? '',
                        color: userEntity?.colorName != null &&
                                (userEntity?.colorName ?? '').isNotEmpty
                            ? Color((int.parse(
                                '${userEntity?.colorName?.replaceAll('#', '0xff')}')))
                            : ColorManager.black,
                        mainAxisAlignment: MainAxisAlignment.center,
                        textAlign: TextAlign.center,
                        textStyle: context.bodyMedium
                            .size(14)
                            .colorExt(userEntity?.colorName != null &&
                                    (userEntity?.colorName ?? '').isNotEmpty
                                ? Color((int.parse(
                                    '${userEntity?.colorName?.replaceAll('#', '0xff')}')))
                                : ColorManager.white)
                            .w500),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: TextWidget(
                            userEntity?.exp.toString() ?? '',
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: context.bodyMedium.w500
                                .colorExt(ColorManager.textPrimary),
                          ),
                        ),
                        3.wBox,
                        isWealth == true
                            ? ImageWidget(
                                height: 20.h,
                                width: 20.w,
                                image: AssetsManager.fire2,
                              )
                            : isCharm == true
                                ? ImageWidget(
                                    height: 20.h,
                                    width: 17.w,
                                    image: AssetsManager.fire2,
                                  )
                                : ImageWidget(
                                    height: 20.h,
                                    width: 17.w,
                                    image: AssetsManager.fire2,
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
