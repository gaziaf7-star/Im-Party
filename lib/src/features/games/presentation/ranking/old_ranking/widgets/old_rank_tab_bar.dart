import 'package:general/src/core/index.dart';

class OldTopTabBar extends StatelessWidget {
  final TabController controller;
  final bool fromRoom;

  const OldTopTabBar({
    required this.controller,
    required this.fromRoom,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32.h,
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.label,
        controller: controller,
        dividerHeight: 0,
        dividerColor: ColorManager.transparent,
        overlayColor: WidgetStateColor.transparent,
        indicatorColor: Colors.white,
        indicatorPadding: context.paddingSymmetric(horizontal: 0),
        labelStyle: context.bodyLarge.bold.colorExt(ColorManager.white),
        unselectedLabelStyle: context.bodyLarge.w600.colorExt(
          ColorManager.whiteColor.withValues(alpha: 0.6),
        ),
        labelPadding: context.paddingSymmetric(horizontal: 7),
        tabs: [
          Text(StringManager.room.tr()),
          Text(StringManager.wealth.tr()),
          Text(StringManager.charm.tr()),
          Text(StringManager.games.tr()),
          Text(StringManager.agency1.tr()),
          Text(StringManager.lucky.tr()),
        ],
      ),
    );
  }
}
