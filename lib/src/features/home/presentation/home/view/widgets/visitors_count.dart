import 'package:general/src/core/index.dart';

class VisitorsCount extends StatelessWidget {
  final String count;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool isList;
  final bool isTop;
  final Color? color;
  final String? icon;

  const VisitorsCount({
    super.key,
    required this.count,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.isList = false,
    this.isTop = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (isList) {
      return _buildListView();
    } else if (isTop) {
      return _buildWhiteIconView(context);
    } else {
      return _buildDefaultView(context);
    }
  }

  Widget _buildListView() {
    return Container(
      padding: ConstantsManager.isTheme1
          ? navKey.currentContext
              ?.paddingSymmetric(horizontal: 5.0, vertical: 1.0)
          : null,
      decoration: ConstantsManager.isTheme1
          ? BoxDecoration(
              color: ColorManager.black.withValues(alpha: 0.3),
              borderRadius: 30.radius,
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (ConstantsManager.isTheme1 == true) ...[
            ImageWidget(
              height: 14.h,
              width: 14.h,
              image: icon ?? AssetsManager.icStartLive,
            ),
            3.wBox,
          ],
          if (ConstantsManager.isTheme1 == false)
            Image.asset(
              AssetsManager.newSoundWave,
              height: 19.h,
              width: 19.h,
            ),
          TextWidget(
            count,
            style: TextStyle(
              color: color ?? ColorManager.textPrimary,
              fontSize: fontSize ?? 10,
              fontWeight: fontWeight ?? FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultView(BuildContext context) {
    return Padding(
      padding: context.paddingSymmetric(horizontal: 5, vertical: 1.0),
      child: Container(
        padding: ConstantsManager.isTheme1
            ? navKey.currentContext
                ?.paddingSymmetric(horizontal: 5.0, vertical: 1.0)
            : null,
        decoration: ConstantsManager.isTheme1
            ? BoxDecoration(
                color: ColorManager.black.withValues(alpha: 0.3),
                borderRadius: 30.radius,
              )
            : null,
        child: Row(
          children: [
            if (ConstantsManager.isTheme1 == true) ...[
              ImageWidget(
                height: 14.h,
                width: 14.h,
                image: icon ?? AssetsManager.icStartLive,
              ),
              3.wBox,
            ],
            if (ConstantsManager.isTheme1 == false)
              Image.asset(
                AssetsManager.newSoundWave,
                color: ColorManager.primary,
                height: 19.h,
                width: 19.h,
              ),
            TextWidget(
              count,
              style: context.bodyMedium
                  .size(fontSize ?? 9)
                  .colorExt(color ?? ColorManager.textPrimary)
                  .copyWith(
                    fontWeight: fontWeight ?? FontWeight.w400,
                  ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildWhiteIconView(BuildContext context) {
    return Padding(
      padding: context.paddingSymmetric(horizontal: 5, vertical: 1),
      child: Container(
        padding: ConstantsManager.isTheme1
            ? navKey.currentContext
                ?.paddingSymmetric(horizontal: 5.0, vertical: 1.0)
            : null,
        decoration: ConstantsManager.isTheme1
            ? BoxDecoration(
                color: ColorManager.black.withValues(alpha: 0.3),
                borderRadius: 30.radius,
              )
            : null,
        child: Row(
          children: [
            if (ConstantsManager.isTheme1 == true) ...[
              ImageWidget(
                height: 14.h,
                width: 14.h,
                image: icon ?? AssetsManager.icStartLive,
              ),
              3.wBox,
            ],
            if (ConstantsManager.isTheme1 == false)
              Image.asset(
                AssetsManager.newSoundWave,
                color: ColorManager.onDark,
                height: 19.0.h,
                width: 19.0.h,
              ),
            TextWidget(
              count,
              style: context.bodyMedium
                  .colorExt(ColorManager.onDark)
                  .size(fontSize ?? 12)
                  .copyWith(
                    fontWeight: fontWeight ?? FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
