import 'package:general/src/features/auth/domain/entities/my_store_entity.dart';
import 'package:general/src/features/payment/presentation/bloc/buy_coins_bloc/buy_coins_bloc.dart';
import 'package:general/src/features/payment/presentation/bloc/buy_coins_bloc/buy_coins_event.dart';
import 'package:general/src/features/payment/presentation/bloc/buy_coins_bloc/buy_coins_state.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';
import 'package:general/src/core/widgets/md_indicator.dart';

import '../../../../../reels_viewer/reels_viewer.dart';

class CoinsTabBar extends StatefulWidget {
  final TabController controller;
  final String txt;
  final Color? color;
  // Passed down from CoinsScreenState instead of re-reading
  // StringManager.userType live here -- keeps this tab's tab-list length
  // in sync with the TabController's frozen length (fixes the
  // intermittently hidden Diamond tab).
  final bool showDiamondTab;

  const CoinsTabBar({
    required this.controller,
    super.key,
    required this.txt,
    required this.color,
    required this.showDiamondTab,
  });

  @override
  State<CoinsTabBar> createState() => _CoinsTabBarState();
}

class _CoinsTabBarState extends State<CoinsTabBar> {
  @override
  Widget build(BuildContext context) {
    // White header block (tabs + balance card) with rounded bottom corners
    // over the grey page, as in the reference wallet.
    return BlocBuilder<BuyCoinsBloc, BuyCoinsState>(
      bloc: di<BuyCoinsBloc>(),
      buildWhen: (prev, curr) => prev.controllerIndex != curr.controllerIndex,
      builder: (context, state) {
        final coins = state.controllerIndex == 0;
        return Container(
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
          decoration: BoxDecoration(
            color: ColorManager.white,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTabBar(context),
              12.hBox,
              coins
                  ? _BalanceCard(
                      iconPath: AssetsManager.coinsVip,
                      valueBuilder: (s) => s?.coins.toString() ?? '0',
                      recordRoute: Routes.billPage,
                      colors: const [Color(0xFFFFF4D9), Color(0xFFFBC8A6)],
                      accent: const Color(0xFFF08A2C),
                    )
                  : _BalanceCard(
                      // Shows earned_coins, as before.
                      iconPath: AssetsManager.diamondsIcon,
                      valueBuilder: (s) => s?.earnedCoins.toString() ?? '0',
                      recordRoute: Routes.diamondRecord,
                      colors: const [Color(0xFFF1E9FF), Color(0xFFD5C2FF)],
                      accent: const Color(0xFF8A56E8),
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return TabBar(
      controller: widget.controller,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      dividerHeight: 0,
      overlayColor: WidgetStateColor.transparent,
      indicatorSize: TabBarIndicatorSize.label,
      indicator: MDIndicator(
        indicatorColor: const Color(0xFF1C1C1E),
        indicatorWidth: 14.w,
        indicatorHeight: 4.h,
        radius: 20,
      ),
      onTap: (value) =>
          di<BuyCoinsBloc>().add(ChangeValueEvent(controllerIndex: value)),
      labelPadding: context.paddingOnly(end: 28),
      labelColor: const Color(0xFF1C1C1E),
      unselectedLabelColor: const Color(0xFF9A9AA0),
      labelStyle: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800),
      unselectedLabelStyle:
          TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
      tabs: [
        Tab(text: StringManager.coins.tr(), height: 44.h),
        if (widget.showDiamondTab)
          Tab(text: StringManager.diamond.tr(), height: 44.h),
      ],
    );
  }
}

/// Soft gradient balance card: icon + big number, "Account Balance >" (opens
/// the record), and two round shortcuts at the top right (record and
/// buy-from-reseller).
class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.iconPath,
    required this.valueBuilder,
    required this.recordRoute,
    required this.colors,
    required this.accent,
  });

  final String iconPath;
  final String Function(MyStoreEntity? myStore) valueBuilder;
  final String recordRoute;
  final List<Color> colors;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150.h,
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 14.w, 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(iconPath, height: 38.h),
                    8.wBox,
                    BlocBuilder<MyStoreBloc, MyStoreState>(
                      bloc: di<MyStoreBloc>(),
                      buildWhen: (prev, curr) => prev.myStore != curr.myStore,
                      builder: (context, myStoreState) {
                        return ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: ScreenUtil().screenWidth * 0.7,
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              valueBuilder(myStoreState.myStore),
                              style: TextStyle(
                                color: const Color(0xFF1C1C1E),
                                fontSize: 34.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                10.hBox,
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, recordRoute),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Account Balance',
                        style: TextStyle(
                          color: accent,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          color: accent, size: 22.sp),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
