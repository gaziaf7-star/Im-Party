import '../../../../../core/index.dart';
import '../../../../../core/widgets/id_with_copy.dart';
import '../../../../auth/domain/entities/user_entity.dart';

class SearchUserRow extends StatelessWidget {
  final UserEntity user;
  final Widget? endIcon;
  final Color? color;
  final void Function()? onTap;
  const SearchUserRow({
    required this.user,
    this.endIcon,
    this.color,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: context.paddingSymmetric(vertical: 5, horizontal: 10),
      padding: context.paddingAll(5),
      decoration: BoxDecoration(
        borderRadius: 8.radius,
        // color: color ?? ColorManager.babyBlue2
      ),
      child: InkWell(
        onTap: onTap ??
                () {
              Methods().userProfileNavigator(
                context: context,
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
                  borderRadius: 25.radius,
                  imageSize: 55.h,
                  displayName: user.name ?? '',
                  image: EndPoints.getImage(
                    user.profile?.image ?? '',
                  ),
                ),
                10.wBox,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Builder(builder: (context) {
                      final rawColor = (user.colorName != null &&
                          user.colorName != "NULL" &&
                          user.colorName!.isNotEmpty)
                          ? user.colorName
                          : (user.vip?.colorName != null &&
                          user.vip!.colorName != "NULL" &&
                          user.vip!.colorName!.isNotEmpty)
                          ? user.vip!.colorName
                          : null;

                      // Owner request: plain (non-VIP) names now render in
                      // fixed black instead of the panel-driven
                      // ColorManager.secondaryText — a VIP's own special
                      // name colour (rawColor above) still wins when set,
                      // so this only changes the default look.
                      final nameColor =
                          Methods.safeHexColor(rawColor) ?? Colors.black;

                      return GradientTextVip(
                        width: 170.w,
                        color: nameColor,
                        textOverflow: TextOverflow.ellipsis,
                        text: user.name ?? '',
                        // Owner request: name text a bit bigger (was 14).
                        // GradientTextVip's `color` param only paints the
                        // VIP shimmer variant — for a plain (non-VIP) user
                        // it renders with textStyle's own colour, which was
                        // never set here, so it fell back to the theme's
                        // default (white). Setting it explicitly here fixes
                        // that for both the VIP and non-VIP cases.
                        textStyle: context.bodyLarge.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: nameColor,
                        ),
                        isVip: ((user.colorName ?? '').isNotEmpty &&
                            user.colorName != "NULL") ||
                            ((user.vip?.colorName ?? '').isNotEmpty &&
                                user.vip?.colorName != "NULL"),
                      );
                    }),
                    // ConstrainedBox(
                    //   constraints: BoxConstraints(
                    //     maxWidth: 170.w,
                    //     minWidth: 1.w,
                    //   ),
                    //   child: Text(
                    //     '${user.name}',
                    //     overflow: TextOverflow.ellipsis,
                    //     style: context.bodyMedium.w600
                    //         .size(14)
                    //         .colorExt(ColorManager.textPrimary.withValues(alpha: (0.5 ))),
                    //   ),
                    // ),
                    5.hBox,
                    // Owner request: ID text (and its copy icon) now fixed
                    // light black instead of the panel-driven
                    // ColorManager.textPrimary.
                    IdWithCopyIcon(
                      userId: user.uuid ?? '',
                      isNeedCopyIcon: true,
                      isSpecial: (user.specialId != null &&
                          (user.specialId ?? '') != ''),
                      specialImg: user.idImage ?? '',
                      color: user.imageColorEntity?.color,
                      img: user.imageColorEntity?.image,
                      mainAxisAlignment: MainAxisAlignment.start,
                      idColor: Colors.black.withValues(alpha: 0.5),
                      idStyle: context.bodyMedium
                          .size(11)
                          .w500
                          .colorExt(Colors.black.withValues(alpha: 0.5)),
                    ),
                    // 5.hBox,
                    // Row(
                    //   children: [
                    //     (user.vip?.level ?? 0) != 0
                    //         ? VipContainer(
                    //             vip: user.vip!.img1!,
                    //             width: 45.w,
                    //             height: 22.h,
                    //           )
                    //         : SizedBox(
                    //             height: 22.h,
                    //           ),
                    //     //  5.wBox,
                    //     GenderWidget(
                    //       age: user.profile?.age ?? 0,
                    //       gender: user.profile?.gender ?? 0,
                    //     ),
                    //
                    //     // 5.wBox,
                    //     (user.level?.senderImage ?? '') != ''
                    //         ? Padding(
                    //             padding: const EdgeInsets.symmetric(
                    //                 horizontal: 2.5),
                    //             child: LevelContainer(
                    //               height: 15.h,
                    //               boxFit: BoxFit.fill,
                    //               width: 45.w,
                    //               image: user.level?.senderImage ?? '',
                    //               level: user.level?.senderLevel ?? 1,
                    //             ),
                    //           )
                    //         : const SizedBox(),
                    //     (user.level?.receiverImage ?? '') != ''
                    //         ? Padding(
                    //             padding: const EdgeInsets.symmetric(
                    //                 horizontal: 2.5),
                    //             child: LevelContainer(
                    //               height: 15.h,
                    //               boxFit: BoxFit.fill,
                    //               width: 45.w,
                    //               image: user.level?.receiverImage ?? '',
                    //               level: user.level?.reciverLevel ?? 1,
                    //             ),
                    //           )
                    //         : const SizedBox(),
                    //   ],
                    // ),
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