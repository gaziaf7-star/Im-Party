part of 'basic_tool_dialog.dart';

class BasicToolItem extends StatelessWidget {
  const BasicToolItem({
    super.key,
    required this.image,
    required this.title,
    this.height,
    this.width,
    this.color,
    this.icon,
    this.titleColor,
    this.noTint = false,
  });
  final String image;
  final String title;
  final double? height;
  final double? width;
  final IconData? icon;
  final Color? color, titleColor;
  // Shows `image` with its own real colors, no brand-gradient ShaderMask tint.
  final bool noTint;
  @override
  Widget build(BuildContext context) {
    final plainImage = Image.asset(
      image,
      width: width ?? 33.w,
      height: height ?? 33.h,
    );
    return Container(
      padding: context.paddingAll(2.r),
      margin: context.paddingOnly(top: 3.h),
      width: 90.w,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: context.paddingAll(9),
            // Faint brand-gradient tint on the badge circle, brand-gradient
            // icon inside via ShaderMask -- on request (was a flat lavender
            // tint on both).
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: ColorManager.brandGradientColors
                      .map((c) => c.withValues(alpha: 0.1))
                      .toList(),
                ),
                borderRadius: 30.radius),
            child: noTint && icon == null
                ? plainImage
                : ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) =>
                  ColorManager.brandGradient.createShader(bounds),
              child: icon != null
                  ? Icon(
                icon,
                size: 33.sp,
                color: ColorManager.white,
              )
                  : Image.asset(
                image,
                width: width ?? 33.w,
                height: height ?? 33.h,
                color: ColorManager.white,
              ),
            ),
          ),
          4.hBox,
          Text(
            title,
            style: context.bodySmall
                .colorExt(titleColor ?? _kToolsIconColor)
                .copyWith(fontSize: 12.sp),
            textAlign: TextAlign.center,
            // Was maxLines: 1 -- a longer label like "Activate boss
            // position" or "Screenshot/Recording" got truncated with "..."
            // instead of wrapping to a second line like the reference
            // design. 2 lines fixes that while still guarding against a
            // genuinely too-long label.
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}