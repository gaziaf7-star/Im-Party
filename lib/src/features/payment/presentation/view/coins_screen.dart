import 'package:general/src/core/index.dart';
import 'package:general/src/features/payment/presentation/bloc/buy_coins_bloc/buy_coins_bloc.dart';
import 'package:general/src/features/payment/presentation/bloc/buy_coins_bloc/buy_coins_event.dart';
import 'package:general/src/features/payment/presentation/bloc/buy_coins_bloc/buy_coins_state.dart';
import 'package:general/src/features/payment/presentation/bloc/fetch_coins/fetch_coins_bloc.dart';
import 'package:general/src/features/payment/presentation/bloc/fetch_coins/fetch_coins_event.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';
import 'package:general/src/features/profile/presentation/wallet_withdraw/view/reseller_directory_page.dart';
import '../../../profile/presentation/exchange_diamond/bloc/diamond_bloc.dart';
import '../components/coins_tab_bar.dart';
import 'components/coins_tab_bar_view.dart';

part 'components/coins_tab_bar.dart';

class CoinsScreen extends StatefulWidget {
  final int? index;

  const CoinsScreen({super.key, this.index});

  @override
  State<CoinsScreen> createState() => CoinsScreenState();
}

class CoinsScreenState extends State<CoinsScreen>
    with TickerProviderStateMixin {
  final FetchCoinsBloc _goldCoinBloc = di<FetchCoinsBloc>();
  late final TabController _controller;

  // Frozen ONCE here instead of being re-read live from the mutable
  // StringManager.userType global in multiple build() methods (this file,
  // CoinsTabBarView, CoinsTabBar) -- those independent live reads could
  // each see a different value than the one used to size _controller's
  // length below (e.g. if my-data resolves after this screen opens),
  // which desynced TabController/TabBarView/TabBar lengths and made the
  // Diamond tab intermittently fail to render. Fix: compute once, pass
  // down as a plain bool.
  //
  // Per request, the Diamond tab must always be visible on this screen now
  // (it was being hidden for some user types by the old
  // `!(userType[1] || userType[2])` condition, and that condition also
  // risked a null-check crash before my-data finished loading) -- so this
  // is now unconditionally true instead of depending on StringManager.userType.
  static const bool _showDiamondTab = true;

  // The old "Profits" (USD earnings) tab and its nested dollarsController
  // sub-tabs have been removed from this screen per request -- this page
  // now only has 2 tabs: My Coins and Diamond.

  int value = di<MyStoreBloc>().state.myStore?.coins ?? 0;

  @override
  void initState() {
    super.initState();
    di<BuyCoinsBloc>().add(
        const ChangeValueEvent(value: 0, changeText: true, controllerIndex: 0));

    di<MyStoreBloc>().add(const GetMyStoreEvent());
    if (!di<DiamondBloc>().state.reqStateDiamond.isLoaded) {
      di<DiamondBloc>().add(const GetDiamondDataEvent(isLoading: true));
    }
    di<MyStoreBloc>().state.myStore;
    _controller = TabController(
      length: _showDiamondTab ? 2 : 1,
      vsync: this,
      initialIndex: widget.index ?? 0,
    );

    if (!_goldCoinBloc.state.reqState.isLoaded) {
      _goldCoinBloc.add(const FetchCoinsEvent());
    }

    _controller.addListener(() {
      if (_controller.indexIsChanging) return;

      final value = (_controller.index == 0)
          ? di<MyStoreBloc>().state.myStore?.coins ?? 0
          : di<MyStoreBloc>().state.myStore?.diamonds ?? 0;

      di<BuyCoinsBloc>().add(ChangeValueEvent(
          value: int.tryParse(value.toString()), changeText: true, controllerIndex: _controller.index));
    });
  }

  @override
  Widget build(BuildContext context) {
    final normalPage = BlocBuilder<BuyCoinsBloc, BuyCoinsState>(
      bloc: di<BuyCoinsBloc>(),
      buildWhen: (prev, curr) => prev.controllerIndex != curr.controllerIndex,
      builder: (context, state) {
        // One accent per active tab, reused for both the AppBar's gradient
        // and CoinsTabBar's own tint — so the two always match, on request
        // ("amar bg ar color ja ta thakba amar appbar o sm color hoba").
        final accentColor = (state.controllerIndex == 0)
            ? ColorManager.coinsAccent
            : ColorManager.diamondsAccent;
        return Scaffold(
          backgroundColor: ColorManager.white,
          // Was `false` -- that stopped this screen from resizing when the
          // keyboard opens, so a focused field (Withdraw/Exchange amount,
          // account number, etc.) could end up hidden behind the keyboard
          // with no way to scroll it into view. `true` (the Scaffold
          // default) lets the body shrink so the Withdraw/Exchange forms'
          // own scroll views can bring the focused field above the
          // keyboard, per request.
          resizeToAvoidBottomInset: true,
          appBar: AppBarWidget(
            iconColor: ColorManager.white,
            backgroundGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [accentColor, accentColor.withValues(alpha: 0.75)],
            ),
            title: StringManager.rechargeCoins.tr(),
            titleStyle: context.bodyMedium
                .size(18)
                .w600
                .colorExt(ColorManager.white),
            actions: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0.w),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ResellerDirectoryPage(),
                      ),
                    );
                  },
                  child: Container(
                    padding: context.paddingSymmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: resellerVipGradient,
                      ),
                      border: Border.all(color: const Color(0xFFD4A94A)),
                      boxShadow: const [
                        BoxShadow(color: Color(0x66D4A94A), blurRadius: 6),
                      ],
                    ),
                    child: TextWidget(
                      StringManager.top.tr(),
                      style: context.bodySmall.w700
                          .colorExt(Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: DefaultTabController(
            length: _controller.length,
            child: Column(
              children: [
                CoinsTabBar(
                  controller: _controller,
                  color: accentColor,
                  showDiamondTab: _showDiamondTab,
                  txt: state.controllerIndex == 0
                      ? StringManager.coins.tr()
                      : StringManager.diamond.tr(),
                ),
                Expanded(
                  child: RefreshIndicatorWidget(
                    onRefresh: () async {
                      _goldCoinBloc.add(const FetchCoinsEvent());
                      di<MyStoreBloc>().add(const GetMyStoreEvent());
                    },
                    child: CoinsTabBarView(
                      controller: _controller,
                      showDiamondTab: _showDiamondTab,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );

    return normalPage;
  }
}