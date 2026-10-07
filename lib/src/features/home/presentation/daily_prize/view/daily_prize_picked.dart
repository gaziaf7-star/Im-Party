import 'package:general/src/core/index.dart';

/// Professional white success dialog shown after claiming a daily reward.
///
/// Reward/API behaviour is intentionally unchanged. This file only updates
/// the presentation of the success state.
class DailyPrizePicked extends StatelessWidget {
  final String image;
  final String name;

  const DailyPrizePicked({
    super.key,
    required this.image,
    required this.name,
  });

  static const Color _titleColor = Color(0xFF111111);
  static const Color _subTitleColor = Color(0xFF6B7280);
  static const Color _softBackground = Color(0xFFF7F8FA);
  static const Color _borderColor = Color(0xFFE9EAED);
  static const Color _accentColor = Color(0xFFFFB020);

  @override
  Widget build(BuildContext context) {
    final dialogWidth =
    (ScreenUtil().screenWidth * 0.88).clamp(280.0, 390.0).toDouble();

    return Container(
      width: dialogWidth,
      padding: EdgeInsets.fromLTRB(22.w, 20.h, 22.w, 22.h),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: _borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorManager.black.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: Offset(0, 12.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSuccessIcon(),
          14.hBox,
          TextWidget(
            StringManager.youGetYourPrizeSuccess.tr(),
            style: context.titleLarge.bold
                .size(22)
                .colorExt(_titleColor),
            textAlign: TextAlign.center,
          ),
          18.hBox,
          _buildRewardPreview(),
          16.hBox,
          Container(
            constraints: BoxConstraints(minWidth: 110.w),
            padding: EdgeInsets.symmetric(
              horizontal: 18.w,
              vertical: 9.h,
            ),
            decoration: BoxDecoration(
              color: _softBackground,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: _borderColor),
            ),
            child: TextWidget(
              name,
              style: context.bodyMedium.bold
                  .size(15)
                  .colorExt(_titleColor),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          8.hBox,
          Container(
            width: 42.w,
            height: 3.h,
            decoration: BoxDecoration(
              color: _accentColor,
              borderRadius: BorderRadius.circular(99.r),
            ),
          ),
          22.hBox,
          _buildConfirmButton(context),
        ],
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 52.r,
      height: 52.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _accentColor.withValues(alpha: 0.12),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 36.r,
        height: 36.r,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: _accentColor,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.check_rounded,
          size: 23.r,
          color: ColorManager.white,
        ),
      ),
    );
  }

  Widget _buildRewardPreview() {
    return Container(
      width: double.infinity,
      height: 150.h,
      decoration: BoxDecoration(
        color: _softBackground,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _borderColor),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 104.r,
            height: 104.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ColorManager.white,
              boxShadow: [
                BoxShadow(
                  color: _accentColor.withValues(alpha: 0.14),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          _buildRewardImage(),
        ],
      ),
    );
  }

  Widget _buildRewardImage() {
    if (image.contains('.svga') || image.contains('.zz')) {
      return CacheSvgaWidget(
        isStopErrorAndLoadingFrame: false,
        url: image,
        height: 96.h,
        width: 110.w,
        boxFit: BoxFit.contain,
      );
    }

    return ImageViewWidget(
      url: image,
      height: 96.h,
      width: 110.w,
      boxFit: BoxFit.contain,
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () {
          // "Please complete information" nudge removed per request -- just
          // close the daily-prize sheet now.
          Navigator.pop(context);
        },
        child: Ink(
          width: double.infinity,
          height: 50.h,
          decoration: BoxDecoration(
            color: _titleColor,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: ColorManager.black.withValues(alpha: 0.14),
                blurRadius: 12,
                offset: Offset(0, 5.h),
              ),
            ],
          ),
          child: Center(
            child: TextWidget(
              StringManager.confirm.tr(),
              style: context.bodyMedium.bold
                  .size(15)
                  .colorExt(ColorManager.white),
            ),
          ),
        ),
      ),
    );
  }
}
