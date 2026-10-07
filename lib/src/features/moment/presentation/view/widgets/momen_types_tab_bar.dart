part of 'package:general/src/features/moment/presentation/view/moment_page.dart';

class _MomentTypesTabBar extends StatelessWidget {
  const _MomentTypesTabBar({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      overlayColor: WidgetStateColor.transparent,
      indicatorSize: TabBarIndicatorSize.label,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      indicator: MDIndicator(
          indicatorColor: ColorManager.textPrimary,
          indicatorWidth: 17.w,
          indicatorHeight: 4.h,
          radius: 20),
      // horizontal removed (fixed-width centered indicator → visually identical)
      // to avoid "indicatorPadding insets should be less than Tab Size" crash.
      indicatorPadding: EdgeInsets.symmetric(vertical: -2.5.h),
      dividerHeight: 0,
      indicatorColor: ColorManager.textPrimary,
      labelPadding: context.paddingSymmetric(horizontal: 10),
      // Bumped 14 -> 17 per owner request ("text should be a bit bigger").
      unselectedLabelStyle: context.bodyMedium
          .colorExt(ColorManager.textPrimary.withValues(alpha: 0.5))
          .size(17),
      labelStyle:
      context.bodyMedium.w600.size(17).colorExt(ColorManager.textPrimary),
      tabs: [
        Text(StringManager.follow.tr()),
        Text(StringManager.recommend.tr()),
        Text(StringManager.latest.tr()),
      ],
    );
  }
}