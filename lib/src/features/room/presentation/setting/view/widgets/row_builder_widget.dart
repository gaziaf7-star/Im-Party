part of '../setting_page.dart';

class RowBuilderWidget extends StatelessWidget {
  final String title;
  final Widget lastWidget;
  final Function() onTap;
  const RowBuilderWidget(
      {super.key,
        required this.title,
        required this.onTap,
        required this.lastWidget});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: ScreenUtil().screenWidth,
        padding: context.paddingSymmetric(horizontal: 10.w, vertical: 10.h),
        // Hardcoded white -- this whole page (setting_page.dart) is fixed
        // white/black now, so the admin-mutable scaffoldBg used here before
        // would have kept every row in this list dark even after the tab
        // bar and header above it turned white.
        decoration: const BoxDecoration(
          color: ColorManager.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget(
              title,
              style: context.bodyLarge.colorExt(ColorManager.black),
            ),
            lastWidget,
          ],
        ),
      ),
    );
  }
}