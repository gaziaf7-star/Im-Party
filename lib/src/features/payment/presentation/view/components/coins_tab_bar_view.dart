import 'package:general/src/core/index.dart';
import 'coins_view.dart';
import 'diamond_view.dart';

class CoinsTabBarView extends StatelessWidget {
  final TabController controller;
  // Passed down from CoinsScreenState instead of re-reading
  // StringManager.userType live here -- keeps this list's length in sync
  // with the TabController's frozen length (fixes the intermittently
  // hidden Diamond tab).
  final bool showDiamondTab;

  const CoinsTabBarView({
    required this.controller,
    required this.showDiamondTab,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // The old "Profits" (USD earnings) tab and its nested dollarsController
    // sub-tabs have been removed from this screen per request -- only
    // My Coins and Diamond remain.
    return TabBarView(
      controller: controller,
      clipBehavior: Clip.none,
      physics: const NeverScrollableScrollPhysics(), // Disable swipe

      children: [
        const CoinsView(),
        if (showDiamondTab) const DiamondView(),
      ],
    );
  }
}