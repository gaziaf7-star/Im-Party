part of'../coins_page.dart';

class GoldenDiamondCard extends StatelessWidget {
  final bool isCoins;

  const GoldenDiamondCard({
    required this.isCoins,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 100.h,
        padding:context.paddingSymmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: 18.radius,
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage(
              isCoins ? AssetsManager.goldCardBackground : AssetsManager.diamondCardBackground,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isCoins ? StringManager.coins.tr() : StringManager.diamonds.tr(),
                  style: context.bodyLarge.w800.colorExt(ColorManager.textPrimary),
                ),
                25.hBox,
                BlocBuilder<MyStoreBloc, MyStoreState>(
                  bloc: di<MyStoreBloc>(),
                  buildWhen: (prev, curr) => prev.myStore != curr.myStore,
                  builder: (context, state) {
                    // Diamond card shows earned_coins now, not diamonds --
                    // on request; the card's own look (label/icon/style)
                    // stays exactly the same.
                    return TextWidget(
                      '${isCoins ? state.myStore?.coins : state.myStore?.earnedCoins}',
                      style: context.bodyLarge.w700.size(25).colorExt(ColorManager.textPrimary),
                    );
                  },
                ),
              ],
            ),
            isCoins == true
                ? Image.asset(
              AssetsManager.iconsCoine,
              width: 55.w,
              height: 55.h,
            )
                : Image.asset(
              AssetsManager.diamondIcon,
              width: 55.w,
              height: 55.h,
            ),
          ],
        ),
      ),
    );
  }
}
