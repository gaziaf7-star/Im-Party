part of '../old_rank_screen.dart';

class OldInnerTabBar extends StatelessWidget {
  final TabController tabController;
  final Color color;
  final int index;

  const OldInnerTabBar({
    required this.tabController,
    required this.index,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RankPeriodTabs(
      controller: tabController,
      labels: [
        StringManager.hourly.tr(),
        StringManager.daily.tr(),
        StringManager.weekly.tr(),
        StringManager.monthly.tr(),
      ],
    );
  }
}
