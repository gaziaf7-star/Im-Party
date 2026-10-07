part of '../components/recharge_dialog_coins.dart';

class CoinsToDollarsDialogItem extends StatelessWidget {
  final GoldCoinsEntity goldCoinsEntity;

  const CoinsToDollarsDialogItem({required this.goldCoinsEntity, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GoldCoinBloc, GoldCoinState>(
      bloc: di<GoldCoinBloc>(),
      buildWhen: (prev, curr) => prev.itemId != curr.itemId,
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            border: state.itemId == goldCoinsEntity.id.toString()
                ? Border.all(color: ColorManager.secondaryColor)
                : Border.all(color: ColorManager.transparent),
            color: state.itemId == goldCoinsEntity.id.toString()
                ? ColorManager.secondaryColor.withValues(alpha: (0.2 ))
                : ColorManager.surfaceCardColor,
            borderRadius: 8.radius,
          ),
          child: Material(
            color: ColorManager.transparent,
            shadowColor: ColorManager.transparent,
            elevation: 0,
            child: InkWell(
              onTap: () {
                di<GoldCoinBloc>().add(
                  SelectCoinDataEvent(
                    itemId: goldCoinsEntity.id.toString(),
                  ),
                );
              },
              borderRadius: 10.radius,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          AssetsManager.coinsVip,
                          scale: 3,
                        ),
                        5.wBox,
                        ConstrainedBox(
                          constraints: BoxConstraints(
                              minWidth: 5.w,
                              maxWidth: 70.w
                          ),
                          child:  FittedBox(
                            child: TextWidget(
                              goldCoinsEntity.coin.toString(),
                              overflow: TextOverflow.ellipsis,
                              style: context.bodyMedium.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  2.hBox,
                  TextWidget(
                    '\$${goldCoinsEntity.usd}',
                    style:
                    context.bodyMedium.colorExt(ColorManager.secondaryText.withValues(alpha: (0.4 ))),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
