part of '../bag_page.dart';

class BagProductItem extends StatefulWidget {
  final MyBagEntity data;
  final MallOrBagType tabType;
  final bool isLoading;

  const BagProductItem({
    required this.data,
    required this.tabType,
    this.isLoading = false,
    super.key,
  });

  @override
  State<BagProductItem> createState() => BagProductItemState();
}

class BagProductItemState extends State<BagProductItem> {
  static const Color _cyan = Color(0xFF37E9FF);

  final ValueNotifier<double?> downloadProgress =
  ValueNotifier<double?>(null);

  Future<void> prepareAndOpenItem(
      BuildContext context,
      MyBagEntity data, {
        bool isShowTestScreen = true,
      }) async {
    if (downloadProgress.value != null) return;

    final param = TestMallBagParam(
      image: data.image,
      svg: data.svg,
      type: data.imageType,
      name: data.name,
    );
    final source = TestItemsController.sourceOf(param);

    if (await AssetPreviewPrefetch.cachedFile(source) == null &&
        source.isPlayable) {
      downloadProgress.value = 0.0;

      await AssetPreviewPrefetch.ensureCached(
        source,
        onProgress: (received, total) {
          if (mounted) {
            downloadProgress.value = received / total;
          }
        },
      );

      if (!mounted) return;
      downloadProgress.value = null;
    }

    if (!isShowTestScreen || !context.mounted) return;

    TestItemsController.instance.onMallCardTap(
      context,
      param,
      widget.tabType,
    );
  }

  @override
  void dispose() {
    downloadProgress.dispose();
    super.dispose();
  }

  MyBagEntity? _selectedForType(MyBagState state) {
    if (widget.tabType == MallOrBagType.bubble) {
      return state.selectedItemBubble;
    }
    if (widget.tabType == MallOrBagType.frame) {
      return state.selectedItemFrame;
    }
    if (widget.tabType == MallOrBagType.intro) {
      return state.selectedItemIntro;
    }
    if (widget.tabType == MallOrBagType.specialId) {
      return state.selectedItemSpecialId;
    }
    return state.selectedItemProfileFrame;
  }

  bool _selectionEnabled(MyBagState state) {
    if (widget.tabType == MallOrBagType.bubble) {
      return state.isBubbleNull != true;
    }
    if (widget.tabType == MallOrBagType.frame) {
      return state.isFrameNull != true;
    }
    if (widget.tabType == MallOrBagType.intro) {
      return state.isIntroNull != true;
    }
    if (widget.tabType == MallOrBagType.specialId) {
      return state.isSpecialIdNull != true;
    }
    return state.isProfileFrameNull != true;
  }

  int _typeIndex() {
    if (widget.tabType == MallOrBagType.bubble) return 0;
    if (widget.tabType == MallOrBagType.frame) return 1;
    if (widget.tabType == MallOrBagType.intro) return 2;
    if (widget.tabType == MallOrBagType.specialId) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyBagBloc, MyBagState>(
      bloc: di<MyBagBloc>(),
      buildWhen: (prev, curr) =>
      prev.selectedItemBubble != curr.selectedItemBubble ||
          prev.selectedItemFrame != curr.selectedItemFrame ||
          prev.selectedItemIntro != curr.selectedItemIntro ||
          prev.selectedItemSpecialId != curr.selectedItemSpecialId ||
          prev.selectedItemProfileFrame !=
              curr.selectedItemProfileFrame ||
          prev.isBubbleNull != curr.isBubbleNull ||
          prev.isFrameNull != curr.isFrameNull ||
          prev.isIntroNull != curr.isIntroNull ||
          prev.isSpecialIdNull != curr.isSpecialIdNull ||
          prev.isProfileFrameNull != curr.isProfileFrameNull,
      builder: (context, state) {
        final selected = _selectedForType(state);
        final isSelected = selected?.id == widget.data.id &&
            _selectionEnabled(state);

        return InkWell(
          onTap: () {
            di<MyBagBloc>().add(
              SelectBagItemEvent(
                selectedItem: widget.data,
                type: _typeIndex(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(17.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? const [
                  Color(0xFF4C2188),
                  Color(0xFF2A1852),
                  Color(0xFF1A1323),
                ]
                    : const [
                  Color(0xFF32205B),
                  Color(0xFF281A49),
                  Color(0xFF1B142B),
                ],
              ),
              border: Border.all(
                color: isSelected
                    ? _cyan
                    : const Color(0xFF7652B8)
                    .withValues(alpha: 0.62),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? _cyan.withValues(alpha: 0.18)
                      : Colors.black.withValues(alpha: 0.18),
                  blurRadius: isSelected ? 17.r : 11.r,
                  offset: Offset(0, 5.h),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      10.w,
                      9.h,
                      10.w,
                      11.h,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 7.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF65B3)
                                    .withValues(alpha: 0.13),
                                borderRadius:
                                BorderRadius.circular(12.r),
                              ),
                              child: TextWidget(
                                "${widget.data.expire ?? ''}",
                                isTranslate: false,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.bodySmall
                                    .size(10.5)
                                    .w600
                                    .colorExt(
                                  const Color(0xFFFF78BE),
                                ),
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => prepareAndOpenItem(
                                context,
                                widget.data,
                              ),
                              child: Container(
                                width: 32.w,
                                height: 32.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white
                                      .withValues(alpha: 0.13),
                                  border: Border.all(
                                    color: Colors.white
                                        .withValues(alpha: 0.10),
                                  ),
                                ),
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white
                                      .withValues(alpha: 0.84),
                                  size: 20.h,
                                ),
                              ),
                            ),
                          ],
                        ),
                        6.hBox,
                        Expanded(
                          child: Center(
                            child: ImageViewWidget(
                              url: widget.data.image ?? '',
                              width: 126.w,
                              height: 126.h,
                              boxFit: BoxFit.contain,
                            ),
                          ),
                        ),
                        7.hBox,
                        TextWidget(
                          widget.data.name ?? '',
                          isTranslate: false,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.bodyMedium
                              .size(13)
                              .bold
                              .colorExt(Colors.white),
                        ),
                      ],
                    ),
                  ),
                  ValueListenableBuilder<double?>(
                    valueListenable: downloadProgress,
                    builder: (context, progress, child) {
                      if (progress == null) {
                        return const SizedBox.shrink();
                      }

                      return Positioned.fill(
                        child: Container(
                          color:
                          Colors.black.withValues(alpha: 0.58),
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                          ),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor:
                            Colors.white.withValues(alpha: 0.16),
                            color: _cyan,
                            minHeight: 7.h,
                            borderRadius:
                            BorderRadius.circular(20.r),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
