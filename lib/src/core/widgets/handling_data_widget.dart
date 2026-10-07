import 'package:lottie/lottie.dart';
import 'package:general/src/core/index.dart';

import 'GradientLoader.dart';

class HandlingDataWidget extends StatelessWidget {
  const HandlingDataWidget({
    super.key,
    required this.reqState,
    this.childEmpty,
    required this.title,
    required this.subTitle,
    this.onTap,
    this.isBlock,
    this.buttonTitle,
    this.titleStyle,
    this.subTitleStyle,
    this.isLoadingCenter,
    this.isNeedLoadingWidget = true,
    this.buttonBackgroundColors,
    this.buttonBorderColor,
    required this.child,
  });

  final RequestState reqState;
  final Widget child;
  final Widget? childEmpty;
  final String? isBlock;
  final String? buttonTitle;
  final String title, subTitle;
  final VoidCallback? onTap;
  final TextStyle? titleStyle;
  final TextStyle? subTitleStyle;
  final bool? isNeedLoadingWidget;
  final bool? isLoadingCenter;

  /// Opt-in gradient fill for the retry/refresh button (e.g.
  /// [ColorManager.brandGradientColors]). Null (the default for every
  /// existing caller) keeps the current transparent-with-border look.
  final List<Color>? buttonBackgroundColors;

  /// Opt-in border colour override for the retry/refresh button. Only
  /// meaningful together with [buttonBackgroundColors] (usually
  /// [ColorManager.transparent], since a filled gradient button doesn't need
  /// a visible border) — ignored otherwise.
  final Color? buttonBorderColor;

  @override
  Widget build(BuildContext context) {
    if (reqState.isLoading) {
      return (isNeedLoadingWidget == false)
          ? child
          : LoadingView(isLoadingCenter: isLoadingCenter);
    } else if (reqState.isError) {
      return ErrorView(
        onTap: onTap,
        isBlock: isBlock,
        subTitleStyle: subTitleStyle,
        titleStyle: titleStyle,
        buttonBackgroundColors: buttonBackgroundColors,
        buttonBorderColor: buttonBorderColor,
      );
    } else if (reqState.isOffline) {
      return _OfflineView(
        onTap: onTap,
        subTitleStyle: subTitleStyle,
        titleStyle: titleStyle,
        buttonBackgroundColors: buttonBackgroundColors,
        buttonBorderColor: buttonBorderColor,
      );
    } else if (reqState.userBan) {
      return BanUserWidget(
        onTap: onTap,
        subTitleStyle: subTitleStyle,
        titleStyle: titleStyle,
        title: title,
        message: subTitle,
      );
    } else if (reqState.isEmpty) {
      return childEmpty ??
          EmptyView(
            title: title,
            subTitle: subTitle,
            onTap: onTap,
            subTitleStyle: subTitleStyle,
            titleStyle: titleStyle,
            buttonTitle: buttonTitle,
            buttonBackgroundColors: buttonBackgroundColors,
            buttonBorderColor: buttonBorderColor,
          );
    } else {
      return child;
    }
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.isLoadingCenter});

  final bool? isLoadingCenter;
  @override
  Widget build(BuildContext context) {
    // Was LoadingAnimationWidget.staggeredDotsWave(color: ColorManager.
    // primary) in this branch and a flat CircularProgressIndicator.adaptive
    // in _NewLoadingView below — on request every loading state in the app
    // now shows the same single design: just GradientLoader (the brand
    // pink->purple ring), no text, both themes.
    return ConstantsManager.isTheme1
        ? _NewLoadingView(isLoadingCenter: isLoadingCenter)
        : isLoadingCenter ?? false
        ? SizedBox(
      height: 320.h,
      child: Center(child: GradientLoader(size: 30.h)),
    )
        : Center(child: GradientLoader(size: 30.h));
  }
}

class _NewLoadingView extends StatelessWidget {
  const _NewLoadingView({required this.isLoadingCenter});

  final bool? isLoadingCenter;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: 45.w,
      height: 45.h,
      decoration: BoxDecoration(
        color: ColorManager.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: ColorManager.black.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: ColorManager.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: GradientLoader(size: 22.5.w, strokeWidth: 2),
      ),
    );

    return isLoadingCenter ?? false
        ? SizedBox(
      height: 320.h,
      child: Center(child: content),
    )
        : Center(child: content);
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    this.onTap,
    this.isBlock,
    this.subTitleStyle,
    this.titleStyle,
    this.buttonBackgroundColors,
    this.buttonBorderColor,
  });
  final VoidCallback? onTap;
  final String? isBlock;
  final TextStyle? titleStyle;
  final TextStyle? subTitleStyle;
  final List<Color>? buttonBackgroundColors;
  final Color? buttonBorderColor;

  @override
  Widget build(BuildContext context) {
    return ErrorOrEmptyWidget(
      image: AssetsManager.error,
      title: StringManager.someWrong.tr(),
      message: isBlock ?? StringManager.someThingWrong.tr(),
      onTap: onTap,
      titleStyle: titleStyle,
      subTitleStyle: subTitleStyle,
      buttonBackgroundColors: buttonBackgroundColors,
      buttonBorderColor: buttonBorderColor,
    );
  }
}

class _OfflineView extends StatelessWidget {
  const _OfflineView({
    this.onTap,
    this.subTitleStyle,
    this.titleStyle,
    this.buttonBackgroundColors,
    this.buttonBorderColor,
  });

  final VoidCallback? onTap;
  final TextStyle? titleStyle;
  final TextStyle? subTitleStyle;
  final List<Color>? buttonBackgroundColors;
  final Color? buttonBorderColor;

  @override
  Widget build(BuildContext context) {
    return ErrorOrEmptyWidget(
      image: AssetsManager.noWifi,
      title: StringManager.noConnection.tr(),
      message: StringManager.unableToConnect.tr(),
      onTap: onTap,
      titleStyle: titleStyle,
      subTitleStyle: subTitleStyle,
      buttonBackgroundColors: buttonBackgroundColors,
      buttonBorderColor: buttonBorderColor,
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    this.onTap,
    required this.title,
    this.titleStyle,
    this.subTitleStyle,
    this.buttonTitle,
    required this.subTitle,
    this.buttonBackgroundColors,
    this.buttonBorderColor,
  });
  final String title, subTitle;
  final String? buttonTitle;
  final VoidCallback? onTap;
  final TextStyle? titleStyle;
  final TextStyle? subTitleStyle;
  final List<Color>? buttonBackgroundColors;
  final Color? buttonBorderColor;

  @override
  Widget build(BuildContext context) {
    return ErrorOrEmptyWidget(
      image: AssetsManager.empty,
      title: tr(title),
      message: tr(subTitle),
      onTap: onTap,
      titleStyle: titleStyle,
      subTitleStyle: subTitleStyle,
      buttonTitle: buttonTitle,
      buttonBackgroundColors: buttonBackgroundColors,
      buttonBorderColor: buttonBorderColor,
    );
  }
}

class ErrorOrEmptyWidget extends StatelessWidget {
  const ErrorOrEmptyWidget({
    super.key,
    required this.image,
    required this.title,
    required this.message,
    this.onTap,
    this.size,
    this.titleStyle,
    this.subTitleStyle,
    this.buttonTitle,
    this.buttonColor,
    this.buttonBackgroundColors,
    this.buttonBorderColor,
  });

  final String image;
  final String? buttonTitle;
  final String title;
  final String message;
  final VoidCallback? onTap;
  final double? size;
  final TextStyle? titleStyle;
  final TextStyle? subTitleStyle;
  final Color? buttonColor;

  /// Opt-in gradient fill for the retry button (e.g. the brand gradient).
  /// Null keeps the existing transparent/outline look everywhere else.
  final List<Color>? buttonBackgroundColors;
  final Color? buttonBorderColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.paddingOnly(start: 10, end: 10),
      // SingleChildScrollView instead of a bare Align -- this empty-state is
      // reused all over the app, including places that (deliberately) don't
      // give it a fixed height so it hugs its own content (e.g. LuckyBox's
      // bottomDailog). During the loading→loaded transition the ambient
      // constraint can momentarily be far smaller than this Column's natural
      // (mainAxisSize.min) height, and Align never clips/scrolls -- it just
      // overflows (the red/yellow stripes). Wrapping in a scroll view means
      // a too-small constraint just becomes scrollable instead of crashing
      // the frame; with a normal, sufficient constraint this is a no-op.
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (image.isNotEmpty)
              Padding(
                padding: context.paddingOnly(
                    end: image == AssetsManager.loading ? 15 : 0),
                child: Lottie.asset(
                  image,
                  height: size?.h ?? 90.h,
                  width: size?.w ?? 90.w,
                ),
              ),
            TextWidget(
              title,
              textAlign: TextAlign.center,
              style: titleStyle ??
                  context.bodyLarge.w600.colorExt(ColorManager.textPrimary),
            ),
            5.hBox,
            TextWidget(
              message,
              textAlign: TextAlign.center,
              style: subTitleStyle ??
                  context.bodyMedium.copyWith(
                    color: ColorManager.secondaryText,
                    height: 1.30,
                  ),
            ),
            if (onTap != null) ...[
              30.hBox,
              Padding(
                padding: context.paddingSymmetric(horizontal: 30),
                child: ButtonWidget(
                  title: buttonTitle ?? StringManager.refresh.tr(),
                  // A gradient fill (buttonBackgroundColors) takes over the
                  // background entirely — ButtonWidget already treats a
                  // gradient and a flat backgroundColor as mutually
                  // exclusive, so this stays a plain fallback for the
                  // non-gradient callers.
                  backgroundColor: buttonColor ?? ColorManager.transparent,
                  backgroundColors: buttonBackgroundColors,
                  // White reads on every gradient fill this app uses; a
                  // caller with a gradient always wants it instead of
                  // whatever titleStyle/textPrimary would otherwise give.
                  titleColor: buttonBackgroundColors != null
                      ? ColorManager.white
                      : titleStyle?.color ?? ColorManager.textPrimary,
                  // A caller that passed [titleStyle] has already declared what
                  // reads on ITS surface — reels is a permanently black shell,
                  // where the panel's dark text_primary_color renders an
                  // invisible dark-on-black "Refresh". Reuse that colour instead
                  // of assuming the page is light.
                  borderColor: buttonBorderColor ?? ColorManager.primary,
                  fontWeight: FontWeight.w400,
                  onPressed: onTap ?? () {},
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class BanUserWidget extends StatelessWidget {
  const BanUserWidget({
    super.key,
    required this.title,
    required this.message,
    this.onTap,
    this.size,
    this.titleStyle,
    this.subTitleStyle,
    this.buttonTitle,
    this.buttonColor,
  });

  final String? buttonTitle;
  final String title;
  final String message;
  final VoidCallback? onTap;
  final double? size;
  final TextStyle? titleStyle;
  final TextStyle? subTitleStyle;
  final Color? buttonColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.paddingOnly(start: 10, end: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AssetsManager.ban,
            height: size?.h ?? 90.h,
            width: size?.w ?? 90.w,
            // fit: BoxFit.cover,
          ),
          10.hBox,
          TextWidget(
            title,
            textAlign: TextAlign.center,
            style:
            titleStyle ?? context.bodyLarge.w600.colorExt(ColorManager.red),
          ),
          5.hBox,
        ],
      ),
    );
  }
}