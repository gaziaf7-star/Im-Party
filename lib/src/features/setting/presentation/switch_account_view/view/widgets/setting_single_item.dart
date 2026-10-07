part of 'package:general/src/features/setting/presentation/settings_screen.dart';

class SettingSingleItem extends StatelessWidget {
  const SettingSingleItem({
    super.key,
    required this.title,
    required this.onTap,
    this.sizIcon,
    this.margin,
    this.isLogOut,
    this.isPaddingContainer,
  });

  final String title;
  final VoidCallback onTap;
  final double? sizIcon;
  final double? margin;
  final bool? isPaddingContainer;
  final bool? isLogOut;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: 4.radius,
      child: Container(
          margin: context.paddingSymmetric(vertical: margin ?? 0),
          padding: context.paddingSymmetric(
              horizontal: 18, vertical: isPaddingContainer ?? false ? 15 : 0),
          width: ScreenUtil().screenWidth,
          decoration: BoxDecoration(
            color: ColorManager.white,
            border: Border(
              bottom: BorderSide(
                color: ColorManager.grey2.withValues(alpha: 0.25),
                width: 0.6,
              ),
            ),
          ),
          child: isLogOut ?? false
              ? TextWidget(title.tr(),
              textAlign: TextAlign.center,
              style: context.bodyMedium
                  .size(15)
                  .w500
                  .colorExt(ColorManager.redAccount))
              : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextWidget(title.tr(),
                  textAlign: TextAlign.center,
                  style: context.bodyMedium.size(15).w500.colorExt(ColorManager.black)
              ),
              const Spacer(),
              Icon(
                color: ColorManager.black.withValues(alpha: 0.45),
                Icons.arrow_forward_ios,
                size: 10,
              ),
            ],
          )),
    );
  }
}