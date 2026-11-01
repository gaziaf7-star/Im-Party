part of '../mall_page.dart';

/// Store card (shared [StoreItemCard] look) with the price and days.
class _MallProductItem extends StatelessWidget {
  final MallEntity data;
  final MallOrBagType tabType;
  final bool isSelected;
  final VoidCallback onTap;

  const _MallProductItem({
    required this.data,
    required this.tabType,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final days = data.expire ?? 0;
    return StoreItemCard(
      image: data.image ?? '',
      name: data.name ?? '',
      selected: isSelected,
      onTap: onTap,
      footer: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(AssetsManager.coinPayment, width: 14.w, height: 14.w),
          3.wBox,
          Text(
            '${data.price ?? 0}',
            style: TextStyle(
              color: StoreColors.gold,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (days > 0)
            Text(
              ' / ${days}d',
              style: TextStyle(color: Colors.white70, fontSize: 11.sp),
            ),
        ],
      ),
    );
  }
}
