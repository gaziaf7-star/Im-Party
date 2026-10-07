part of 'package:general/src/features/profile/presentation/f_f_f_v/view/page/f_f_f_screen.dart';

class TabBarWidget extends StatelessWidget {
  final TabController controller;

  const TabBarWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TabBar(
     
      controller: controller,
      overlayColor: WidgetStateColor.transparent,
      indicatorSize: TabBarIndicatorSize.label,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      // horizontal removed: short labels narrower than the inset throw
      // "indicatorPadding insets should be less than Tab Size". Vertical-only is safe.
      indicatorPadding: EdgeInsets.symmetric(vertical: -2.5.h),
      dividerHeight: 0,
      indicatorColor: ColorManager.black,
      labelPadding: context.paddingSymmetric(horizontal: 20),
      unselectedLabelStyle: context.bodyMedium.colorExt(ColorManager.secondaryText),
      labelStyle: context.bodyMedium.w600,
      tabs:  [
        TextWidget(
          StringManager.following.tr(),
        ),
        TextWidget(
          StringManager.followers.tr(),
        ),
        TextWidget(
          StringManager.friends.tr(),
        ),
        TextWidget(
          StringManager.visitors.tr(),
        ),
      ],
    );
  }
}
