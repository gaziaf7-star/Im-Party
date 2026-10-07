import 'package:general/src/core/index.dart';

import '../../../../data/model/top.dart';

class UserInfoSupportWidget extends StatelessWidget {
  final Top? userTopEntity;
  final void Function()? onTap;
  final int index;
  final bool? isSender;
  const UserInfoSupportWidget({
    this.onTap,
    required this.userTopEntity,
    super.key,
    required this.index,
    required this.isSender,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: 5.radius,
      onTap: onTap ??
          () {
            Methods().userProfileNavigator(
              context: context,
              userId: '${userTopEntity?.id}',
            );
          },
      child: Container(
        padding: context.paddingSymmetric(horizontal: 10, vertical: 10),
        margin: context.paddingOnly(
          bottom: 6.0,
        ),
        decoration: BoxDecoration(
            borderRadius: 5.radius),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextWidget(
              '$index',
              style:
                  context.bodyLarge.size(12).w700.colorExt(ColorManager.secondaryText),
            ),
            10.wBox,
            UserImage(
              boxFit: BoxFit.cover,
              image: userTopEntity?.image ?? "",
              displayName: userTopEntity?.name ?? '',
              imageSize: 50,
              borderRadius: 90.radius,
            ),
            15.wBox,
            Expanded(
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    SizedBox(
                      width: 150.w,
                      child: TextWidget(
                        userTopEntity?.name ?? "",
                        style: context.bodyMedium.size(14),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            5.wBox,
            TextWidget(
              '${userTopEntity?.total ?? 0}',
              style: context.bodyMedium.colorExt(ColorManager.orange),
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            5.wBox,
            Image.asset(
              AssetsManager.coinsVip,
              scale: 3.5,
            ),
          ],
        ),
      ),
    );
  }
}
