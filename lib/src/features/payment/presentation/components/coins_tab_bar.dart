import 'package:general/src/features/auth/domain/entities/my_store_entity.dart';
import 'package:general/src/features/payment/presentation/bloc/buy_coins_bloc/buy_coins_bloc.dart';
import 'package:general/src/features/payment/presentation/bloc/buy_coins_bloc/buy_coins_event.dart';
import 'package:general/src/features/payment/presentation/bloc/buy_coins_bloc/buy_coins_state.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';

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
    // The old "Profits" (USD earnings) tab has been removed from this
    // screen per request -- only My Coins and Diamond remain.
    final tabIndex = widget.controller.index;
    final String currentTabLabel =
    tabIndex == 0 ? StringManager.coins.tr() : StringManager.diamond.tr();

    return BlocBuilder<BuyCoinsBloc, BuyCoinsState>(
      bloc: di<BuyCoinsBloc>(),
      buildWhen: (prev, curr) => prev.controllerIndex != curr.controllerIndex,
      builder: (context, state) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            _buildBackgroundIcon(state),
            _buildTabBar(context, state),

            // Conditional tab content
            if (currentTabLabel == StringManager.coins.tr())
              _buildCoinsUI(state)
            else
              _buildDiamondsUI(state),
          ],
        );
      },
    );
  }

  Widget _buildBackgroundIcon(BuyCoinsState state) {
    return Positioned(
      top: -4,
      right: 120,
      child: Image.asset(
        state.controllerIndex == 0
            ? AssetsManager.coinsVip
            : AssetsManager.diamondsIcon,
        width: 130.w,
        fit: BoxFit.fill,
        opacity: const AlwaysStoppedAnimation(0.1),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, BuyCoinsState state) {
    return Container(
      padding: context.paddingOnly(bottom: 50),
      decoration: BoxDecoration(
        // Professional light look on request: a soft tint of the current
        // accent (coins/diamonds/profits) instead of a bold flat fill, so
        // the page reads as white/light overall while still hinting which
        // tab is active.
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (widget.color ?? ColorManager.primary).withValues(alpha: 0.16),
            ColorManager.white,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(20.r),
          bottomLeft: Radius.circular(20.r),
        ),
      ),
      child: Container(
        padding: context.paddingSymmetric(horizontal: 10, vertical: 5),
        margin: context.paddingAll(15),
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: 30.radius,
          boxShadow: [
            BoxShadow(
              color: ColorManager.black.withValues(alpha: 0.06),
              blurRadius: 10.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: TabBar(
          controller: widget.controller,
          isScrollable: false,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerHeight: 0,
          indicator: BoxDecoration(
            color: (widget.color ?? ColorManager.primary).withValues(alpha: 0.16),
            borderRadius: 25.radius,
          ),
          onTap: (value) =>
              di<BuyCoinsBloc>().add(ChangeValueEvent(controllerIndex: value)),
          // Black in both states, on request — the tab's own TextWidget
          // colour below is what actually paints (see note there), but
          // these are kept consistent rather than left pointing at the
          // old accent/secondaryText tokens.
          labelColor: ColorManager.black,
          indicatorColor: ColorManager.transparent,
          labelPadding: context.paddingSymmetric(horizontal: 10, vertical: 5),
          unselectedLabelStyle:
          context.bodyMedium.colorExt(ColorManager.black).size(16),
          labelStyle: context.bodyMedium.w700.colorExt(ColorManager.black),
          tabs: [
            TextWidget(StringManager.coins.tr(),
                style:
                context.bodyMedium.size(14).colorExt(ColorManager.black)),
            if (widget.showDiamondTab)
              TextWidget(StringManager.diamond.tr(),
                  style: context.bodyMedium
                      .size(14)
                      .colorExt(ColorManager.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinsUI(BuyCoinsState state) {
    return _buildCommonBottomSheet(
      iconPath: AssetsManager.coinsVip,
      valueBuilder: (myStore) => myStore?.coins.toString() ?? '0',
      onTapRoute: Routes.billPage,
    );
  }

  Widget _buildDiamondsUI(BuyCoinsState state) {
    // Shows earned_coins now, not diamonds -- on request; card look/label
    // stays the same.
    return _buildCommonBottomSheet(
      iconPath: AssetsManager.diamondsIcon,
      valueBuilder: (myStore) => myStore?.earnedCoins.toString() ?? '0',
      onTapRoute: Routes.diamondRecord,
    );
  }

  Widget _buildCommonBottomSheet({
    required String iconPath,
    required String Function(MyStoreEntity? myStore) valueBuilder,
    required String onTapRoute,
  }) {
    return Positioned(
      bottom: -90.h,
      child: Container(
        width: 360.w,
        height: 125.h,
        margin: context.paddingSymmetric(horizontal: 15),
        padding: context.paddingAll(10),
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: 14.radius,
          border: Border.all(color: ColorManager.grey2.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: ColorManager.black.withValues(alpha: 0.06),
              blurRadius: 12.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(widget.txt,
                    style: context.bodyMedium
                        .size(16)
                        .w600
                        .colorExt(ColorManager.black)),
                InkWell(
                  onTap: () => Navigator.pushNamed(context, onTapRoute),
                  child: Container(
                    padding:
                    context.paddingSymmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: 20.radius,
                      color: ColorManager.grey2.withValues(alpha: (0.15)),
                    ),
                    child: TextWidget(
                      "${StringManager.record.tr()}>",
                      style: context.bodyMedium.size(14).w600.colorExt(
                          ColorManager.black),
                    ),
                  ),
                ),
              ],
            ),
            8.hBox,
            Row(
              children: [
                Image.asset(iconPath, height: 30),
                5.wBox,
                BlocBuilder<MyStoreBloc, MyStoreState>(
                  bloc: di<MyStoreBloc>(),
                  buildWhen: (prev, curr) => prev.myStore != curr.myStore,
                  builder: (context, myStoreState) {
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: ScreenUtil().screenWidth * 0.6,
                        minWidth: 1,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentGeometry.topRight,
                        child: TextWidget(
                          valueBuilder(myStoreState.myStore),
                          style: context.bodyMedium
                              .size(30)
                              .w700
                              .colorExt(ColorManager.black),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            8.hBox,
          ],
        ),
      ),
    );
  }
}