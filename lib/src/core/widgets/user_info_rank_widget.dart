import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/country_icon.dart';
import 'package:general/src/core/widgets/level_container.dart';
import 'package:general/src/core/widgets/vip_container.dart';
import 'package:general/src/features/games/domain/entities/user_top_entity.dart';

class UserInfoRankWidget extends StatelessWidget {
  final UserTopEntity? userTopEntity;
  final void Function()? onTap;
  final int index;
  final bool? isSender;
  final bool? isWealth;
  final bool? isCp;
  const UserInfoRankWidget({
    this.onTap,
    required this.userTopEntity,
    super.key,
    required this.index,
    required this.isSender,
    required this.isCp, this.isWealth,
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
        padding: context.paddingSymmetric(horizontal: 10, vertical: 10),
        margin: context.paddingOnly(
          bottom: 6.0,
        ),
        decoration: BoxDecoration(
            borderRadius: 5.radius
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget(
              '$index',
              style:
              context.bodyLarge
                  .size(12)
                  .w700
                  .colorExt(ColorManager.secondaryText),
            ),
            10.wBox,
            UserImage(
              boxFit: BoxFit.cover,
              image: userTopEntity?.avatar ?? "",
              displayName: userTopEntity?.name ?? '',
              imageSize: 35,
              borderRadius: 90.radius,
            ),
            15.wBox,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        SizedBox(
                          width:150.w,
                          child: Text(
                            userTopEntity?.name ?? "",
                            style: context.bodyMedium
                                .bold,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        // GenderWidget(age: userTopEntity.,
                        //     gender: userTopEntity?.gender??''=='female'??0:1)
                      ],
                    ),
                  ),
                  5.hBox,
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        if((userTopEntity?.flag ?? '') != '')
                          CountryIcon(country: userTopEntity!.flag!),
                        8.wBox,
                        LevelContainer(
                          image: isSender == true
                              ? userTopEntity?.senderImage ?? ''
                              : userTopEntity?.receiverImage,
                          //level: userTopEntity?.senderLevel ?? 0,
                          // height: 10.h,
                          // width: 30.w,
                        ),
                        8.wBox,
                        if (isCp != true)
                          VipContainer(
                            vip: userTopEntity?.vipLevelImage ?? '',
                            //level: userTopEntity?.receiverLevel ?? 0,
                            height: 10.h,
                            width: 30.w,
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
              style: context.bodyMedium
                  .size(11)
                  .w700,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            5.wBox,
            isWealth?? false?
            Image.asset(AssetsManager.coinsVip, scale: 3.5,):Image.asset(AssetsManager.diamondIcon, scale: 3.5,),

          ],
        ),
      ),
    );
  }
}
