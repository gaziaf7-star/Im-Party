part of '../mall_page.dart';

class _MallTabBarView extends StatefulWidget {
  final List<MallEntity> mall;
  final MallOrBagType tabType;
  final bool isLoading;

  const _MallTabBarView({
    required this.mall,
    required this.tabType,
    this.isLoading = false,
  });

  @override
  State<_MallTabBarView> createState() => _MallTabBarViewState();
}

class _MallTabBarViewState extends State<_MallTabBarView> {
  static const Color _pageBg = Color(0xFF170F1A);
  static const Color _barBg = Color(0xFF241064);
  static const Color _cyan = Color(0xFF39E9FF);

  @override
  void initState() {
    if (widget.mall.isNotEmpty) {
      di<MallBloc>().add(
        SelectMallItemEvent(selectedItem: widget.mall.first),
      );
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _MallTabBarView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.mall.isEmpty &&
        widget.mall.isNotEmpty &&
        di<MallBloc>().state.selectedItem?.id == null) {
      di<MallBloc>().add(
        SelectMallItemEvent(selectedItem: widget.mall.first),
      );
    }
  }

  Future<void> _refresh() async {
    if (widget.tabType == MallOrBagType.bubble) {
      di<MallBloc>().add(const GetBubbleMallEvent());
    } else if (widget.tabType == MallOrBagType.frame) {
      di<MallBloc>().add(const GetFramesMallEvent());
    } else if (widget.tabType == MallOrBagType.intro) {
      di<MallBloc>().add(const GetCarMallEvent());
    } else if (widget.tabType == MallOrBagType.specialId) {
      di<MallBloc>().add(const GetSpecialIdMallEvent());
    } else if (widget.tabType == MallOrBagType.profileFrame) {
      di<MallBloc>().add(const GetProfileFramesMallEvent());
    }

    await Future<void>.delayed(const Duration(milliseconds: 350));
  }

  void _openSendSheet(BuildContext context) {
    final selected = di<MallBloc>().state.selectedItem;
    if (selected == null || selected.id == null) return;

    customModalBottomSheet(
      context,
      radius: 0,
      height: ScreenUtil().screenHeight,
      child: SendBottomSheet(
        isMall: true,
        selectedItemMall: selected,
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context) {
    final selected = di<MallBloc>().state.selectedItem;
    if (selected == null || selected.id == null) return;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.70),
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 17.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF240C65),
                  Color(0xFF37108D),
                  Color(0xFF1B0A56),
                ],
              ),
              border: Border.all(
                color: const Color(0xFF7D55EB).withValues(alpha: 0.65),
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F20CA).withValues(alpha: 0.32),
                  blurRadius: 28.r,
                  offset: Offset(0, 10.h),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextWidget(
                        StringManager.purchase.tr(),
                        style: context.bodyLarge
                            .size(18)
                            .bold
                            .colorExt(Colors.white),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(dialogContext),
                      child: Container(
                        width: 34.w,
                        height: 34.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 19.h,
                        ),
                      ),
                    ),
                  ],
                ),
                13.hBox,
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(11.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 82.w,
                        height: 82.w,
                        padding: EdgeInsets.all(5.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14.r),
                          color: Colors.black.withValues(alpha: 0.13),
                        ),
                        child: ImageViewWidget(
                          url: selected.image ?? '',
                          width: 72.w,
                          height: 72.w,
                          boxFit: BoxFit.contain,
                        ),
                      ),
                      12.wBox,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget(
                              selected.name ?? '',
                              isTranslate: false,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.bodyMedium
                                  .size(15)
                                  .bold
                                  .colorExt(Colors.white),
                            ),
                            10.hBox,
                            Row(
                              children: [
                                Image.asset(
                                  AssetsManager.coinPayment,
                                  width: 23.w,
                                  height: 23.w,
                                ),
                                6.wBox,
                                Flexible(
                                  child: TextWidget(
                                    (selected.price ?? 0).toString(),
                                    isTranslate: false,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.bodyLarge
                                        .size(18)
                                        .bold
                                        .colorExt(
                                      const Color(0xFFFFEA39),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                14.hBox,
                TextWidget(
                  "${StringManager.youWillBuy.tr()} ${selected.name ?? ''}",
                  isTranslate: false,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.bodySmall
                      .size(12)
                      .colorExt(
                    Colors.white.withValues(alpha: 0.76),
                  ),
                ),
                16.hBox,
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (widget.tabType == MallOrBagType.specialId) {
                        di<MallBuyBloc>().add(
                          BuyItemSpecialIdEvent(
                            idItem: int.parse(selected.id!),
                          ),
                        );
                      } else {
                        di<MallBuyBloc>().add(
                          BuyItemEvent(idItem: selected.id!),
                        );
                      }
                      Navigator.pop(dialogContext);
                    },
                    borderRadius: BorderRadius.circular(25.r),
                    child: Ink(
                      width: double.infinity,
                      height: 48.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.r),
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFF8E2BFF),
                            Color(0xFF503CFF),
                            Color(0xFF29D7FF),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.72),
                          width: 1.1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF39E9FF)
                                .withValues(alpha: 0.24),
                            blurRadius: 14.r,
                          ),
                        ],
                      ),
                      child: Center(
                        child: TextWidget(
                          StringManager.purchase.tr(),
                          style: context.bodyMedium
                              .size(15)
                              .bold
                              .colorExt(Colors.white),
                        ),
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

  @override
  Widget build(BuildContext context) {
    final selected = di<MallBloc>().state.selectedItem;

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/icons/Mall bgoImage.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            filterQuality: FilterQuality.high,
          ),
        ),
        Positioned.fill(
          child: Container(
            color: const Color(0xFF100914).withValues(alpha: 0.58),
          ),
        ),
        Column(
          children: [
            Expanded(
              child: RefreshIndicatorWidget(
                onRefresh: _refresh,
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    12.w,
                    MediaQuery.of(context).padding.top + kToolbarHeight - 30.h,
                    12.w,
                    16.h,
                  ),
                  itemCount: widget.mall.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.82,
                    mainAxisSpacing: 12.h,
                    crossAxisSpacing: 12.w,
                  ),
                  itemBuilder: (context, index) {
                    final item = widget.mall[index];
                    final isSelected = selected?.id == item.id;

                    return InkWell(
                      borderRadius: BorderRadius.circular(17.r),
                      onTap: () {
                        di<MallBloc>().add(
                          SelectMallItemEvent(selectedItem: item),
                        );
                      },
                      child: _MallProductItem(
                        data: item,
                        tabType: widget.tabType,
                        isLoading: widget.isLoading,
                        isSelected: isSelected,
                      ),
                    );
                  },
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  17.w,
                  12.h,
                  14.w,
                  12.h,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF240C65),
                      Color(0xFF37108D),
                      Color(0xFF1B0A56),
                    ],
                  ),
                  border: Border(
                    top: BorderSide(
                      color: const Color(0xFF7446E8).withValues(alpha: 0.45),
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F20CA).withValues(alpha: 0.26),
                      blurRadius: 24.r,
                      offset: Offset(0, -6.h),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Image.asset(
                      AssetsManager.coinPayment,
                      width: 27.w,
                      height: 27.w,
                    ),
                    7.wBox,
                    Expanded(
                      child: TextWidget(
                        (di<MyStoreBloc>().state.myStore?.coins ?? 0).toString(),
                        isTranslate: false,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.bodyLarge
                            .size(18)
                            .bold
                            .colorExt(const Color(0xFFFFEA39)),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: selected?.id == null
                            ? null
                            : () => _openSendSheet(context),
                        borderRadius: BorderRadius.circular(16.r),
                        child: Ink(
                          width: 43.w,
                          height: 43.w,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20.h,
                          ),
                        ),
                      ),
                    ),
                    10.wBox,
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: selected?.id == null
                            ? null
                            : () => _showPurchaseDialog(context),
                        borderRadius: BorderRadius.circular(24.r),
                        child: Ink(
                          width: 145.w,
                          height: 45.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24.r),
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(0xFF8E2BFF),
                                Color(0xFF503CFF),
                                Color(0xFF29D7FF),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.70),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _cyan.withValues(alpha: 0.30),
                                blurRadius: 16.r,
                              ),
                            ],
                          ),
                          child: Center(
                            child: TextWidget(
                              StringManager.purchase.tr(),
                              style: context.bodyMedium
                                  .size(15)
                                  .bold
                                  .colorExt(Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
