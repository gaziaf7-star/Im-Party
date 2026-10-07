import 'package:general/src/core/index.dart';

class MainButton extends StatelessWidget {
  const MainButton({
    super.key,
    required this.title,
    required this.onTap,
    this.buttonColor,
    this.borderColor,
    this.loadingColor,
    this.borderWidth,
    this.titleColor,
    this.titleSize,
    this.height,
    this.width,
    this.radius,
    this.buttonColorList,
    this.border,
    this.style,
    this.borderRadius,
    this.isLoading = false,
    this.padding,
    this.fontWeight,
    this.widget,
  });

  final String title;
  final VoidCallback onTap;
  final Color? buttonColor;
  final Widget? widget;
  final Color? borderColor, loadingColor;
  final double? borderWidth;
  final Color? titleColor;
  final double? titleSize;
  final double? height;
  final double? width;
  final double? radius;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;
  final FontWeight? fontWeight;
  final BorderRadiusGeometry? borderRadius;
  final List<Color>? buttonColorList;
  final BoxBorder? border;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    // The panel `app_primary_color_grad` gradient, applied ONLY to the default
    // primary button (no explicit [buttonColor]/[buttonColorList]); explicit
    // overrides keep their exact look. Null when the panel set a solid primary,
    // so the flat [ColorManager.primary] background below stays the source.
    final Gradient? panelPrimaryGradient =
        (buttonColor == null && buttonColorList == null)
            ? ColorManager.primaryGradient
            : null;
    return Container(
      width: width?.w ?? MediaQuery.sizeOf(context).width,
      height: height?.w ?? MediaQuery.sizeOf(context).height,
      decoration: BoxDecoration(
        border: border,
        borderRadius: borderRadius ?? BorderRadius.circular(radius?.r ?? 30.r),
        gradient: buttonColorList != null
            ? LinearGradient(
                colors: buttonColorList!,
              )
            : panelPrimaryGradient,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: padding ?? EdgeInsets.zero,
          // minimumSize: Size(
          //     width?.w ?? MediaQuery.sizeOf(context).width, height?.h ?? 55.h),
          // maximumSize: Size(
          //     width?.w ?? MediaQuery.sizeOf(context).width, height?.h ?? 55.h),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: borderWidth ?? 1.0,
              color: borderColor ?? ColorManager.transparent,
            ),
            borderRadius:
                borderRadius ?? BorderRadius.circular(radius?.r ?? 30.r),
          ),
          elevation: 0.0,
          shadowColor: ColorManager.transparent,
          backgroundColor: buttonColor ??
              (buttonColorList == null && panelPrimaryGradient == null
                  ? ColorManager.primary
                  : ColorManager.transparent),
        ),
        onPressed: isLoading ? null : onTap,
        child: isLoading
            ? const LoadingWidget()
            : widget ??
                FittedBox(
                  child: TextWidget(
                    title,
                    style: style ??
                        context.bodyMedium
                            .copyWith(
                              fontSize: titleSize?.sp ?? 8.sp,
                              fontWeight: fontWeight ?? FontWeight.w600,
                            )
                            .colorExt(
                                titleColor ?? ColorManager.buttonTextColor),
                  ),
                ),
      ),
    );
  }
}
