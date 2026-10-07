import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';
import 'package:general/src/features/profile/profile.dart';

class RechargeCoinsdPage extends StatefulWidget {
  const RechargeCoinsdPage({super.key});

  @override
  State<RechargeCoinsdPage> createState() => _RechargeCoinsdPageState();
}

class _RechargeCoinsdPageState extends State<RechargeCoinsdPage> {
  final GoldCoinBloc _goldCoinBloc = di<GoldCoinBloc>();
  @override
  void initState() {
    if (!_goldCoinBloc.state.reqState.isLoaded) {
      _goldCoinBloc.add(const GetGoldCoinDataEvent());
    }

    super.initState();
  }

  int? selectedCardIndex;
  @override
  Widget build(BuildContext context) {
    return BackgroundImgWidget(
      child: Scaffold(
        backgroundColor: ColorManager.transparent,
        appBar: AppBarWidget(
          title: StringManager.recharge.tr(),
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0.w),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, Routes.billPage);
                },
                child: Image.asset(
                  AssetsManager.pilling,
                  scale: 2,
                ),
              ),
            ),
          ],
        ),
        body: BlocBuilder<GoldCoinBloc, GoldCoinState>(
          bloc: _goldCoinBloc,
          buildWhen: (prev, curr) => prev.reqState != curr.reqState || prev.data != curr.data,
          builder: (context, state) {
            return HandlingDataWidget(
              reqState: state.reqState,
              title: StringManager.noDataYet.tr(),
              subTitle: StringManager.pleaseTryAgine.tr(),
              onTap: () {
                _goldCoinBloc.add(const GetGoldCoinDataEvent());
              },
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        20.hBox,
                        Center(
                          child: Image.asset(
                            AssetsManager.coinsIcon,
                            height: 120.h,
                            width: 120.w,
                          ),
                        ),
                        5.hBox,
                        Text(
                          StringManager.balance.tr(),
                          style: context.bodyMedium.size(20).colorExt(ColorManager.textPrimary).w500,
                        ),
                        5.hBox,
                        BlocBuilder<MyStoreBloc, MyStoreState>(
                          bloc: di<MyStoreBloc>(),
                          buildWhen: (prev, curr) => prev.myStore != curr.myStore,
                          builder: (context, state) {
                            return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "${state.myStore?.coins} ${StringManager.coins.tr()}",
                                textAlign: TextAlign.center,
                                style: context.bodyMedium.bold.colorExt(ColorManager.textPrimary).size(25)
                              ),
                            );
                          },
                        ),
                        20.hBox,
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: GridView.builder(
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 150 / 78,
                            ),
                            itemCount: state.data.length,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return RechargeCoinsDiamondItem(
                                isCoins: true,
                                isSelected: selectedCardIndex == index,
                                coins: "\$ ${state.data[index].usd}",
                                diamonds: state.data[index].coin.toString(),
                                onTap: () {
                                  setState(() {
                                    if (selectedCardIndex == index) {
                                      selectedCardIndex = null;
                                    } else {
                                      selectedCardIndex = index;
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        80.hBox,
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: context.paddingSymmetric(vertical: 10),
                      child: ButtonWidget(
                        onPressed: () {
                          if (selectedCardIndex != null) {
                            showDialog(
                              context: context,
                              builder: (context) => AnimatedDialog(
                                title: StringManager.confirmation.tr(),
                                description: StringManager.youWillRecharge(
                                  coin: state.data[selectedCardIndex!].coin
                                      .toString(),
                                  price: state.data[selectedCardIndex!].usd
                                      .toString(),
                                ),
                                conText: StringManager.confirm.tr(),
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                            );
                          }
                        },
                        radius: 10.r,
                        width: 320.w,
                        height: 56,
                        title: selectedCardIndex == null
                            ? StringManager.recharge.tr()
                            : "${StringManager.recharge.tr()} \$ ${state.data[selectedCardIndex!].usd}",
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class RechargeCoinsDiamondItem extends StatelessWidget {
  const RechargeCoinsDiamondItem({
    super.key,
    required this.diamonds,
    required this.coins,
    required this.isCoins,
    required this.isSelected,
    required this.onTap,
  });

  final String diamonds;
  final String coins;
  final bool isCoins;
  final bool isSelected;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 88.h,
        width: 160.w,
        decoration: BoxDecoration(
          color: ColorManager.surfaceCardColor,
          borderRadius: 13.radius,
          border: Border.all(
            color: isSelected
                ? ColorManager.primary
                : ColorManager.black.withValues(alpha: (0.2 )),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    isCoins
                        ? AssetsManager.coinsIcon
                        : AssetsManager.exchangeDiamondIcon,
                    height:isCoins?30: 36,
                    width:isCoins?30: 36,
                  ),
                  5.wBox,
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        diamonds,
                        style: context.bodyMedium.size(20).bold.colorExt(ColorManager.textPrimary),

                      ),
                    ),
                  ),
                ],
              ),
            ),
            5.hBox,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0.w),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  coins,
                  style: context.bodyMedium.size(15).w400.colorExt(ColorManager.itemTexGreyt),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/*
Widget screeeen() {
  return BlocBuilder<DiamondBloc, DiamondState>(
    bloc: di<DiamondBloc>(),
    builder: (context, state) {
      return SizedBox(
        height: ScreenUtil().screenHeight,
        child: Padding(
          padding: context.paddingSymmetric(horizontal: 10),
          child: Column(
            children: [
              Padding(
                padding: context.paddingOnly(
                  top: 20,
                  bottom: 30,
                ),
                child: const GoldenDiamondCard(isCoins: false),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    StringManager.rechargeCoins.tr(),
                    style: context.bodyLarge.w600,
                  ),
                  InkWell(
                    onTap: () {
                      di<MyStoreBloc>().add(const GetMyStoreEvent());
                      di<DiamondBloc>().add(GetDiamondDataEvent());
                    },
                    child: Image.asset(
                      AssetsManager.refresh,
                      scale: 2,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: HandlingDataWidget(
                  reqState: state.reqStateDiamond,
                  title: StringManager.noDataYet.tr(),
                  subTitle: StringManager.pleaseTryAgine.tr(),
                  onTap: () {
                    di<DiamondBloc>().add(GetDiamondDataEvent());
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: context.paddingSymmetric(
                          vertical: 5,
                        ),
                        child: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AnimatedDialog(
                                title: StringManager.confirmation,
                                description: StringManager.youWillEx(
                                  coin: state.diamondData!.data[index].coin
                                      .toString(),
                                  dimond: state
                                      .diamondData!.data[index].diamonds
                                      .toString(),
                                ),
                                conText: StringManager.confirm,
                                onTap: () {
                                  di<DiamondBloc>().add(
                                    ExchangeDiamondEvent(
                                      itemId: state.diamondData?.data[index].id
                                              .toString() ??
                                          "",
                                      context: context,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          child: DiamondsCardItem(
                            replaceWithGoldItemEntity:
                                state.diamondData!.data[index],
                          ),
                        ),
                      );
                    },
                    itemCount: state.diamondData?.data.length ?? 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

*/