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
    // White titles; the selected one is larger with a short white underline.
    return SizedBox(
      height: 40.h,
      child: TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.center,
        indicatorSize: TabBarIndicatorSize.label,
        controller: controller,
        dividerHeight: 0,
        dividerColor: ColorManager.transparent,
        overlayColor: WidgetStateColor.transparent,
        indicator: UnderlineTabIndicator(
          borderSide: const BorderSide(color: Colors.white, width: 3),
          borderRadius: BorderRadius.circular(3),
          insets: EdgeInsets.symmetric(horizontal: 14.w),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.65),
        labelStyle: context.bodyLarge.size(17).w600,
        unselectedLabelStyle: context.bodyLarge.size(15).w500,
        labelPadding: context.paddingSymmetric(horizontal: 10),
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
