part of '../old_rank_screen.dart';

class OldInnerTabBar extends StatelessWidget {
  final TabController tabController;
  final Color color;
  final int index;

  const OldInnerTabBar({
    required this.tabController,
    required this.index,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      margin: context.paddingSymmetric(horizontal: 20),
      padding: context.paddingSymmetric(vertical: 3, horizontal: 3),
      decoration: BoxDecoration(
        color: ColorManager.black.withValues(alpha: 0.15),
        borderRadius: 30.radius,
        border: Border.all(color: ColorManager.white, width: 0.3),
      ),
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        controller: tabController,
        isScrollable: false,
        indicatorColor: ColorManager.white,
        dividerHeight: 0,
        labelStyle: context.bodyLarge.size(15).bold.colorExt(
              ColorManager.textPrimary,
            ),
        unselectedLabelStyle: context.bodyLarge.size(15).w600.colorExt(
              ColorManager.whiteColor.withValues(alpha: 0.7),
            ),
        labelPadding: EdgeInsets.zero,
        indicator: ColorManager.primaryDecoration(borderRadius: 30.radius),
        tabs: [
          Text(StringManager.hourly.tr()),
          Text(StringManager.daily.tr()),
          Text(StringManager.weekly.tr()),
          Text(StringManager.monthly.tr()),
        ],
      ),
    );
  }
}
