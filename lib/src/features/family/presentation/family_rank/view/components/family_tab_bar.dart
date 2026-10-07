part of '../family_rank_page.dart';

class _FamilyTabBar extends StatelessWidget {
  final TabController controller;

  const _FamilyTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      margin: context.paddingSymmetric(horizontal: 20),
      padding: context.paddingSymmetric(vertical: 3,horizontal: 3),
      decoration: BoxDecoration(
        color: ColorManager.black.withValues(alpha: (0.15 )),
        borderRadius: 30.radius,
        border: Border.all(color: ColorManager.white,width: 0.3),
      ),
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        controller: controller,
        isScrollable: false,
        indicatorColor: ColorManager.white,
        dividerHeight: 0,
        labelStyle: context.bodyLarge.size(15).bold.colorExt(ColorManager.textPrimary,),
        unselectedLabelStyle: context.bodyLarge.size(15).w600.colorExt(ColorManager.textPrimary.withValues(alpha: (0.7 )),),
        labelPadding: EdgeInsets.zero,
        indicator: ColorManager.primaryDecoration(borderRadius: 30.radius),
        tabs: [
          Text(StringManager.daily.tr()),
          Text(StringManager.weekly.tr()),
          Text(StringManager.monthly.tr()),
        ],
      ),
    );

    // return Container(
    //   padding: context.paddingOnly(bottom: 10),
    //   color: ColorManager.white,
    //   child: TabBar(
    //     controller: controller,
    //     overlayColor: WidgetStateColor.transparent,
    //     indicatorSize: TabBarIndicatorSize.label,
    //     indicatorPadding:
    //         EdgeInsets.symmetric(vertical: -2.5.h, horizontal: 5.w),
    //     dividerHeight: 0,
    //     indicatorColor: ColorManager.black,
    //     labelPadding: context.paddingOnly(start: 10),
    //     unselectedLabelStyle:
    //         context.bodyMedium.colorExt(ColorManager.textColor),
    //     labelStyle: context.bodyMedium.w600,
    //     tabs:  [
    //       Text(StringManager.today.tr()),
    //       Text(StringManager.weekly.tr()),
    //       Text(StringManager.monthly.tr()),
    //     ],
    //   ),
    // );
  }
}
