part of '../bag_page.dart';

class BagTabBarView extends StatelessWidget {
  final List<MyBagEntity> bagList;
  final MyBagEntity? selectedItem;
  final bool isLoading;
  final MallOrBagType tabType;

  const BagTabBarView({
    required this.bagList,
    required this.selectedItem,
    required this.tabType,
    super.key,
    this.isLoading = false,
  });

  Future<void> _refresh() async {
    if (tabType == MallOrBagType.bubble) {
      di<MyBagBloc>().add(const GetBubbleBackPackMyBagEvent());
    } else if (tabType == MallOrBagType.frame) {
      di<MyBagBloc>().add(const GetFramesMyBagEvent());
    } else if (tabType == MallOrBagType.intro) {
      di<MyBagBloc>().add(const GetEntrieMyBagEvent());
    } else if (tabType == MallOrBagType.specialId) {
      di<MyBagBloc>().add(const GetSpecialIdMyBagEvent());
    } else if (tabType == MallOrBagType.profileFrame) {
      di<MyBagBloc>().add(const GetProfileFrameMyBagEvent());
    }

    await Future<void>.delayed(
      const Duration(milliseconds: 350),
    );
  }

  int _eventType() {
    if (tabType == MallOrBagType.bubble) return 0;
    if (tabType == MallOrBagType.frame) return 1;
    if (tabType == MallOrBagType.intro) return 2;
    if (tabType == MallOrBagType.specialId) return 3;
    return 4;
  }

  String _typeCode() {
    if (tabType == MallOrBagType.frame) return '1';
    if (tabType == MallOrBagType.bubble) return '2';
    if (tabType == MallOrBagType.intro) return '3';
    if (tabType == MallOrBagType.profileFrame) return '28';
    return '4';
  }

  void _openSendSheet(BuildContext context, MyBagEntity item) {
    customModalBottomSheet(
      context,
      radius: 0,
      height: ScreenUtil().screenHeight,
      child: SendBottomSheet(
        selectedItem: item,
        isMall: false,
      ),
    );
  }

  void _toggleUse(BuildContext context, MyBagEntity item) {
    final isUsed = item.isUsed;
    final eventType = _eventType();
    final typeCode = _typeCode();

    if (tabType == MallOrBagType.specialId) {
      di<MyBagBloc>().add(
        SelectBagItemEvent(
          selectedItem: isUsed ? null : item,
          type: eventType,
        ),
      );

      di<UseUnUseBloc>().add(
        UseUnUseSpecialIdEvent(
          param: UseUnUseBagItemParam(
            itemId: item.id.toString(),
            isUsed: !isUsed,
          ),
          tabType: tabType,
        ),
      );
      return;
    }

    if (isUsed) {
      di<UseUnUseBloc>().add(
        UnUseEvent(
          param: UseUnUseBagItemParam(
            itemId: item.id.toString(),
            type: typeCode,
          ),
          tabType: tabType,
        ),
      );

      di<MyBagBloc>().add(
        SelectBagItemEvent(
          selectedItem: null,
          type: eventType,
        ),
      );
    } else {
      di<UseUnUseBloc>().add(
        UseEvent(
          param: UseUnUseBagItemParam(
            itemId: item.id.toString(),
            type: typeCode,
          ),
          tabType: tabType,
        ),
      );

      di<MyBagBloc>().add(
        SelectBagItemEvent(
          selectedItem: item,
          type: eventType,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding =
        MediaQuery.of(context).padding.top + kToolbarHeight - 30.h;

    return Column(
      children: [
        Expanded(
          child: RefreshIndicatorWidget(
            onRefresh: _refresh,
            child: bagList.isEmpty && !isLoading
                ? ListView(
              physics:
              const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(top: topPadding),
              children: [
                SizedBox(height: 90.h),
                Icon(
                  Icons.backpack_outlined,
                  size: 60.h,
                  color: Colors.white.withValues(alpha: 0.30),
                ),
              ],
            )
                : GridView.builder(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                12.w,
                topPadding,
                12.w,
                16.h,
              ),
              itemCount:
              isLoading && bagList.isEmpty ? 6 : bagList.length,
              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.82,
                mainAxisSpacing: 10.h,
                crossAxisSpacing: 10.w,
              ),
              itemBuilder: (context, index) {
                if (bagList.isEmpty) {
                  return Skeletonizer(
                    enabled: true,
                    child: BagProductItem(
                      data: const MyBagEntity(
                        isUsed: false,
                        use: false,
                      ),
                      tabType: tabType,
                    ),
                  );
                }

                return Skeletonizer(
                  enabled: isLoading,
                  child: BagProductItem(
                    data: bagList[index],
                    tabType: tabType,
                  ),
                );
              },
            ),
          ),
        ),
        if (selectedItem != null)
          SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                15.w,
                11.h,
                15.w,
                11.h,
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
                    color: const Color(0xFF7446E8)
                        .withValues(alpha: 0.45),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F20CA)
                        .withValues(alpha: 0.25),
                    blurRadius: 22.r,
                    offset: Offset(0, -5.h),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextWidget(
                      selectedItem!.name ?? '',
                      isTranslate: false,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.bodyMedium
                          .size(14)
                          .bold
                          .colorExt(Colors.white),
                    ),
                  ),
                  if (selectedItem!.using == 0) ...[
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () =>
                            _openSendSheet(context, selectedItem!),
                        borderRadius: BorderRadius.circular(22.r),
                        child: Ink(
                          height: 42.h,
                          padding:
                          EdgeInsets.symmetric(horizontal: 18.w),
                          decoration: BoxDecoration(
                            borderRadius:
                            BorderRadius.circular(22.r),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF8E2BFF),
                                Color(0xFFFF39D7),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white
                                  .withValues(alpha: 0.42),
                            ),
                          ),
                          child: Center(
                            child: TextWidget(
                              StringManager.send.tr(),
                              style: context.bodyMedium
                                  .size(13)
                                  .bold
                                  .colorExt(Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    8.wBox,
                  ],
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () =>
                          _toggleUse(context, selectedItem!),
                      borderRadius: BorderRadius.circular(22.r),
                      child: Ink(
                        height: 42.h,
                        padding:
                        EdgeInsets.symmetric(horizontal: 22.w),
                        decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(22.r),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF5B3CFF),
                              Color(0xFF29D7FF),
                            ],
                          ),
                          border: Border.all(
                            color:
                            Colors.white.withValues(alpha: 0.60),
                          ),
                        ),
                        child: Center(
                          child: TextWidget(
                            selectedItem!.isUsed
                                ? StringManager.unUse.tr()
                                : StringManager.use.tr(),
                            style: context.bodyMedium
                                .size(13)
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
    );
  }
}

