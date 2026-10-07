part of '../edit_profile_screen.dart';

class _RowEditInfo extends StatelessWidget {
  const _RowEditInfo({
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isFlagIcon,
    this.hasTrailing,
    this.isNeedTranslation,
  });

  final VoidCallback? onTap;
  final String? subtitle, trailing, title;
  final bool? hasTrailing, isFlagIcon, isNeedTranslation;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: ColorManager.white,
          border: Border.all(
              color: ColorManager.grey2.withValues(alpha: 0.3)),
          borderRadius: 10.radius,
        ),
        padding: context.paddingSymmetric(vertical: 20, horizontal: 10),
        child: Row(
          children: [
            Expanded(
              child: TextWidget(
                subtitle!,
                style: context.bodyMedium
                    .size(16)
                    .colorExt(ColorManager.black),
              ),
            ),
            isFlagIcon ?? false
                ? ImageViewWidget(height: 30, width: 30, url: title ?? '')
                : isNeedTranslation == true
                ? ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 220.w),
              child: TextWidget(
                title!,
                style: context.bodyMedium
                    .copyWith(overflow: TextOverflow.ellipsis)
                    .size(16)
                    .colorExt(ColorManager.black),
              ),
            )
                : ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 220.w),
              child: Text(
                title!,
                style: context.bodyMedium
                    .copyWith(overflow: TextOverflow.ellipsis)
                    .size(16)
                    .colorExt(ColorManager.black),
              ),
            ),
            10.wBox,
            hasTrailing == true
                ? Icon(
              Icons.arrow_forward_ios,
              color: ColorManager.black,
              size: 16.h,
            )
                : 15.wBox,
          ],
        ),
      ),
    );
  }
}