part of '../level_page.dart';

class LevelTabBarView extends StatelessWidget {
  final List<LevelBadgesEntity> senderBadges;
  final List<LevelBadgesEntity> reciverBadges;
  final List<LevelBadgesEntity> chargeBadges;

  final TabController controller;

  const LevelTabBarView({
    required this.controller,
    super.key,
    required this.senderBadges,
    required this.reciverBadges,
    required this.chargeBadges,
  });

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: controller,
      clipBehavior: Clip.none,
      children: [
        LevelView(data: senderBadges),
        CharmView(data: reciverBadges),
        ChargeView(data: chargeBadges),
      ],
    );
  }
}
