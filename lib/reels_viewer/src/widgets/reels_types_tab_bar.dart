import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/md_indicator.dart';

class ReelsTypesTabBar extends StatelessWidget {
  const ReelsTypesTabBar({super.key, required this.controller});

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
          indicatorHeight: 3.h,
          radius: 20),
      // horizontal removed (fixed-width centered indicator → visually identical)
      // to avoid "indicatorPadding insets should be less than Tab Size" crash.
      indicatorPadding: EdgeInsets.symmetric(vertical: -2.5.h),
      dividerHeight: 0,
      indicatorColor: ColorManager.textPrimary,
      labelPadding: context.paddingSymmetric(horizontal: 10),
      unselectedLabelStyle:
          context.bodyMedium.colorExt(ColorManager.idGreyColor).bold.size(16),
      labelStyle:
          context.bodyMedium.colorExt(ColorManager.textPrimary).bold.size(16),
      tabs: [
        Text(StringManager.following.tr()),
        Text(StringManager.forYou.tr()),
      ],
    );
  }
}
