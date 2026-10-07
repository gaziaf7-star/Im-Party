import 'package:general/src/features/games/games.dart';

import '../../../../../../../../core/widgets/md_indicator.dart';

class VisitorTabBar extends StatelessWidget {
  final TabController controller;
  final int usersNo;

  const VisitorTabBar(
      {super.key, required this.controller, required this.usersNo});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      tabAlignment: TabAlignment.start,
      controller: controller,
      overlayColor: WidgetStateColor.transparent,
      dividerHeight: 0,
      isScrollable: true,
      splashFactory: NoSplash.splashFactory,
      labelPadding: context.paddingSymmetric(horizontal: 15, vertical: 5),
      indicator: MDIndicator(
        radius: 20.r,
        indicatorSize: MDIndicatorSize.normal,
        indicatorHeight: 3,
        indicatorWidth: 30.w,
        // App brand colour instead of flat black, per request -- this
        // sheet's bg/text are fixed white/black, but the active-tab
        // indicator should still read as "the app's colour", same as the
        // Room Information page's own TabBar underline.
        indicatorColor: ColorManager.primary,
      ),
      tabs: [
        TextWidget(
          di<RoomStateManager>().isInAudioRoom
              ? StringManager.onlineUser.tr()
              : "${StringManager.onlineUser.tr()} ($usersNo)",
          style: context.bodyLarge.bold.colorExt(ColorManager.black),
        ),
        TextWidget(
          di<RoomStateManager>().isInAudioRoom
              ? StringManager.roomManager.tr()
              : StringManager.liveManager.tr(),
          style: context.bodyLarge.bold.colorExt(ColorManager.black),
        ),
      ],
    );
  }
}