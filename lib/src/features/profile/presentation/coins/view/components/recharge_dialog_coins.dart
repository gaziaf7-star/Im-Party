import 'package:general/src/features/profile/domain/entities/gold_coins_entity.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/get_gold_coin/gold_coin_bloc.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';

import '../../../../../../core/index.dart';
part '../widgets/coins_to_dollars_dialog_item.dart';

class RechargeDialog extends StatefulWidget {
  const RechargeDialog({super.key});

  @override
  State<RechargeDialog> createState() => _RechargeDialogState();
}

class _RechargeDialogState extends State<RechargeDialog> {
  GoldCoinsEntity? productDetailsResponse;

  @override
  void initState() {
    if (!di<GoldCoinBloc>().state.reqState.isLoaded) {
      di<GoldCoinBloc>().add(const GetGoldCoinDataEvent());
    }
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.paddingSymmetric(horizontal: 25,vertical: 10),
      decoration: BoxDecoration(
        color: ColorManager.surfaceCardColor,
        borderRadius: BorderRadius.only(
          topRight: 15.radiusCircular,
          topLeft: 15.radiusCircular,
        ),
      ),
      height: 450.h,
      child: Column(
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              StringManager.recharge.tr(),
              style:
                  context.bodyLarge.w600.colorExt(ColorManager.primary),
            ),
          ),
          15.hBox,
          BlocBuilder<MyStoreBloc, MyStoreState>(
            bloc: di<MyStoreBloc>(),
            buildWhen: (prev, curr) => prev.reqState != curr.reqState || prev.myStore != curr.myStore,
            builder: (context, state) {
              if (state.reqState.isLoaded) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${StringManager.balance.tr()}: ${state.myStore?.coins ?? 0}",
                      style: context.bodyMedium.w500
                          .colorExt(ColorManager.secondaryText.withValues(alpha: (0.7 ))),
                    ),
                    InkWell(
                      child: Image.asset(
                        AssetsManager.refresh,
                        scale: 2,
                      ),
                      onTap: () {
                        di<MyStoreBloc>().add(const GetMyStoreEvent());
                      },
                    ),
                  ],
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          20.hBox,
          Expanded(
            child: BlocBuilder<GoldCoinBloc, GoldCoinState>(
              bloc: di<GoldCoinBloc>(),
              buildWhen: (prev, curr) => prev.reqState != curr.reqState || prev.data != curr.data,
              builder: (context, state) {
                return HandlingDataWidget(
                  reqState: state.reqState,
                  title: StringManager.noDataYet.tr(),
                  subTitle: StringManager.pleaseTryAgine.tr(),
                  onTap: () {
                    di<GoldCoinBloc>().add(const GetGoldCoinDataEvent());
                  },
                  child: SizedBox(
                    width: ScreenUtil().screenWidth,
                    child: GridView.builder(
                      shrinkWrap: true,

                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 1.2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        crossAxisCount: 3,
                      ),
                      itemBuilder: (context, index) => CoinsToDollarsDialogItem(
                        goldCoinsEntity: state.data[index],
                      ),
                      itemCount: state.data.length,
                    ),
                  ),
                );
              },
            ),
          ),
          ButtonWidget(
              onPressed: (){},
              title: StringManager.recharge.tr(),
              height: 45.h,
          ),
        ],
      ),
    );
  }
}
