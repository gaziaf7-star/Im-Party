part of 'package:general/src/features/room/presentation/component/room_header/rank_room/view/rank_room_page.dart';

class _HeaderTabBarBody extends StatelessWidget {
  final TabController controller;

  const _HeaderTabBarBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ScreenUtil().screenWidth,
      child: Padding(
        padding: context.paddingSymmetric(horizontal: 5),
        child: TabBar(
          indicatorSize: TabBarIndicatorSize.label,
          controller: controller,
          // tabAlignment: TabAlignment.start,
          // isScrollable: true,
          dividerHeight: 0,
          dividerColor: ColorManager.transparent,
          overlayColor: WidgetStateColor.transparent,
          indicator: MDIndicator(
            // Brand gradient instead of a flat white bar, on request.
            indicatorGradient: ColorManager.brandGradient,
            indicatorWidth: 17.0.w,
            indicatorHeight: 4.h,
            radius: 20,
          ),
          indicatorPadding:
              context.paddingOnly(bottom: 10),
          // Selected-tab text fixed to black on request (was the
          // theme-driven textPrimary, which reads light/white here).
          labelStyle: context.bodyLarge.bold.colorExt(ColorManager.black),
          unselectedLabelStyle: context.bodyLarge.w600
              .colorExt(ColorManager.textPrimary.withValues(alpha: (0.6 ))),
          labelPadding: context.paddingSymmetric(horizontal: 7),
          tabs: [
            Tab(text: StringManager.wealth.tr()),
            Tab(text: StringManager.charm.tr())
          ],
        ),
      ),
    );
  }
}
