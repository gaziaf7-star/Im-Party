import 'dart:async';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/presentation/host_agency/bloc/search_manager/search_user_agency_bloc.dart';
import 'package:general/src/features/profile/profile.dart';
import 'package:intl/intl.dart';

import '../../../../../core/widgets/GradientLoader.dart';
import '../../../data/model/coin_seller_model.dart';
import '../bloc/coin_seller_bloc.dart';
import 'coin_seller_withdraw_requests_page.dart';

part 'widgets/coin_seller_balance_card.dart';
part 'widgets/coin_seller_transfer_tab.dart';
part 'widgets/coin_seller_history_tab.dart';
part 'widgets/coin_seller_history_item.dart';

const Color _coinSellerBg = Color(0xFFF7F6FA);
const Color _coinSellerCard = Colors.white;
const Color _coinSellerText = Color(0xFF141318);
const Color _coinSellerSubText = Color(0xFF77747E);
const Color _coinSellerBorder = Color(0xFFE8E5ED);
const Color _coinSellerPurple = Color(0xFF6D37F5);
const Color _coinSellerCyan = Color(0xFF29D7FF);

const List<Color> _coinSellerGradient = [
  Color(0xFF8E2BFF),
  Color(0xFF503CFF),
  Color(0xFF29D7FF),
];

class CoinSellerScreen extends StatefulWidget {
  const CoinSellerScreen({super.key});

  @override
  State<CoinSellerScreen> createState() => _CoinSellerScreenState();
}

class _CoinSellerScreenState extends State<CoinSellerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final CoinSellerBloc _bloc = di<CoinSellerBloc>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _bloc.add(const GetCoinSellerProfileEvent(isLoading: true));
    _bloc.add(const GetCoinSellerHistoryEvent(isLoading: true));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _coinSellerBg,
      appBar: AppBarWidget(
        backgroundColor: Colors.white,
        shadow: Colors.transparent,
        iconColor: _coinSellerText,
        title: StringManager.coinSellerDashboard.tr(),
        titleStyle: context.titleLarge
            .size(19)
            .bold
            .colorExt(_coinSellerText),
        actions: [
          // Opens the withdraw hub straight on its "Incoming" tab, where the
          // coin seller can accept/reject the withdraw requests users have
          // sent them -- on request.
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CoinSellerWithdrawRequestsPage(),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.r),
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: _coinSellerGradient,
                  ),
                ),
                child: TextWidget(
                  StringManager.withdrawal.tr(),
                  style: context.bodySmall.size(12).bold.colorExt(Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocListener<CoinSellerBloc, CoinSellerState>(
        bloc: _bloc,
        listenWhen: (prev, curr) =>
        prev.reqStateTransfer != curr.reqStateTransfer,
        listener: (context, state) {
          if (state.reqStateTransfer.isLoading) {
            Methods.showToast(context, isLoading: true);
          }
        },
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              8.hBox,
              const CoinSellerBalanceCard(),
              14.hBox,
              Container(
                height: 48.h,
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFECE8F5),
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(
                    color: const Color(0xFFE0DBEA),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.r),
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: _coinSellerGradient,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _coinSellerPurple.withValues(alpha: 0.20),
                        blurRadius: 10.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: _coinSellerSubText,
                  labelStyle: context.bodyMedium
                      .size(13)
                      .bold,
                  unselectedLabelStyle: context.bodyMedium
                      .size(13)
                      .w600,
                  tabs: [
                    Tab(
                      text: StringManager.transferCoins.tr(),
                    ),
                    Tab(
                      text: StringManager.transferHistory.tr(),
                    ),
                  ],
                ),
              ),
              12.hBox,
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const BouncingScrollPhysics(),
                  children: const [
                    CoinSellerTransferTab(),
                    CoinSellerHistoryTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
