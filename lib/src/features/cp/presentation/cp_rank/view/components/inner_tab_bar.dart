part of'../cp_rank.dart';

class InnerTabBar extends StatelessWidget {
  final TabController tabController;
  final Color color;
  const InnerTabBar(
      {required this.tabController,
      required this.color,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      margin: context.paddingSymmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: ColorManager.white.withValues(alpha: (0.2 )),
        borderRadius: 30.radius,
      ),
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        controller: tabController,
        isScrollable: false,
        indicatorColor: ColorManager.white,
        dividerHeight: 0,
        labelStyle: context.bodyLarge.size(13).bold.colorExt(ColorManager.pink.withValues(alpha:0.5)),
        unselectedLabelStyle: context.bodyLarge.size(13).w600.colorExt(ColorManager.textPrimary.withValues(alpha: (0.5 )),),
        labelPadding: EdgeInsets.zero,
        indicator: BoxDecoration(
          borderRadius: 30.radius,
          color: Colors.white
        ),
        tabs: [
          Text(StringManager.daily.tr()),
          Text(StringManager.weekly.tr()),
          Text(StringManager.monthly.tr()),
        ],
      ),
    );
  }
}
