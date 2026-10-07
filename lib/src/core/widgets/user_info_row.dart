import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/domain/entities/user_entity.dart';

import 'id_with_copy.dart';

class UserInfoRow extends StatelessWidget {
  final UserEntity user;
  final Widget? endIcon;
  final bool? isUserVip;
  final VoidCallback? select;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const UserInfoRow({
    required this.user,
    this.endIcon,
    super.key,
    this.isUserVip,
    this.margin,
    this.padding,
    this.select,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? context.paddingSymmetric(vertical: 5, horizontal: 10),
      padding: padding ?? context.paddingAll(5),
      decoration: BoxDecoration(
        borderRadius: 8.radius,
        // border: isUserVip ?? false
        //     ? Border.all(color: ColorManager.primary)
        //     : null,
        //  color: ColorManager.white,
      ),
      child: InkWell(
        onTap: select ??
            () {
              Methods().userProfileNavigator(
                context: context,
                //isPushAndRemoveUntil: true,
                userId: '${user.id}',
              );
            },
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                UserImage(
                  borderRadius: 50.radius,
                  imageSize: 60.h,
                  image: user.profile?.image ?? '',
                  displayName: '${user.name}',
                ),
                10.wBox,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 170.w,
                        minWidth: 1.w,
                      ),
                      child: Text(
                        '${user.name}',
                        overflow: TextOverflow.ellipsis,
                        style: context.bodyMedium.w600
                            .size(14)
                            .colorExt(ColorManager.textTabBar),
                      ),
                    ),
                    5.hBox,
                    IdWithCopyIcon(
                        userId: user.uuid ?? '',
                        isNeedCopyIcon: true,
                        isSpecial: (user.specialId != 0 &&
                            (user.specialId ?? '') != ''),
                        specialImg: user.idImage ?? '',
                        color: user.imageColorEntity?.color,
                        img: user.imageColorEntity?.image,
                        mainAxisAlignment: MainAxisAlignment.start,
                        idColor: ColorManager.secondaryText,
                        idStyle: context.bodyMedium.size(11).w500.colorExt(
                            ColorManager.secondaryText)),
                  ],
                ),
                const Spacer(),
                endIcon ?? const SizedBox()
              ],
            ),
            // 5.hBox,
            // const Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 10.0),
            //   child: Divider(
            //     thickness: 0.7,
            //     color: ColorManager.grey,
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
