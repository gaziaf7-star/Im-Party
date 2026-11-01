part of '../family_rank_page.dart';

class _FamilyTabBar extends StatelessWidget {
  final TabController controller;

  const _FamilyTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return RankPeriodTabs(
      controller: controller,
      labels: [
        StringManager.daily.tr(),
        StringManager.weekly.tr(),
        StringManager.monthly.tr(),
      ],
    );
  }
}
