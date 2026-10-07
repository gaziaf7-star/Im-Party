part of '../coins_page.dart';

class TabBarViewCoinsBody extends StatefulWidget {
  const TabBarViewCoinsBody({super.key});

  @override
  State<TabBarViewCoinsBody> createState() => _TabBarViewCoinsBodyState();
}

class _TabBarViewCoinsBodyState extends State<TabBarViewCoinsBody> {
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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Support contact (WhatsApp). White-label: the number is
                        // server-driven (admin -> /config/settings ->
                        // RealtimeConfig.supportWhatsapp). Hidden entirely when the
                        // admin hasn't set one — never show a foreign number.
                        if (RealtimeConfig.supportWhatsapp.isNotEmpty) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              10.wBox,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextWidget(
                                    StringManager.contactSeller.tr(),
                                    style: context.bodyMedium.bold.copyWith(
                                        fontSize: 13.sp,
                                        color: ColorManager.textPrimary),
                                  ),
                                  TextWidget(
                                    RealtimeConfig.supportWhatsapp,
                                    style: context.bodyMedium.w400.copyWith(
                                        fontSize: 12.sp,
                                        color: ColorManager.textPrimary),
                                  )
                                ],
                              ),
                              const Spacer(),
                              InkWell(
                                borderRadius: BorderRadius.circular(30.r),
                                onTap: () {
                                  Methods.safeLaunchUrl(
                                      "https://wa.me/${RealtimeConfig.supportWhatsapp}");
                                },
                                child: Container(
                                  height: 30.h,
                                  width: 100.w,
                                  decoration: BoxDecoration(
                                    color: ColorManager.greenWhatsApp,
                                    borderRadius: BorderRadius.circular(30.r),
                                  ),
                                  child: Row(
                                    children: [
                                      TextWidget(
                                        StringManager.message.tr(),
                                        style: context.bodyMedium.bold.copyWith(
                                            fontSize: 12.sp,
                                            color: ColorManager.textPrimary),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          20.hBox,
                        ],
                        CoinsCardBuilder(
                          colors: [
                            ColorManager.profileCardColor
                                .withValues(alpha: (0.5)),
                            ColorManager.profileCardColor,
                            ColorManager.profileCardColor,
                          ],
                          title: StringManager.avaiableCoins.tr(),
                          trailing: Row(
                            children: [
                              // Image.asset(
                              //   AssetsManager.availableCoin,
                              //   fit: BoxFit.cover,
                              //   height: 16.h,
                              //   width: 16.w,
                              // ),
                              10.wBox,
                              BlocBuilder<MyStoreBloc, MyStoreState>(
                                bloc: di<MyStoreBloc>(),
                                buildWhen: (prev, curr) => prev.myStore != curr.myStore,
                                builder: (context, state) {
                                  return TextWidget(
                                    "${state.myStore?.coins}",
                                    overflow: TextOverflow.clip,
                                    style: context.bodyMedium.bold
                                        .size(15)
                                        .colorExt(
                                          ColorManager.onDark,
                                        )
                                        .copyWith(
                                            fontFamily:
                                                StringManager.fontFamily),
                                  );
                                },
                              ),
                            ],
                          ),
                          onTap: () {},
                        ),
                        10.hBox,
                        CoinsCardBuilder(
                          colors: ColorManager.familyColors,
                          title: StringManager.myIncome2.tr(),
                          trailing: TextWidget(
                            "\$1000",
                            overflow: TextOverflow.clip,
                            style: context.bodyMedium.bold
                                .size(15)
                                .colorExt(
                                  ColorManager.onDark,
                                )
                                .copyWith(fontFamily: StringManager.fontFamily),
                          ),
                          onTap: () {},
                        ),
                        10.hBox,
                        CoinsCardBuilder(
                          colors: ColorManager.hostColors,
                          title: StringManager.exchangeDiamond.tr(),
                          onTap: () {
                            Navigator.pushNamed(
                                context, Routes.tabBarViewDiamonds);
                          },
                        ),
                        10.hBox,
                        CoinsCardBuilder(
                          colors: ColorManager.agencyColors,
                          title: StringManager.withdrawal.tr(),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              Routes.hostWithdrawel,
                              arguments: const CoinsScreenParam(
                                stopTransferButton: false,
                                isFromCoinsScreen: false,
                              ),
                            );
                          },
                        ),
                        10.hBox,
                        // Padding(
                        //   padding: context.paddingOnly(
                        //     top: 20,
                        //     bottom: 20,
                        //   ),
                        //   child: const GoldenDiamondCard(isCoins: true),
                        // ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Text(
                        //       StringManager.rechargeCoins.tr(),
                        //       style: context.bodyLarge.w600,
                        //     ),
                        //     InkWell(
                        //       onTap: () {
                        //         di<MyStoreBloc>().add(const GetMyStoreEvent());
                        //         // getIt<GoldCoinBloc>().add(const GetGoldCoinDataEvent());
                        //       },
                        //       child: Image.asset(
                        //         AssetsManager.refresh,
                        //         scale: 2,
                        //       ),
                        //     ),
                        //   ],
                        // ),

                        10.hBox,
                        TextWidget(
                          StringManager.rechargeOptions.tr(),
                          style: context.bodyMedium.w500.copyWith(
                              fontSize: 16.sp, color: ColorManager.textPrimary),
                        ),
                        10.hBox,

                        SizedBox(
                          width: ScreenUtil().screenWidth,
                          child: GridView.builder(
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 5,
                              childAspectRatio: 110 / 129,
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

                        10.hBox,
                        GestureDetector(
                          onTap: () =>
                              Methods.safeLaunchUrl("mailto:Support@gmail.com"),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      "${StringManager.rechargeProblem.tr()}\n",
                                  style: context.bodyMedium.w400.copyWith(
                                      fontSize: 12.sp,
                                      color: ColorManager.textPrimary),
                                ),
                                TextSpan(
                                  text: "Support@gmail.com",
                                  style: context.bodyMedium.w400.copyWith(
                                      fontSize: 12.sp,
                                      color: ColorManager.primary),
                                ),
                              ],
                            ),
                          ),
                        ),
                        70.hBox,
                      ],
                    ),
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
                      title: StringManager.rechargeNow.tr(),
                      backgroundColors: ColorManager.saveButtonColors,
                      radius: 5.r,
                      width: 350,
                      height: 60,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ));
      },
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 80.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isSelected
                  ? ColorManager.secondaryColor
                  : ColorManager.surfaceCardColor,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5), topRight: Radius.circular(5)),
              border: Border.all(
                color: isSelected
                    ? ColorManager.primary
                    : ColorManager.black.withValues(alpha: (0.2)),
                width: 1,
              ),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    isCoins
                        ? AssetsManager.coinIcon
                        : AssetsManager.exchangeDiamondIcon,
                    height: 35,
                    width: 35,
                  ),
                  10.wBox,
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        diamonds,
                        style: context.bodyMedium.size(15).w500.colorExt(
                              isSelected
                                  ? ColorManager.onDark
                                  : ColorManager.textPrimary,
                            ),
                      ),
                    ),
                  ),
                ]),
          ),
          Container(
            height: 40.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: ColorManager.primary,
              borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(5),
                  bottomLeft: Radius.circular(5)),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                coins,
                style: context.bodyMedium.size(13).w500.colorExt(
                      ColorManager.onDark,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
