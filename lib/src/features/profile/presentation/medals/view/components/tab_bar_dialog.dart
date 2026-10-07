part of '../medals_page.dart';

class TabBarDialog extends StatelessWidget {
  final TabController controller;

  const TabBarDialog({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.h,
      child: TabBar(
        labelPadding: context.paddingSymmetric(
          horizontal: 30,
        ),
        controller: controller,
        automaticIndicatorColorAdjustment: false,
        indicatorWeight: 1,
        indicatorColor: ColorManager.transparent,
        dividerHeight: 0,
        unselectedLabelStyle: context.bodyLarge.w400.colorExt(ColorManager.secondaryText),
        padding: EdgeInsets.zero,
        labelStyle: context.bodyLarge.w600.colorExt(ColorManager.textPrimary),
        tabs: [
          Text(StringManager.recharge.tr()),
          Text(StringManager.gift.tr()),
        ],
      ),
    );
  }
}
