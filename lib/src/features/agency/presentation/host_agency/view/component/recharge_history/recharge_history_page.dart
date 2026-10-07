import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/agency.dart';

part 'components/recharge_tab_bar.dart';
part 'components/recharge_tab_bar_view.dart';
part 'widgets/google_coins_recharge_history_item.dart';
part 'widgets/received_coins_recharge_history_item.dart';

class RechargeHistoryPage extends StatefulWidget {
  const RechargeHistoryPage({super.key});

  @override
  State<RechargeHistoryPage> createState() => _RechargeHistoryPageState();
}

class _RechargeHistoryPageState extends State<RechargeHistoryPage>
    with TickerProviderStateMixin {
  late final TabController rechargeHistoryController;
  final GetGoogleCoinsHistoryBloc _bloc = di<GetGoogleCoinsHistoryBloc>();
  final GetChargeCoinsHistoryBloc _coinsBloc = di<GetChargeCoinsHistoryBloc>();

  @override
  void initState() {
    rechargeHistoryController = TabController(length: 2, vsync: this);

    if (!_bloc.state.requestState.isLoaded) {
      _bloc.add(const GetGoogleCoinsHistoryEvent());
    }
    if (!_coinsBloc.state.requestState.isLoaded) {
      _coinsBloc.add(const GetChargeCoinsHistoryEvent());
    }
    super.initState();
  }

  @override
  void dispose() {
    rechargeHistoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        backgroundColor: ColorManager.scaffoldBg,
        title: StringManager.transactions.tr(),
      ),
      body: Column(
        children: [
          RechargeTabBar(
            rechargeHistoryController: rechargeHistoryController,
          ),
          Expanded(
            child: TabBarView(
              controller: rechargeHistoryController,
              children: [
                BlocBuilder<GetChargeCoinsHistoryBloc,
                    GetChargeCoinsHistoryState>(
                  bloc: _coinsBloc,
                  buildWhen: (prev, curr) =>
                      prev.requestState != curr.requestState ||
                      prev.dataList != curr.dataList,
                  builder: (context, state) {
                    return HandlingDataWidget(
                      reqState: _coinsBloc.state.requestState,
                      title: StringManager.noTransactionsYet.tr(),
                      subTitle: StringManager.yourCoinChargeHistoryAppear.tr(),
                      onTap: () =>
                          _coinsBloc.add(const GetChargeCoinsHistoryEvent()),
                      child: RechargeHistoryTabBarView(
                        onRefresh: () async =>
                            _coinsBloc.add(const GetChargeCoinsHistoryEvent()),
                        receivedCoinsHistoryModelList:
                            _coinsBloc.state.dataList,
                        isGoogle: false,
                      ),
                    );
                  },
                ),
                BlocBuilder<GetGoogleCoinsHistoryBloc,
                    GetGoogleCoinsHistoryState>(
                  bloc: _bloc,
                  buildWhen: (prev, curr) =>
                      prev.requestState != curr.requestState ||
                      prev.coinsHistoryList != curr.coinsHistoryList,
                  builder: (context, state) {
                    return HandlingDataWidget(
                      reqState: _bloc.state.requestState,
                      title: StringManager.noTransactionsYet.tr(),
                      subTitle: StringManager.noTransactionsYet.tr(),
                      onTap: () =>
                          _bloc.add(const GetGoogleCoinsHistoryEvent()),
                      child: RechargeHistoryTabBarView(
                        onRefresh: () async =>
                            _bloc.add(const GetGoogleCoinsHistoryEvent()),
                        googleCoinsHistoryModelList:
                            _bloc.state.coinsHistoryList,
                        isGoogle: true,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
