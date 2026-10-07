import 'package:skeletonizer/skeletonizer.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';
import 'package:general/src/features/profile/profile.dart';
import '../../../domain/entities/replace_with_gold_entity.dart';
import 'widgets/recharge_diamonds_item.dart';

class RechargeDiamondPage extends StatefulWidget {
  const RechargeDiamondPage({super.key});

  @override
  State<RechargeDiamondPage> createState() => _RechargeDiamondPageState();
}

class _RechargeDiamondPageState extends State<RechargeDiamondPage> {
  @override
  void initState() {
    if (!di<DiamondBloc>().state.reqStateDiamond.isLoaded) {
      di<DiamondBloc>().add(const GetDiamondDataEvent());
    }
    super.initState();
  }

  int? selectedCardIndex;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DiamondBloc, DiamondState>(
      buildWhen: (prev, curr) => prev.reqStateDiamond != curr.reqStateDiamond || prev.diamondData != curr.diamondData,
      listener: (context, state) {
        if (state.reqStateExchange.isLoading) {
          Methods.showToast(context, isLoading: true);
        } else if (state.reqStateExchange.isLoaded) {
          di<MyStoreBloc>().add(const GetMyStoreEvent());
        }
        // else  if (state.reqStateExchange.isError) {
        //   Methods.showToast(context, message: state.messageDiamond ?? '');
        // }
      },
      bloc: di<DiamondBloc>(),
      builder: (context, state) {
        return Scaffold(
            appBar: AppBarWidget(
              title: StringManager.exchangeDiamond.tr(),
              titleStyle: context.bodyMedium
                  .size(18)
                  .w600
                  .colorExt(ColorManager.appBarTitlegrey),
              actions: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.0.w),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, Routes.billPage);
                    },
                    child: Image.asset(
                      AssetsManager.billIcon,
                      color: ColorManager.textPrimary,
                      scale: 3,
                    ),
                  ),
                ),
              ],
            ),
            body: RefreshIndicatorWidget(
              onRefresh: () async {
                di<DiamondBloc>().add(const GetDiamondDataEvent());
                di<MyStoreBloc>().add(const GetMyStoreEvent(isLoading: false));
              },
              child: HandlingDataWidget(
                reqState: state.reqStateDiamond,
                title: StringManager.noDataYet.tr(),
                isNeedLoadingWidget: true,
                subTitle: StringManager.pleaseTryAgine.tr(),
                onTap: () {
                  di<DiamondBloc>().add(const GetDiamondDataEvent());
                },
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        15.hBox,
                        Container(
                          width: ScreenUtil().screenWidth,
                          height: 125.h,
                          decoration: BoxDecoration(
                            color: ColorManager.textTabBar,
                            borderRadius: 10.radius,
                            image: DecorationImage(
                              alignment: Alignment.bottomLeft,
                              image:
                                  AssetImage(AssetsManager.rechargeCoinsIcon),
                              scale: 3,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextWidget(
                                StringManager.diamonds.tr(),
                                style: context.bodyMedium.w500
                                    .colorExt(ColorManager.secondaryText)
                                    .size(12),
                              ),
                              10.hBox,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    AssetsManager.diamondsIcon,
                                    scale: 3,
                                  ),
                                  5.wBox,
                                  BlocBuilder<MyStoreBloc, MyStoreState>(
                                    bloc: di<MyStoreBloc>(),
                                    buildWhen: (prev, curr) => prev.myStore != curr.myStore,
                                    builder: (context, state) {
                                      return TextWidget(
                                        '${state.myStore?.diamonds ?? 0}',
                                        style: context.bodyLarge.w700
                                            .size(30)
                                            .colorExt(ColorManager.textPrimary),
                                      );
                                    },
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        10.hBox,
                        Skeletonizer(
                          enabled:
                              state.reqStateDiamond == RequestState.loading,
                          child: ListView.builder(
                            itemCount: state.reqStateDiamond.isLoading
                                ? 10
                                : (state.diamondData?.data.length ?? 0),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  if (StringManager.userType[0]! ||
                                      StringManager.userType[3]! ||
                                      StringManager.userType[5]!) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AnimatedDialog(
                                        title: StringManager.confirmation.tr(),
                                        description: StringManager.youWillEx(
                                          coin: state
                                              .diamondData!.data[index].coin
                                              .toString(),
                                          dimond: state
                                              .diamondData!.data[index].diamonds
                                              .toString(),
                                        ),
                                        conText: StringManager.confirm.tr(),
                                        onTap: () {
                                          di<DiamondBloc>().add(
                                            ExchangeDiamondEvent(
                                              itemId: state.diamondData
                                                      ?.data[index].id
                                                      .toString() ??
                                                  "",
                                              context: context,
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AnimatedDialog(
                                        title: StringManager.confirmation.tr(),
                                        description: StringManager
                                            .exchangeDiamondWarning
                                            .tr(),
                                        isHideConfirm: true,
                                      ),
                                    );
                                  }

                                  setState(() {
                                    selectedCardIndex = index;
                                  });
                                },
                                child: RechargeDiamondsItem(
                                    diamondEntity:
                                        state.reqStateDiamond.isLoading
                                            ? const ReplaceWithGoldItemEntity(
                                                id: 1, diamonds: 1, coin: 2)
                                            : state.diamondData?.data[index]),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
            /*  bottomNavigationBar: Padding(
            padding: context.paddingSymmetric(horizontal: 15, vertical: 10),
            child: ButtonWidget(
              onPressed: () {
                if (selectedCardIndex != null) {
                  if (StringManager.userType[0]! ||
                      StringManager.userType[3]! ||
                      StringManager.userType[5]!) {
                    showDialog(
                      context: context,
                      builder: (context) => AnimatedDialog(
                        title: StringManager.confirmation,
                        description: StringManager.youWillEx(
                          coin: state
                              .diamondData!.data[selectedCardIndex!].coin
                              .toString(),
                          dimond: state
                              .diamondData!.data[selectedCardIndex!].diamonds
                              .toString(),
                        ),
                        conText: StringManager.confirm,
                        onTap: () {
                          di<DiamondBloc>().add(
                            ExchangeDiamondEvent(
                              itemId: state.diamondData
                                      ?.data[selectedCardIndex!].id
                                      .toString() ??
                                  "",
                              context: context,
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AnimatedDialog(
                        title: StringManager.confirmation,
                        description:
                            StringManager.exchangeDiamondWarning.tr(),
                        isHideConfirm: true,
                      ),
                    );
                  }
                }
              },
              title: StringManager.exchangeNow.tr(),
              backgroundColors: ColorManager.saveButtonColors,
              radius: 5.r,
              width: 350,
              height: 60,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
                 */
            );
      },
    );
  }
}

/*
Scaffold(
            appBar: AppBarWidget(
              title: StringManager.exchangeDiamond.tr(),
              titleStyle: context.bodyMedium
                  .size(13)
                  .w500
                  .colorExt(ColorManager.appBarTitlegrey),
              actions: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.0.w),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, Routes.billPage);
                    },
                    child: Image.asset(
                      AssetsManager.billIcon,
                      color: ColorManager.textPrimary,
                      scale: 3,
                    ),
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    20.hBox,
                    CoinsCardBuilder(
                      colors: [
                        ColorManager.profileCardColor.withValues(alpha:0.5),
                        ColorManager.profileCardColor,
                        ColorManager.profileCardColor,
                      ],
                      title: StringManager.avaiableCoins.tr(),
                      trailing: Row(
                        children: [
                          Image.asset(
                            AssetsManager.diamondIcon,
                            fit: BoxFit.cover,
                            height: 16.h,
                            width: 16.w,
                          ),
                          10.wBox,
                          BlocBuilder<MyStoreBloc, MyStoreState>(
                            bloc: di<MyStoreBloc>(),
                            builder: (context, state) {
                              return TextWidget(
                                "${state.myStore?.diamonds}",
                                overflow: TextOverflow.clip,
                                style: context.bodyMedium.bold
                                    .size(15)
                                    .colorExt(
                                      ColorManager.onDark,
                                    )
                                    .copyWith(
                                        fontFamily: StringManager.fontFamily),
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
                      title: StringManager.myIncome2,
                      trailing: BlocBuilder<MyStoreBloc, MyStoreState>(
                        bloc: di<MyStoreBloc>(),
                        builder: (context, state) {
                          return TextWidget(
                            "\$${state.myStore?.userUsd}",
                            overflow: TextOverflow.clip,
                            style: context.bodyMedium.bold
                                .size(15)
                                .colorExt(
                                  ColorManager.onDark,
                                )
                                .copyWith(fontFamily: StringManager.fontFamily),
                          );
                        },
                      ),
                      onTap: () {},
                    ),
                    20.hBox,
                    TextWidget(
                      StringManager.rechargeOptions.tr(),
                      style: context.bodyMedium.w500
                          .copyWith(fontSize: 16.sp, color: ColorManager.textPrimary),
                    ),
                    10.hBox,
                    state.diamondData?.data == null ||
                            state.diamondData?.data.isEmpty == true
                        ? const SizedBox()
                        : SizedBox(
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
                              itemCount: state.diamondData?.data.length,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return RechargeCoinsDiamondItem(
                                  isCoins: false,
                                  isSelected: selectedCardIndex == index,
                                  coins:
                                      "${state.diamondData?.data[index].coin ?? ''} ${StringManager.coins.tr()}",
                                  diamonds:
                                      '${state.diamondData?.data[index].diamonds}',
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
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Padding(
              padding: context.paddingSymmetric(horizontal: 15, vertical: 10),
              child: ButtonWidget(
                onPressed: () {
                  if (selectedCardIndex != null) {
                    if (StringManager.userType[0]! ||
                        StringManager.userType[3]! ||
                        StringManager.userType[5]!) {
                      showDialog(
                        context: context,
                        builder: (context) => AnimatedDialog(
                          title: StringManager.confirmation,
                          description: StringManager.youWillEx(
                            coin: state
                                .diamondData!.data[selectedCardIndex!].coin
                                .toString(),
                            dimond: state
                                .diamondData!.data[selectedCardIndex!].diamonds
                                .toString(),
                          ),
                          conText: StringManager.confirm,
                          onTap: () {
                            di<DiamondBloc>().add(
                              ExchangeDiamondEvent(
                                itemId: state.diamondData
                                        ?.data[selectedCardIndex!].id
                                        .toString() ??
                                    "",
                                context: context,
                              ),
                            );
                          },
                        ),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AnimatedDialog(
                          title: StringManager.confirmation,
                          description:
                              StringManager.exchangeDiamondWarning.tr(),
                          isHideConfirm: true,
                        ),
                      );
                    }
                  }
                },
                title: StringManager.exchangeNow.tr(),
                backgroundColors: ColorManager.saveButtonColors,
                radius: 5.r,
                width: 350,
                height: 60,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),


*/
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
                        style: context.bodyMedium.w500
                            .colorExt(isSelected
                                ? ColorManager.onDark
                                : ColorManager.textPrimary)
                            .size(15),
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
              child: Text(coins,
                  style: context.bodyMedium
                      .size(13)
                      .w500
                      .colorExt(ColorManager.textPrimary)),
            ),
          ),
        ],
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
