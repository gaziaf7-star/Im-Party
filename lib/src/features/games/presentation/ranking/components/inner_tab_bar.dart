part of'../rank_screen.dart';

class InnerTabBar extends StatelessWidget {
  final TabController tabController;
  final Color color;
  final int index;
  const InnerTabBar(
      {required this.tabController,
      required this.index,
      required this.color,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      margin: context.paddingSymmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: ColorManager.black.withValues(alpha: (0.15)),
        borderRadius: 30.radius,
        // border: Border.all(color: ColorManager.white,width: 0.3),
      ),
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        controller: tabController,
        isScrollable: false,
        indicatorColor: ColorManager.white,
        dividerHeight: 0,
        labelStyle: context.bodyLarge.size(15).bold.colorExt(ColorManager.white,),
        unselectedLabelStyle: context.bodyLarge.size(15).colorExt(ColorManager.textPrimary.withValues(alpha: (0.7 )),),
        labelPadding: EdgeInsets.zero,
        indicator: BoxDecoration(
          borderRadius: 30.radius,
          color: ColorManager.primary,
          // gradient: const LinearGradient(
          //   begin: AlignmentDirectional.topCenter,
          //   end: AlignmentDirectional.bottomCenter,
          //   colors: ColorManager.vipBuyButtonGradient,
          // ),
        ),
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
