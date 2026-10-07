import 'package:flutter/cupertino.dart';
import 'package:general/src/core/index.dart';

class DailyPrizeItem extends StatelessWidget {
  const DailyPrizeItem({
    super.key,
    this.day,
    this.image,
    this.takenPrize,
    this.isLastDay,
    this.isThisDay,
    this.size,
  });

  final String? image;
  final bool? takenPrize;
  final bool? isLastDay;
  final bool? isThisDay;
  final int? day;
  final double? size;

  /// Same hardcoded accent used by the dialog's purple/gold theme, so this
  /// card reads correctly regardless of the admin panel's brand color.
  static const _accentPurple = Color(0xFF8E7CF7);
  static const _accentGold = Color(0xFFFE7E07);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: 50.radius,
      child: Container(
        height: 100.h,
        margin: context.paddingSymmetric(horizontal: 3.0),
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: 12.radius,
          border: Border.all(
            color: isThisDay == true ? _accentPurple : ColorManager.transparent,
            width: isThisDay == true ? 1.6 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: ColorManager.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.topStart,
              child: Container(
                padding: context.paddingSymmetric(vertical: 0.6, horizontal: 7),
                decoration: BoxDecoration(
                  color: _accentGold,
                  borderRadius: BorderRadius.only(
                    topLeft: Methods.getLang() == 'ar'
                        ? 0.radiusCircular
                        : 12.radiusCircular,
                    bottomRight: Methods.getLang() == 'ar'
                        ? 0.radiusCircular
                        : 12.radiusCircular,
                    topRight: Methods.getLang() == 'ar'
                        ? 12.radiusCircular
                        : 0.radiusCircular,
                    bottomLeft: Methods.getLang() == 'ar'
                        ? 12.radiusCircular
                        : 0.radiusCircular,
                  ),
                ),
                child: Text(
                  '$day',
                  style: context.bodyMedium.w600.colorExt(ColorManager.white),
                ),
              ),
            ),
            (image!.contains(".svga") || image!.contains(".zz"))
                ? CacheSvgaWidget(
              isStopErrorAndLoadingFrame: false,
              url: image ?? '',
              width: 40.w,
              height: 40.w,
              boxFit: BoxFit.cover,
            )
                : ImageViewWidget(
              url: image ?? "",
              height: size ?? 40.h,
              width: size ?? 40.w,
              boxFit: BoxFit.contain,
            ),
            10.hBox,
            if (takenPrize == true) ...[
              Icon(
                CupertinoIcons.checkmark,
                color: _accentPurple,
                size: 18.h,
              )
            ] else ...[
              18.hBox,
            ]
          ],
        ),
      ),
    );
  }
}