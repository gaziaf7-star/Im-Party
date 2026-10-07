part of '../level_page.dart';

class LevelTabBar extends StatelessWidget {
  final TabController controller;

  const LevelTabBar({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.paddingSymmetric(horizontal: 10, vertical: 5),
      margin: context.paddingSymmetric(horizontal: 15, vertical: 8),
      child: TabBar(
        controller: controller,
        indicatorSize: TabBarIndicatorSize.label,
        overlayColor: WidgetStateProperty.all(ColorManager.transparent),
        dividerHeight: 0,
        indicator: const BoxDecoration(),
        labelColor: ColorManager.black,
        splashFactory: NoSplash.splashFactory,
        indicatorColor: ColorManager.transparent,
        labelPadding: context.paddingSymmetric(horizontal: 12, vertical: 5),
        unselectedLabelStyle: context.bodyMedium
            .colorExt(ColorManager.black.withValues(alpha: (0.35))),
        labelStyle: context.bodyMedium.bold.size(16).colorExt(ColorManager.black),
        tabs: [
          Text(
            StringManager.wealth.tr(),
          ),
          Text(
            StringManager.charm.tr(),
          ),
          Text(
            StringManager.charge.tr(),
          ),
        ],
      ),
    );
  }
}