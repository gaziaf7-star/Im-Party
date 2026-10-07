part of '../mall_page.dart';

class _MallProductItem extends StatefulWidget {
  final MallEntity data;
  final MallOrBagType tabType;
  final bool isLoading;
  final bool isSelected;

  const _MallProductItem({
    required this.data,
    required this.tabType,
    this.isLoading = false,
    this.isSelected = false,
  });

  @override
  State<_MallProductItem> createState() => _MallProductItemState();
}

class _MallProductItemState extends State<_MallProductItem> {
  static const Color _cyan = Color(0xFF37E9FF);
  double? _downloadProgress;

  @override
  Widget build(BuildContext context) {
    final days = widget.data.expire ?? 0;
    final price = widget.data.price ?? 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 190),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isSelected
              ? const [
            Color(0xFF4C2188),
            Color(0xFF2A1852),
            Color(0xFF1A1323),
          ]
              : const [
            Color(0xFF342067),
            Color(0xFF251943),
            Color(0xFF18121F),
          ],
        ),
        border: Border.all(
          color: widget.isSelected
              ? _cyan
              : const Color(0xFF67538F).withValues(alpha: 0.56),
          width: widget.isSelected ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isSelected
                ? _cyan.withValues(alpha: 0.18)
                : Colors.black.withValues(alpha: 0.20),
            blurRadius: widget.isSelected ? 18.r : 10.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          children: [
            Positioned(
              top: -26.h,
              right: -24.w,
              child: Container(
                width: 90.w,
                height: 90.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8A48FF)
                          .withValues(alpha: 0.22),
                      blurRadius: 42.r,
                      spreadRadius: 7.r,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                10.w,
                10.h,
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
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_activity_rounded,
                              size: 13.h,
                              color: const Color(0xFFFF78BE),
                            ),
                            4.wBox,
                            TextWidget(
                              '$days',
                              isTranslate: false,
                              style: context.bodySmall
                                  .size(10.5)
                                  .w600
                                  .colorExt(const Color(0xFFFF78BE)),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _handleItemView(
                          context,
                          widget.data,
                        ),
                        child: Container(
                          width: 32.w,
                          height: 32.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.13),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.10),
                            ),
                          ),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white.withValues(alpha: 0.82),
                            size: 20.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                  8.hBox,
                  Expanded(
                    child: Center(
                      child: AnimatedScale(
                        scale: widget.isSelected ? 1.04 : 1.0,
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        child: ImageViewWidget(
                          url: widget.data.image ?? '',
                          width: 125.w,
                          height: 125.h,
                          boxFit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  6.hBox,
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
                  8.hBox,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        AssetsManager.coinPayment,
                        width: 21.w,
                        height: 21.w,
                      ),
                      5.wBox,
                      Flexible(
                        child: TextWidget(
                          price.toString(),
                          isTranslate: false,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.bodyLarge
                              .size(16)
                              .bold
                              .colorExt(const Color(0xFFFFEA33)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_downloadProgress != null)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.58),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: LinearProgressIndicator(
                      value: _downloadProgress,
                      backgroundColor: Colors.white.withValues(alpha: 0.16),
                      color: _cyan,
                      minHeight: 7.h,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleItemView(BuildContext context, MallEntity data) async {
    if (_downloadProgress != null) return;

    final param = TestMallBagParam(
      image: data.image,
      svg: data.svg,
      type: data.imageType,
      name: data.name,
    );
    final source = TestItemsController.sourceOf(param);

    if (await AssetPreviewPrefetch.cachedFile(source) == null &&
        source.isPlayable) {
      if (!mounted) return;
      setState(() => _downloadProgress = 0.0);

      await AssetPreviewPrefetch.ensureCached(
        source,
        onProgress: (received, total) {
          if (mounted) {
            setState(() => _downloadProgress = received / total);
          }
        },
      );

      if (!mounted) return;
      setState(() => _downloadProgress = null);
    }

    if (!context.mounted) return;

    TestItemsController.instance.onMallCardTap(
      context,
      param,
      widget.tabType,
    );
  }
}
