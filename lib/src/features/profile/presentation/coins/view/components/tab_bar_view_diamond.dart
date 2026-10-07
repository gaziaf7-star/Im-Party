part of'../coins_page.dart';
class TabBarViewDiamond extends StatelessWidget {

  const TabBarViewDiamond({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ColorManager.cardDecoration(
        borderRadius: BorderRadius.only(
          topRight: 25.radiusCircular,
          topLeft: 25.radiusCircular,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: context.paddingOnly(
              top: 20,
              bottom: 20,
            ),
            child: const GoldenDiamondCard(isCoins: false),
          ),
          Text(StringManager.useOfDiamonds.tr(),
              style: context.bodyLarge.w800),
          15.hBox,
          Text(StringManager.diamondsNeeded.tr(),
              style: context.bodyMedium.w500),
          Text(StringManager.receiveGifts.tr(),
              style: context.bodyMedium.w500),
          150.hBox,
          if (MyDataModel.getInstance().myType == 0 || MyDataModel.getInstance().myType == 3 || MyDataModel.getInstance().myType == 5)
            Align(
              alignment: Alignment.center,
              child: ButtonWidget(
                onPressed: () {
                  Navigator.pushNamed(context, Routes.exchangeDiamondPage);
                },
                fontSize: 18,
                width: 220.w,
                backgroundColors: ColorManager.backgroundGradientDiamond,
                title: StringManager.exchange.tr(),
              ),
            ),
        ],
      ),
    );
  }
}
