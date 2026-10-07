import 'package:general/src/core/index.dart';

class AnimatedDialog extends StatefulWidget {
  final String? title, description;
  final VoidCallback? onTap;
  final VoidCallback? onTapCancel;
  final Widget? child;
  final String? conText;
  final String? cancelText;
  final bool isHideConfirm;
  final bool? showIcon;
  final bool? showCloseIcon;
  final bool? hideCancel;
  final bool? titleDivider;
  final bool? isUpdateDialog;
  final bool? needPopScope;
  final Widget? billText;
  final double? horizontalPadding;
  final double? radius;
  final EdgeInsetsGeometry? contentPadding;
  final Color? color;
  final Color? cancelTextColor;
  final Color? borderColor;
  final double? width, height, fontSize;
  final double? cancelWidth, cancelHeight, cancelFontSize;

  /// Opt-in override for the dialog's own card background (was always the
  /// panel-driven scaffoldBg/surfaceCardColor). Null (every existing caller)
  /// keeps the current look; only a caller that passes this gets a
  /// different background.
  final Color? dialogBackgroundColor;

  /// Opt-in override for the [description] text colour (was always the
  /// fixed [ColorManager.secondaryText]).
  final Color? descriptionColor;

  /// Opt-in override for the [title] text colour (was always the
  /// panel-driven [ColorManager.textPrimary]).
  final Color? titleColor;

  /// Opt-in gradient fill for the confirm button (e.g. the brand gradient),
  /// taking priority over [color] when set. Null keeps the existing flat
  /// [color]/[ColorManager.primary] fill.
  final List<Color>? confirmGradientColors;

  const AnimatedDialog({
    super.key,
    this.title,
    this.child,
    this.contentPadding,
    this.conText,
    this.description,
    this.showIcon,
    this.onTap,
    this.titleDivider,
    this.isHideConfirm = false,
    this.showCloseIcon = false,
    this.hideCancel = false,
    this.billText,
    this.radius,
    this.isUpdateDialog,
    this.needPopScope,
    this.color,
    this.cancelText,
    this.horizontalPadding,
    this.width,
    this.height,
    this.onTapCancel,
    this.cancelWidth,
    this.cancelHeight,
    this.fontSize,
    this.cancelFontSize,
    this.cancelTextColor,
    this.borderColor,
    this.dialogBackgroundColor,
    this.descriptionColor,
    this.titleColor,
    this.confirmGradientColors,
  });

  @override
  AnimatedDialogState createState() => AnimatedDialogState();
}

class AnimatedDialogState extends State<AnimatedDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.needPopScope == true ? false : true,
      child: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Dialog(
            backgroundColor:
            widget.dialogBackgroundColor ?? ColorManager.scaffoldBg,
            insetPadding: EdgeInsets.symmetric(
                horizontal: widget.horizontalPadding ?? 25.w),
            shape: RoundedRectangleBorder(
              borderRadius: widget.radius?.radius ?? 20.radius,
            ),
            elevation: 0.0,
            child: Container(
              decoration: BoxDecoration(
                color: widget.dialogBackgroundColor ??
                    ColorManager.surfaceCardColor,
                borderRadius:
                widget.radius != null ? widget.radius!.radius : 20.radius,
              ),
              child: Padding(
                padding: widget.contentPadding ?? context.paddingAll(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (widget.showIcon ?? false) ...[
                          ImageWidget(
                            height: 30.h,
                            width: 30.w,
                            image: AssetsManager.googlePlayUpdate,
                          ),
                          15.wBox,
                        ],
                        if ((widget.title ?? '') != '')
                          Expanded(
                            child: TextWidget(
                              widget.title ?? '',
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: context.bodyLarge
                                  .colorExt(
                                widget.titleColor ??
                                    ColorManager.textPrimary,
                              )
                                  .size(16)
                                  .w600,
                            ),
                          ),
                        if (widget.showCloseIcon ?? false) ...[
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.close,
                              size: 15.h,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (widget.titleDivider ?? true) ...[
                      10.hBox,
                      Divider(color: ColorManager.grey.withValues(alpha: 0.1)),
                    ],
                    widget.child ?? 15.hBox,
                    if (widget.billText != null) widget.billText!,
                    if (widget.billText == null &&
                        (widget.description ?? '') != '')
                      TextWidget(
                        widget.description ?? '',
                        textAlign: TextAlign.center,
                        style: context.bodyMedium.w500.colorExt(
                          widget.descriptionColor ?? ColorManager.secondaryText,
                        ),
                      ),
                    30.hBox,
                    if (widget.isHideConfirm == false ||
                        widget.isUpdateDialog == true)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if ((widget.isUpdateDialog ?? true) &&
                              !(widget.hideCancel ?? false))
                            Expanded(
                              child: ButtonWidget(
                                title: widget.cancelText ??
                                    StringManager.cancel.tr(),
                                height: widget.cancelHeight ?? 45.h,
                                fontSize: widget.cancelFontSize ?? 14.sp,
                                titleColor: widget.cancelTextColor ??
                                    ColorManager.textPrimary,
                                fontWeight: FontWeight.w400,
                                borderColor:
                                widget.borderColor ?? ColorManager.grey,
                                width: widget.cancelWidth,
                                padding: context.paddingSymmetric(
                                  horizontal: 0,
                                ),
                                backgroundColor: ColorManager.transparent,
                                onPressed: widget.onTapCancel ??
                                        () => Navigator.of(context).pop(),
                              ),
                            ),
                          if (widget.isHideConfirm == false) 20.wBox,
                          if (widget.isHideConfirm == false)
                            Expanded(
                              child: InkWell(
                                onDoubleTap: () {},
                                child: ButtonWidget(
                                  title: widget.conText ??
                                      StringManager.confirm.tr(),
                                  height: widget.height ?? 45.h,
                                  padding: context.paddingSymmetric(
                                    horizontal: 0,
                                  ),
                                  width: widget.width,
                                  fontSize: widget.fontSize ?? 14.sp,
                                  // White reads on every gradient fill this
                                  // app uses; a caller with a gradient always
                                  // wants it instead of buttonTextColor.
                                  titleColor: widget.confirmGradientColors !=
                                      null
                                      ? ColorManager.white
                                      : ColorManager.buttonTextColor,
                                  backgroundColor:
                                  widget.color ?? ColorManager.primary,
                                  backgroundColors: widget.confirmGradientColors,
                                  fontWeight: FontWeight.w400,
                                  onPressed: widget.onTap ?? () {},
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}