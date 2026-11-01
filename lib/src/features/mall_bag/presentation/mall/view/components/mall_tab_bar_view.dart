part of '../mall_page.dart';

/// 3-column grid of a category's items. Tapping a card selects it (it then
/// shows on the podium above).
class _MallTabBarView extends StatelessWidget {
  final List<MallEntity> mall;
  final MallOrBagType tabType;
  final MallEntity? selected;
  final bool isLoading;
  final Future<void> Function() onRefresh;

  const _MallTabBarView({
    required this.mall,
    required this.tabType,
    required this.selected,
    required this.onRefresh,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: StoreColors.lilac,
      backgroundColor: const Color(0xFF1A1724),
      onRefresh: onRefresh,
      child: GridView.builder(

        padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 16.h),
        itemCount: mall.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: .74,
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 10.w,
        ),
        itemBuilder: (context, index) {
          final item = mall[index];
          return _MallProductItem(
            data: item,
            tabType: tabType,
            isSelected: selected?.id == item.id,
            onTap: () {
              HapticFeedback.selectionClick();
              di<MallBloc>().add(SelectMallItemEvent(selectedItem: item));
            },
          ).storeEntrance(index);
        },
      ),
    );
  }
}

/// Send (outlined) + Purchase (lilac gradient, with the price) buttons.
class _MallBottomBar extends StatelessWidget {
  const _MallBottomBar({required this.selected, required this.type});

  final MallEntity? selected;
  final MallOrBagType type;

  void _openSendSheet(BuildContext context) {
    final item = selected;
    if (item == null || item.id == null) return;
    customModalBottomSheet(
      context,
      radius: 0,
      height: ScreenUtil().screenHeight,
      child: SendBottomSheet(isMall: true, selectedItemMall: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final enabled = selected?.id != null;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 10.h),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: StorePillButton(
                enabled: enabled,
                onTap: () => _openSendSheet(context),
                outlined: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.card_giftcard_rounded,
                        color: StoreColors.lilacA, size: 17.sp),
                    6.wBox,
                    Text(
                      StringManager.send.tr(),
                      style: TextStyle(
                        color: StoreColors.lilacA,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            12.wBox,
            Expanded(
              flex: 3,
              child: StorePillButton(
                enabled: enabled,
                onTap: () => _showPurchaseDialog(context, selected!, type),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      StringManager.purchase.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (selected?.price != null) ...[
                      8.wBox,
                      Image.asset(AssetsManager.coinPayment,
                          width: 15.w, height: 15.w),
                      3.wBox,
                      Flexible(
                        child: Text(
                          '${selected!.price}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showPurchaseDialog(
    BuildContext context, MallEntity selected, MallOrBagType type) {
  final balance = di<MyStoreBloc>().state.myStore?.coins ?? 0;
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: .72),
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: 26.w),
        child: Container(
          padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 18.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            color: const Color(0xFF14121B),
            border: Border.all(
              color: StoreColors.lilac.withValues(alpha: .55),
            ),
            boxShadow: [
              BoxShadow(
                color: StoreColors.lilacB.withValues(alpha: .22),
                blurRadius: 28,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      StringManager.purchase.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(dialogContext),
                    child: Icon(Icons.close_rounded,
                        color: Colors.white70, size: 22.sp),
                  ),
                ],
              ),
              14.hBox,
              Container(
                width: 120.w,
                height: 120.w,
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.r),
                  color: Colors.white.withValues(alpha: .05),
                  border: Border.all(color: Colors.white.withValues(alpha: .08)),
                ),
                child: ImageViewWidget(
                  url: selected.image ?? '',
                  boxFit: BoxFit.contain,
                ),
              ),
              12.hBox,
              Text(
                selected.name ?? '',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              8.hBox,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(AssetsManager.coinPayment,
                      width: 20.w, height: 20.w),
                  5.wBox,
                  Text(
                    '${selected.price ?? 0}',
                    style: TextStyle(
                      color: StoreColors.gold,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if ((selected.expire ?? 0) > 0)
                    Text(
                      '  /  ${selected.expire} ${StringManager.days.tr()}',
                      style: TextStyle(color: Colors.white60, fontSize: 13.sp),
                    ),
                ],
              ),
              6.hBox,
              Text(
                '${StringManager.balance.tr()}: $balance',
                style: TextStyle(color: Colors.white54, fontSize: 12.sp),
              ),
              18.hBox,
              StorePillButton(
                enabled: true,
                onTap: () {
                  if (type == MallOrBagType.specialId) {
                    di<MallBuyBloc>().add(
                      BuyItemSpecialIdEvent(idItem: int.parse(selected.id!)),
                    );
                  } else {
                    di<MallBuyBloc>().add(BuyItemEvent(idItem: selected.id!));
                  }
                  Navigator.pop(dialogContext);
                },
                child: Center(
                  child: Text(
                    StringManager.purchase.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
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
