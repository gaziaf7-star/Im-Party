import 'package:general/src/core/index.dart';

class TopTabBar extends StatelessWidget {
  final TabController controller;
  final bool fromRoom;
  const TopTabBar(
      {required this.controller, required this.fromRoom, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32.h,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final isFirstTab = controller.index == 0;
          final selectedColor =
          isFirstTab ? Colors.black : ColorManager.whiteColor;
          final unselectedColor = isFirstTab
              ? Colors.black.withValues(alpha: 0.6)
              : ColorManager.whiteColor.withValues(alpha: 0.6);

          return TabBar(
            indicatorSize: TabBarIndicatorSize.label,
            controller: controller,
            dividerHeight: 0,
            dividerColor: ColorManager.transparent,
            overlayColor: WidgetStateColor.transparent,
            indicatorColor: isFirstTab ? Colors.black : Colors.white,
            indicatorPadding: context.paddingSymmetric(horizontal: 0),
            labelStyle: context.bodyLarge.bold.colorExt(selectedColor),
            unselectedLabelStyle:
            context.bodyLarge.w600.colorExt(unselectedColor),
            labelPadding: context.paddingSymmetric(horizontal: 7),
            tabs: [
              Text(StringManager.room.tr()),
              Text(StringManager.wealth.tr()),
              Text(StringManager.charm.tr()),
              Text(StringManager.games.tr()),
              Text(StringManager.agency1.tr()),
              Text(StringManager.lucky.tr()),
            ],
          );
        },
      ),
    );
  }
}