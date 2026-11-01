part of '../bag_page.dart';

/// Backpack card (shared [StoreItemCard] look): time left underneath, and an
/// "in use" mark on the item currently worn.
class BagProductItem extends StatelessWidget {
  final MyBagEntity data;
  final bool isSelected;
  final VoidCallback onTap;

  const BagProductItem({
    required this.data,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final expire = (data.expire ?? '').trim();
    return StoreItemCard(
      image: data.image ?? '',
      name: data.name ?? '',
      selected: isSelected,
      onTap: onTap,
      footer: expire.isEmpty
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule_rounded,
                    size: 12.sp, color: Colors.white60),
                3.wBox,
                Text(
                  expire,
                  style: TextStyle(color: Colors.white70, fontSize: 11.sp),
                ),
              ],
            ),
      badge: data.isUsed
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                gradient: const LinearGradient(colors: StoreColors.button),
              ),
              child: Icon(Icons.check_rounded,
                  color: Colors.white, size: 12.sp),
            )
          : null,
    );
  }
}
