import 'package:general/src/core/index.dart';

import '../../../../profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';
import '../../../../profile/presentation/exchange_diamond/bloc/exchange_v2_bloc/exchange_v2_bloc.dart';
import '../../../../profile/presentation/exchange_diamond/view/widgets/exchange_form_body.dart';
import '../../../../profile/presentation/wallet_withdraw/view/widgets/withdraw_form_body.dart';

/// Wallet screen's Diamond tab. Shows the diamond balance + live exchange
/// rate card, and -- per request -- right below it, two tabs: "Withdraw"
/// and "Exchange". The Withdraw tab has the withdraw form
/// (WithdrawFormBody, POST /wallets/withdraw), the Exchange tab has the
/// diamond -> coin exchange form (ExchangeFormBody, v2 exchange API).
/// Withdraw is no longer a separate Profile menu row -- it now lives here.
class DiamondView extends StatefulWidget {
  const DiamondView({super.key});

  @override
  State<DiamondView> createState() => _DiamondViewState();
}

class _DiamondViewState extends State<DiamondView>
    with SingleTickerProviderStateMixin {
  late final TabController _innerTabController;

  @override
  void initState() {
    super.initState();
    _innerTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _innerTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.paddingSymmetric(horizontal: 10),
      child: Column(
        children: [
          110.hBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                StringManager.rechargeDiamond.tr(),
                style: context.bodyLarge.w600.colorExt(ColorManager.black),
              ),
              InkWell(
                onTap: () {
                  di<MyStoreBloc>().add(const GetMyStoreEvent());
                  di<ExchangeV2Bloc>().add(const GetExchangeSettingsEvent());
                },
                child: Image.asset(
                  AssetsManager.refreshIcon,
                  scale: 2,
                ),
              ),
            ],
          ),
          16.hBox,
          // The big "Diamond Balance" gradient card that used to sit here
          // was removed per request -- it was just repeating the same
          // number already shown by the "Diamond ... Record>" card above
          // (from CoinsTabBar), so the balance was visibly showing twice.
          // Now each tab below shows only the balance that's actually
          // relevant to it: Withdraw shows the Coins balance,
          // Exchange shows the Diamond balance + live rate.
          //
          // New: Withdraw / Exchange tab switch, per request.
          Container(
            padding: context.paddingAll(4),
            decoration: BoxDecoration(
              color: ColorManager.grey2.withValues(alpha: 0.10),
              borderRadius: 12.radius,
            ),
            child: TabBar(
              controller: _innerTabController,
              dividerColor: ColorManager.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: ColorManager.diamondsAccent,
                borderRadius: 10.radius,
              ),
              labelColor: ColorManager.white,
              unselectedLabelColor: ColorManager.black,
              labelStyle: context.bodyMedium.w600.size(14),
              unselectedLabelStyle: context.bodyMedium.w600.size(14),
              tabs: [
                Tab(text: StringManager.withdrawal.tr()),
                Tab(text: StringManager.exchange.tr()),
              ],
            ),
          ),
          10.hBox,
          Expanded(
            child: TabBarView(
              controller: _innerTabController,
              // Both tabs' own balance cards are hidden here on request --
              // the "Diamond ... Record>" card above (from CoinsTabBar)
              // already shows the balance, so showing it again inside each
              // tab was redundant.
              children:  [
                WithdrawFormBody(showBalanceCard: false),
                ExchangeFormBody(showBalanceCard: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}