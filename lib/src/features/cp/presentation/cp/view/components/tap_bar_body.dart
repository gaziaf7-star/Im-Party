import '../../../../../../core/index.dart';
import 'cp_design.dart';

/// Custom pill tab row (not the stock TabBar indicator) so each tab reads as
/// its own separate gold-edged capsule with a gap between them, matching the
/// reference design instead of one shared sliding-indicator track.
class TapBarBody extends StatelessWidget {
  const TapBarBody({super.key, required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final labels = [
      StringManager.cpTabRules.tr(),
      StringManager.cpTabPrivileges.tr(),
      StringManager.cpTabFriend.tr(),
    ];
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          children: [
            for (int i = 0; i < labels.length; i++) ...[
              if (i != 0) 8.wBox,
              Expanded(
                child: CpTabPill(
                  text: labels[i],
                  selected: controller.index == i,
                  onTap: () => controller.animateTo(i),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
