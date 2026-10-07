part of 'package:general/src/features/room/presentation/component/room_header/rank_room/view/rank_room_page.dart';

class _TabBarBody extends StatelessWidget {
  final TabController controller;
  final int index;
  const _TabBarBody({required this.controller, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      margin: context.paddingSymmetric(horizontal: 20),
      padding: context.paddingSymmetric(vertical: 3, horizontal: 3),
      decoration: BoxDecoration(
        color: ColorManager.black.withValues(alpha: (0.15 )),
        borderRadius: 30.radius,
        //border: Border.all(color: ColorManager.white,width: 0.3),
      ),
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        controller: controller,
        isScrollable: false,
        dividerHeight: 0,
        labelStyle: context.bodyLarge.size(15).bold.colorExt(
              ColorManager.blackColor,
            ),
        unselectedLabelStyle: context.bodyLarge.size(15).w600.colorExt(
              ColorManager.white.withValues(alpha: (0.7 )),
            ),
        labelPadding: EdgeInsets.zero,
        // Brand gradient pill instead of a flat white one, on request --
        // label stays black (already was) since it now sits on a gradient
        // rather than plain white.
        indicator: BoxDecoration(
          borderRadius: 30.radius,
          gradient: ColorManager.brandGradient,
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
