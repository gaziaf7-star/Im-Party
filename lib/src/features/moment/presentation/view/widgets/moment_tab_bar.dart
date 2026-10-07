part of 'package:general/src/features/moment/presentation/view/moment_page.dart';

class _MomentTabBar extends StatelessWidget {
  const _MomentTabBar({required this.controller});

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
      indicatorColor: ColorManager.black,
      labelPadding: context.paddingOnly(start: 10),
      unselectedLabelStyle: context.bodyMedium
          .colorExt(ColorManager.textPrimary.withValues(alpha: 0.7))
          .size(18),
      labelStyle:
          context.bodyMedium.w600.size(18).colorExt(ColorManager.textPrimary),
      tabs: [
        Text(StringManager.moment.tr()),
        Text(StringManager.online.tr()),
      ],
    );
  }
}
