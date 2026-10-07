part of '../medals_page.dart';

class MedalsTabBar extends StatelessWidget {
  final List<String> titles;
  final TabController controller;
  final bool? isScrollable;

  const MedalsTabBar({
    super.key,
    required this.titles,
    required this.controller,
    this.isScrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    // Rounded gold-outlined capsule with a gold-gradient glow on the
    // selected tab -- matching the reference "ACHIEVEMENT MEDAL / EVENT
    // MEDAL" pill tab bar exactly, instead of the stock underline TabBar.
    return Container(
      height: 46.h,
      // Small side gap, on request -- was flush with the screen edges.
      margin: context.paddingSymmetric(horizontal: 10),
      padding: context.paddingAll(4),
      decoration: BoxDecoration(
        borderRadius: 30.radius,
        border: Border.all(color: const Color(0x99FFD98A)),
      ),
      child: TabBar(
        labelPadding: EdgeInsets.zero,
        controller: controller,
        tabAlignment: isScrollable! ? TabAlignment.start : null,
        automaticIndicatorColorAdjustment: false,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          borderRadius: 30.radius,
          gradient: const LinearGradient(
            colors: [Color(0xFFFFE9A8), Color(0xFFB8862F)],
          ),
        ),
        dividerHeight: 0,
        isScrollable: isScrollable ?? false,
        unselectedLabelStyle: context.bodySmall.w600.colorExt(Colors.white70),
        labelColor: const Color(0xFF3A2205),
        padding: EdgeInsets.zero,
        labelStyle: context.bodySmall.bold.colorExt(const Color(0xFF3A2205)),
        tabs: [
          for (int i = 0; i < titles.length; i++)
            Tab(text: titles[i].toUpperCase()),
        ],
      ),
    );
  }
}
