part of '../bag_page.dart';

/// 3-column grid of owned items; tapping one puts it on the podium.
class _BagGrid extends StatelessWidget {
  const _BagGrid({
    required this.items,
    required this.shown,
    required this.onSelect,
    required this.onRefresh,
  });

  final List<MyBagEntity> items;
  final MyBagEntity? shown;
  final ValueChanged<MyBagEntity> onSelect;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: StoreColors.lilac,
      backgroundColor: const Color(0xFF1A1724),
      onRefresh: onRefresh,
      child: items.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: 50.h),
                Icon(Icons.backpack_outlined,
                    size: 54.sp, color: Colors.white.withValues(alpha: .25)),
                10.hBox,
                Center(
                  child: Text(
                    StringManager.noDataYet.tr(),
                    style: TextStyle(color: Colors.white54, fontSize: 13.sp),
                  ),
                ),
              ],
            )
          : GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 16.h),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: .74,
                mainAxisSpacing: 12.h,
                crossAxisSpacing: 10.w,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return BagProductItem(
                  data: item,
                  isSelected: shown?.id == item.id,
                  onTap: () => onSelect(item),
                ).storeEntrance(index);
              },
            ),
    );
  }
}

/// Send (outlined; only for items that can be gifted) + Use / Unuse.
class _BagBottomBar extends StatelessWidget {
  const _BagBottomBar({
    required this.item,
    required this.type,
    required this.category,
  });

  final MyBagEntity? item;
  final MallOrBagType type;

  /// 0 bubble, 1 frame, 2 entry, 3 special ID, 4 profile frame.
  final int category;

  String get _typeCode => switch (type) {
        MallOrBagType.frame => '1',
        MallOrBagType.bubble => '2',
        MallOrBagType.intro => '3',
        MallOrBagType.profileFrame => '28',
        _ => '4',
      };

  void _openSendSheet(BuildContext context, MyBagEntity it) {
    customModalBottomSheet(
      context,
      radius: 0,
      height: ScreenUtil().screenHeight,
      child: SendBottomSheet(selectedItem: it, isMall: false),
    );
  }

  /// Wear / take off the item (same requests as before).
  void _toggleUse(MyBagEntity it) {
    final isUsed = it.isUsed;
    if (type == MallOrBagType.specialId) {
      di<MyBagBloc>().add(
        SelectBagItemEvent(selectedItem: isUsed ? null : it, type: category),
      );
      di<UseUnUseBloc>().add(
        UseUnUseSpecialIdEvent(
          param: UseUnUseBagItemParam(
            itemId: it.id.toString(),
            isUsed: !isUsed,
          ),
          tabType: type,
        ),
      );
      return;
    }
    if (isUsed) {
      di<UseUnUseBloc>().add(
        UnUseEvent(
          param: UseUnUseBagItemParam(itemId: it.id.toString(), type: _typeCode),
          tabType: type,
        ),
      );
      di<MyBagBloc>().add(SelectBagItemEvent(selectedItem: null, type: category));
    } else {
      di<UseUnUseBloc>().add(
        UseEvent(
          param: UseUnUseBagItemParam(itemId: it.id.toString(), type: _typeCode),
          tabType: type,
        ),
      );
      di<MyBagBloc>().add(SelectBagItemEvent(selectedItem: it, type: category));
    }
  }

  @override
  Widget build(BuildContext context) {
    final it = item;
    final canSend = it != null && it.using == 0;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 10.h),
        child: Row(
          children: [
            if (canSend) ...[
              Expanded(
                flex: 2,
                child: StorePillButton(
                  enabled: true,
                  outlined: true,
                  onTap: () => _openSendSheet(context, it),
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
            ],
            Expanded(
              flex: 3,
              child: StorePillButton(
                enabled: it != null,
                onTap: () => _toggleUse(it!),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      (it?.isUsed ?? false)
                          ? StringManager.unUse.tr()
                          : StringManager.use.tr(),
                      key: ValueKey(it?.isUsed),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
