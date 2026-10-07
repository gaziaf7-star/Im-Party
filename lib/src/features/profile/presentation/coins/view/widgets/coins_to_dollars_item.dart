part of '../coins_page.dart';

class CoinsToDollarsItem extends StatelessWidget {
  final GoldCoinsEntity goldCoinsEntity;

  const CoinsToDollarsItem({required this.goldCoinsEntity, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      margin: context.paddingSymmetric(vertical: 8),
      padding: context.paddingSymmetric(horizontal: 5, vertical: 5),
      decoration: ColorManager.cardDecoration(
        borderRadius: 5.radius,
        // border: Border.all(color: ColorManager.whiteGrey2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                AssetsManager.starCoinsIcon,
                scale: 2.5,
              ),
              // 5.wBox,
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: 5.w, maxWidth: 180.w),
                child: TextWidget(
                  goldCoinsEntity.coin.toString(),
                  overflow: TextOverflow.ellipsis,
                  style: context.bodyMedium.size(15).w500.colorExt(
                        ColorManager.textTabBar,
                      ),
                ),
              ),
              5.wBox,
              TextWidget(
                StringManager.coins.tr(),
                style: context.bodyMedium.size(11).w400.colorExt(
                      ColorManager.greyText,
                    ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 65.w,
            height: 25.h,
            padding: context.paddingSymmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
                color: ColorManager.pink, borderRadius: 10.radius),
            child: Center(
              child: TextWidget(
                '\$${goldCoinsEntity.usd}',
                style: context.bodyMedium.w500
                    .size(10)
                    .colorExt(ColorManager.textPrimary),
              ),
            ),
          )
        ],
      ),
    );
  }
}
