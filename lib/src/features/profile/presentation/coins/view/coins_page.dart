import 'package:general/src/core/index.dart';
import 'package:general/src/core/realtime/realtime_config.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';
import 'package:general/src/features/profile/presentation/wallet_withdraw/view/reseller_directory_page.dart';
import 'package:general/src/features/profile/profile.dart';

part 'widgets/coins_to_dollars_item.dart';
part 'components/tab_bar_wallet.dart';
part 'components/tab_bar_view_coins_body.dart';
part 'components/tab_bar_view_diamond.dart';
part 'widgets/golden_diamond_card.dart';

class CoinsPage extends StatefulWidget {
  const CoinsPage({super.key});

  @override
  State<CoinsPage> createState() => _CoinsPageState();
}

class _CoinsPageState extends State<CoinsPage> with TickerProviderStateMixin {
  final GoldCoinBloc _goldCoinBloc = di<GoldCoinBloc>();

  int? selectedCardIndex;
  @override
  void initState() {
    if (!_goldCoinBloc.state.reqState.isLoaded) {
      _goldCoinBloc.add(const GetGoldCoinDataEvent());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GoldCoinBloc, GoldCoinState>(
      bloc: _goldCoinBloc,
      buildWhen: (prev, curr) => prev.reqState != curr.reqState || prev.data != curr.data,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBarWidget(
            title: StringManager.rechargeCoins.tr(),
            titleStyle: context.bodyMedium
                .size(13)
                .w500
                .colorExt(ColorManager.headerColor),
            actions: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0.w),
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
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ColorManager.iconColor),
                    ),
                    child: TextWidget(
                      StringManager.top.tr(),
                      style: context.bodySmall.w600
                          .colorExt(ColorManager.iconColor),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0.w),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, Routes.billPage);
                  },
                  child: Image.asset(
                    AssetsManager.billIcon,
                    color: ColorManager.iconColor,
                    scale: 3,
                  ),
                ),
              ),
            ],
          ),
          body: RefreshIndicatorWidget(
            onRefresh: () async {
              _goldCoinBloc.add(const GetGoldCoinDataEvent());
              di<MyStoreBloc>().add(const GetMyStoreEvent(isLoading: false));
            },
            child: HandlingDataWidget(
              reqState: state.reqState,
              title: StringManager.noDataYet.tr(),
              subTitle: StringManager.pleaseTryAgine.tr(),
              onTap: () {
                _goldCoinBloc.add(const GetGoldCoinDataEvent());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: context.paddingSymmetric(horizontal: 15),
                  child: Column(
                    children: [
                      15.hBox,
                      Container(
                        width: ScreenUtil().screenWidth,
                        height: 150.h,
                        decoration: BoxDecoration(
                          color: ColorManager.surfaceCardColor,
                          borderRadius: 10.radius,
                          image: DecorationImage(
                            alignment: Alignment.bottomLeft,
                            image: AssetImage(AssetsManager.rechargeCoinsIcon),
                            scale: 3,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextWidget(
                              StringManager.coins.tr(),
                              style: context.bodySmall
                                  .size(12)
                                  .w500
                                  .colorExt(ColorManager.secondaryText),
                            ),
                            10.hBox,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  AssetsManager.starCoinsIcon,
                                  scale: 3,
                                ),
                                BlocBuilder<MyStoreBloc, MyStoreState>(
                                  bloc: di<MyStoreBloc>(),
                                  builder: (context, state) {
                                    return TextWidget(
                                      '${state.myStore?.coins ?? 0}',
                                      style: context.bodyMedium.w700
                                          .colorExt(ColorManager.textPrimary)
                                          .size(30),
                                    );
                                  },
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      20.hBox,
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) => state.data.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AnimatedDialog(
                                      title: StringManager.confirmation.tr(),
                                      description:
                                          StringManager.youWillRecharge(
                                        coin: state.data[index].coin.toString(),
                                        price: state.data[index].usd.toString(),
                                      ),
                                      conText: StringManager.confirm.tr(),
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  );
                                },
                                child: CoinsToDollarsItem(
                                  goldCoinsEntity: state.data[index],
                                ),
                              )
                            : const SizedBox.shrink(),
                        itemCount:
                            state.data.isNotEmpty ? state.data.length : 0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CoinsCardBuilder extends StatelessWidget {
  const CoinsCardBuilder({
    super.key,
    required this.title,
    required this.onTap,
    this.trailing,
    required this.colors,
  });
  final String title;
  final Widget? trailing;
  final void Function()? onTap;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 60.h,
        padding: context.paddingSymmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: colors),
          borderRadius: BorderRadius.circular(5.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget(
              title,
              overflow: TextOverflow.clip,
              style: context.bodyMedium.bold
                  .size(15)
                  .colorExt(
                    ColorManager.onDark,
                  )
                  .copyWith(fontFamily: StringManager.fontFamily),
            ),
          ],
        ),
      ),
    );
  }
}