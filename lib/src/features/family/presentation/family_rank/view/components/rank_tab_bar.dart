part of '../family_rank_page.dart';
class RankTabBar extends StatelessWidget {
  final TabController controller;

  const RankTabBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: ScreenUtil().screenWidth ,
        child: TabBar(
            controller: controller,
            tabAlignment: TabAlignment.fill,
            overlayColor: WidgetStateColor.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            // Horizontal padding here was wider than the tab itself on small
            // devices → "indicatorPadding insets should be less than Tab Size".
            indicatorPadding: context.paddingSymmetric(vertical: -2.5.h),
            dividerHeight: 0,
            isScrollable: false,
            splashFactory: NoSplash.splashFactory,
            labelPadding: context.paddingSymmetric(horizontal:  6),
            unselectedLabelStyle: context.bodyLarge.size(18).w600.colorExt(ColorManager.secondaryText),
            labelStyle: context.bodyLarge.size(18).bold.colorExt(ColorManager.onDark,),
            indicator: MDIndicator(
              radius: 20.r,
              indicatorSize: MDIndicatorSize.normal,
              indicatorHeight: 4,
              indicatorWidth: 30.w,
              indicatorColor: ColorManager.white,
            ),
            tabs: [
              FittedBox(child: Text(StringManager.ranking.tr())),
              FittedBox(child: Text(StringManager.families.tr())),
            ],
            ),
        );
    }
}