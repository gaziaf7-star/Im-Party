import 'package:general/src/features/profile/presentation/coins/view/coins_page.dart';

import '../../../../../../core/index.dart';
import '../../../exchange_diamond/bloc/diamond_bloc.dart';
import '../../bloc/my_store_bloc/my_store_bloc.dart';

class TabBarViewDiamondsBody extends StatefulWidget {
  const TabBarViewDiamondsBody({super.key});

  @override
  State<TabBarViewDiamondsBody> createState() => _TabBarViewDiamondsBodyState();
}

class _TabBarViewDiamondsBodyState extends State<TabBarViewDiamondsBody> {
  int? selectedCardIndex;
  @override
  void initState() {
    if (!di<DiamondBloc>().state.reqStateDiamond.isLoaded) {
      di<DiamondBloc>().add(const GetDiamondDataEvent());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiamondBloc, DiamondState>(
      bloc: di<DiamondBloc>(),
      buildWhen: (prev, curr) => prev.reqStateDiamond != curr.reqStateDiamond || prev.diamondData != curr.diamondData,
      builder: (context, state) {
        return BackgroundImgWidget(
       //   img: AssetsManager.mainBackgroundImg,
          child: Scaffold(
            appBar: AppBarWidget(
              title: StringManager.exchangeDiamond.tr(),
              titleStyle: context.bodyMedium.bold
                  .copyWith(fontSize: 18.sp, color: ColorManager.textPrimary),
              iconButtonBgColor: ColorManager.profileCardColor.withValues(alpha: (0.1 )),
            ),
            body: HandlingDataWidget(
                reqState: state.reqStateDiamond,
                title: StringManager.noDataYet.tr(),
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
                        20.hBox,
                        CoinsCardBuilder(
                          colors: [
                            ColorManager.profileCardColor.withValues(alpha: (0.5 )),
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
                                buildWhen: (prev, curr) => prev.myStore != curr.myStore,
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
                          colors: ColorManager.agencyColors,
                          title: StringManager.withdrawal.tr(),
                          onTap: () {
                            Navigator.pushNamed(context, Routes.withDrawScreen);
                          },
                        ),
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
                            itemCount: state.diamondData?.data.length,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return RechargeCoinsDiamondItem(
                                isCoins: true,
                                isSelected: selectedCardIndex == index,
                                coins:
                                    "\$ ${state.diamondData?.data[index].coin ?? ''}",
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
                        80.hBox,
                      ],
                    ),
                  ),
                )),
           
           
            bottomNavigationBar: Padding(
              padding: context.paddingSymmetric(vertical: 10),
              child: ButtonWidget(
                onPressed: () {
                  if (selectedCardIndex != null) {
                    showDialog(
                      context: context,
                      builder: (context) => AnimatedDialog(
                        title: StringManager.confirmation.tr(),
                        description: StringManager.youWillEx(
                          coin: state.diamondData!.data[selectedCardIndex!].coin
                              .toString(),
                          dimond: state
                              .diamondData!.data[selectedCardIndex!].diamonds
                              .toString(),
                        ),
                        conText: StringManager.confirm.tr(),
                        onTap: () {
                          di<DiamondBloc>().add(
                            ExchangeDiamondEvent(
                              itemId: state
                                      .diamondData?.data[selectedCardIndex!].id
                                      .toString() ??
                                  "",
                              context: context,
                            ),
                          );
                        },
                      ),
                    );
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
        );
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
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5)),
              border: Border.all(
                color: isSelected
                    ? ColorManager.primary
                    : ColorManager.black.withValues(alpha: (0.2 )),
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
                        style:
                        context.bodyMedium.size(15).w500.colorExt(isSelected
                            ? ColorManager.onDark
                            : ColorManager.textPrimary,),

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
                style: context.bodyMedium.size(13).w500.colorExt(ColorManager.textPrimary)
              ),
            ),
          ),
        ],
      ),
    );
  }
}
