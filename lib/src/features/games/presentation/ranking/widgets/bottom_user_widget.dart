import 'package:general/src/core/widgets/level_container.dart';
import 'package:general/src/core/widgets/vip_container.dart';
import 'package:general/src/features/games/games.dart';

class Bottomuserwidget extends StatelessWidget {
  const Bottomuserwidget(
      {super.key,
      required this.userEntity,
      required this.isSender,
      this.isWealth});

  final UserTopEntity? userEntity;
  final bool? isSender;
  final bool? isWealth;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      padding: context.paddingSymmetric(horizontal: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: ColorManager.bottomCardRankGradient,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextWidget(
            'NO',
            style: context.bodyMedium.bold.colorExt(ColorManager.greyTextColor),
          ),
          8.wBox,
          UserImage(
            image: userEntity?.avatar ?? "",
            displayName: userEntity?.name ?? '',
            imageSize: 40.w,
          ),
          15.wBox,
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                userEntity?.name ?? "",
              ),
              5.hBox,
              Row(
                children: [
                  LevelContainer(
                    image: isSender == true
                        ? userEntity?.senderImage ?? ""
                        : userEntity?.receiverImage ?? "",
                    // width: 30,
                    // height: 10,
                    // boxFit: BoxFit.fill,
                  ),
                  5.wBox,
                  if (isSender != null)
                    VipContainer(
                      vip: userEntity?.vipLevelImage ?? "",
                      width: 30,
                      height: 10,
                      boxFit: BoxFit.fill,
                    ),
                ],
              ),
            ],
          ),
          const Spacer(),
          isWealth ?? false
              ? ImageWidget(
                  height: 20.h, width: 20.w, image: AssetsManager.coinIcon)
              : ImageWidget(
                  height: 20.h, width: 20.w, image: AssetsManager.diamondIcon),
          5.wBox,
          TextWidget(
            userEntity?.exp ?? "",
            style: context.bodySmall.w700,
          ),
        ],
      ),
    );
  }
}
