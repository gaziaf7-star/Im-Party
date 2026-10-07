part of '../exchange_diamond_page.dart';

class DiamondsCardItem extends StatelessWidget {
  final ReplaceWithGoldItemEntity? replaceWithGoldItemEntity;

  const DiamondsCardItem({required this.replaceWithGoldItemEntity, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: context.paddingSymmetric(horizontal: 5),
      padding: context.paddingSymmetric(horizontal: 15, vertical: 15),
      decoration: ColorManager.cardDecoration(
        borderRadius: 10.radius,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                AssetsManager.diamondsIcon,
                scale: 3,
              ),
              10.wBox,
              Text(
                replaceWithGoldItemEntity?.diamonds.toString() ?? '',
                style: context.bodyLarge.w700
                    .size(20)
                    .colorExt(ColorManager.textPrimary),
              ),
            ],
          ),
          Container(
            height: 33.h,
            width: 110.w,
            decoration: BoxDecoration(
              // gradient: const LinearGradient(colors: ColorManager.backgroundGradientDiamond),
              borderRadius: 20.radius,
              color: ColorManager.diamondsAccent,
            ),
            child: Padding(
              padding: context.paddingSymmetric(horizontal: 20),
              child: FittedBox(
                child: Text(
                  "${replaceWithGoldItemEntity?.coin.toString() ?? ''}Coins",
                  style: context.bodyMedium.w500
                      .colorExt(ColorManager.onDark)
                      .size(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
