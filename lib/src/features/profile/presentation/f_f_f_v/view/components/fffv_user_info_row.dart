part of 'package:general/src/features/profile/presentation/f_f_f_v/view/page/f_f_f_screen.dart';

class FFFVUserInfoRow extends StatelessWidget {
  final UserEntity user;
  final Widget? endIcon;
  final bool? isUserVip;
  final VoidCallback? select;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const FFFVUserInfoRow({
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
    final String? colorCode = user.colorName;
    final Color? parsedColor = Methods.safeHexColor(colorCode);
    final bool hasValidColor = parsedColor != null;
    // Fixed light-black fallback (was the panel-driven textPrimary) — a
    // real VIP colour name still wins, this only guarantees a readable
    // colour for everyone else.
    final Color resolvedColor = parsedColor ?? ColorManager.momentPostTextColor;
    return Container(
      margin: margin ?? context.paddingSymmetric(horizontal: 20),
      padding: padding ?? context.paddingAll(20),
      decoration: BoxDecoration(
        borderRadius: 12.radius,
        // Explicit white on request -- the old `ColorManager.scaffoldBg`
        // turns fully transparent whenever the user has a custom app-wide
        // "body theme" background enabled, which made this card blend into
        // the page and barely show at all. A subtle border + shadow was
        // added too so the card reads clearly as its own element
        // (Follower / Following / Friend / Visitor lists all share this
        // row widget).
        color: ColorManager.white,
        border: Border.all(color: ColorManager.grey2.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: ColorManager.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: InkWell(
          onTap: select ??
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
                    imageSize: 50.w,
                    displayName: user.name ?? '',
                    image: EndPoints.getImage(
                      user.profile?.image ?? '',
                    ),
                    frame: user.frame,
                    // Without frameType an .svga frame falls through to the
                    // still-image branch and draws nothing.
                    frameType: user.frameType ?? '',
                    frameSize: 70.w,
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
                        child: GradientTextVip(
                          isVip: hasValidColor,
                          width: 150.w,
                          text: '${user.name}',
                          color: resolvedColor,
                          mainAxisAlignment: MainAxisAlignment.center,
                          textAlign: TextAlign.center,
                          textStyle: context.bodyMedium
                              .size(16)
                              .colorExt(resolvedColor),
                        ),
                      ),
                      3.hBox,
                      Row(
                        children: [
                          // Level/VIP badges made a bit bigger on request (2nd
                          // bump) -- still reading too small next to the name.
                          if (user.vip != null && user.vip?.level != 0) ...[
                            VipContainer(
                              vip: user.vip?.img1 ?? '',
                              width: 46.w,
                              height: 22.h,
                            ),
                          ],
                          5.wBox,
                          LevelContainer(
                            image: user.level?.senderImage ?? '',
                            height: 44.h,
                            width: 44.w,
                          ),
                          5.wBox,
                          LevelContainer(
                            image: user.level?.receiverImage ?? '',
                            height: 44.h,
                            width: 44.w,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  endIcon ?? const SizedBox()
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}