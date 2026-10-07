import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/level_container.dart';
import 'package:general/src/features/agency/agency.dart';

import '../../../../../../core/widgets/id_with_copy.dart';

class UserInfoRankWidgetAgency extends StatelessWidget {
  final StarEntity? userTopEntity;
  final void Function()? onTap;
  final int index;
  const UserInfoRankWidgetAgency({
    this.onTap,
    required this.userTopEntity,
    super.key,
    required this.index,
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
        decoration: BoxDecoration(borderRadius: 5.radius),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget(
              '$index',
              style: context.bodyLarge
                  .size(12)
                  .w700
                  .colorExt(ColorManager.secondaryText),
            ),
            10.wBox,
            UserImage(
              boxFit: BoxFit.cover,
              image: userTopEntity?.image ?? "",
              displayName: userTopEntity?.name ?? '',
              imageSize: 70,
              borderRadius: 90.radius,
            ),
            15.wBox,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IntrinsicHeight(
                    child: SizedBox(
                      width: 170.w,
                      child: TextWidget(
                        userTopEntity?.name ?? "",
                        style: context.bodyMedium.size(8).w600.colorExt(
                              Methods.safeHexColor(
                                      userTopEntity?.coloredName) ??
                                  ColorManager.textPrimary,
                            ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  IdWithCopyIcon(
                    userId: (userTopEntity?.uuid ?? ""),
                    mainAxisAlignment: MainAxisAlignment.start,
                  ),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        LevelContainer(
                          image: userTopEntity?.levels?.senderImg ?? '',
                          height: 15.h,
                          width: 30.w,
                        ),
                        8.wBox,
                        LevelContainer(
                          image: userTopEntity?.levels?.receiverImg ?? '',
                          height: 15.h,
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
    );
  }
}
