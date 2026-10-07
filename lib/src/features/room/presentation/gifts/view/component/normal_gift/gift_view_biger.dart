import 'dart:io';
import 'package:general/src/core/cache/alpha_cache_manager.dart';
import 'package:general/src/core/cache/svga_cache_manager.dart';
import 'package:general/src/core/cache/vap_cache_manager.dart';
import 'package:general/src/core/cache/video_cache_manager.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/gifts/gift.dart';
import 'package:general/src/features/room/room.dart';

class PageViewGiftWidget<T extends GiftsEntity> extends StatefulWidget {
  final List<T> data;
  final RequestState state;
  final TypeGift giftType;
  final String message;
  final String userCoins;
  final MyDataModel myData;
  final int? categoryId;
  final double gridPaddingTop;
  final Color? cardBackgroundColor;
  final Color selectedBorderColor;
  final Color normalPriceColor;
  final Color selectedPriceColor;
  final bool enableAnimation;
  final bool showDownloadProgress;
  final bool showMusicIcon;
  final TabController? tabController;

  const PageViewGiftWidget({
    super.key,
    required this.myData,
    required this.data,
    required this.giftType,
    required this.userCoins,
    required this.state,
    required this.message,
    this.categoryId,
    required this.gridPaddingTop,
    this.cardBackgroundColor,
    required this.selectedBorderColor,
    required this.normalPriceColor,
    required this.selectedPriceColor,
    required this.enableAnimation,
    required this.showDownloadProgress,
    required this.showMusicIcon,
    this.tabController,
  });

  @override
  State<PageViewGiftWidget<T>> createState() => _PageViewGiftWidgetState<T>();
}

class _PageViewGiftWidgetState<T extends GiftsEntity>
    extends State<PageViewGiftWidget<T>> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.state) {
      case RequestState.loaded:
        return _buildGiftGrid(context);
      case RequestState.loading:
        return const Center(child: LoadingView());
      case RequestState.idle:
        return const SizedBox();
      default:
        return const ErrorView();
    }
  }

  Widget _buildGiftGrid(BuildContext context) {
    // For non-Vibe app: keep original vertical scrolling
    return Padding(
      padding: context.paddingOnly(
          start: 10, end: 10, top: widget.gridPaddingTop, bottom: 10),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 0.745,
          crossAxisCount: 4,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
        ),
        itemCount: widget.data.length,
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final gift = widget.data[index];
          final isBagItem = widget.giftType == TypeGift.bag;

          return GiftCard(
            gift: gift,
            index: index,
            myDataModel: widget.myData,
            isBagItem: isBagItem,
            isVipGift: widget.giftType == TypeGift.vip,
            categoryId: widget.categoryId,
            cardBackgroundColor: widget.cardBackgroundColor,
            selectedBorderColor: widget.selectedBorderColor,
            normalPriceColor: widget.normalPriceColor,
            selectedPriceColor: widget.selectedPriceColor,
            enableAnimation: widget.enableAnimation,
            showDownloadProgress: widget.showDownloadProgress,
            showMusicIcon: widget.showMusicIcon,
          );
        },
      ),
    );
  }
}

class GiftCard extends StatefulWidget {
  final GiftsEntity gift;
  final int index;
  final MyDataModel myDataModel;
  final bool isBagItem;
  final bool isVipGift;
  final int? categoryId;
  final Color? cardBackgroundColor;
  final Color selectedBorderColor;
  final Color normalPriceColor;
  final Color selectedPriceColor;
  final bool enableAnimation;
  final bool showDownloadProgress;
  final bool showMusicIcon;

  const GiftCard({
    super.key,
    required this.gift,
    required this.index,
    required this.myDataModel,
    this.isBagItem = false,
    this.isVipGift = false,
    this.categoryId,
    this.cardBackgroundColor,
    required this.selectedBorderColor,
    required this.normalPriceColor,
    required this.selectedPriceColor,
    required this.enableAnimation,
    required this.showDownloadProgress,
    required this.showMusicIcon,
  });

  @override
  State<GiftCard> createState() => _GiftCardState();
}

class _GiftCardState extends State<GiftCard>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<double?> downloadProgress = ValueNotifier<double?>(null);
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15, // 👈 grows bigger
    ).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );

    // Check if this gift is already selected on init (auto-selection case)
    if (widget.enableAnimation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final currentState = di<GiftBloc>().state;
        final isSelected = currentState.numOfGift == widget.index &&
            currentState.selectedCategoryId == widget.categoryId;
        if (isSelected) {
          _scaleController.repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _handleGiftTap(BuildContext context, GiftState state) async {
    if (GiftBottomBar.typeCandy.value == TypeCandy.non) {
      final isCurrentlySelected = state.numOfGift == widget.index &&
          state.selectedCategoryId == widget.categoryId;
      if (isCurrentlySelected) {
        GiftScreen.chosenGift = null;
        di<GiftBloc>().add(
          const ChangeGiftDataEvent(
              numOfGift: -1, giftId: -1, giftPrice: -1, categoryId: -1),
        );
      } else {
        GiftScreen.chosenGift = widget.gift;
        di<GiftBloc>().add(
          ChangeGiftDataEvent(
            numOfGift: widget.index,
            giftId: widget.gift.id,
            giftPrice: widget.gift.price,
            categoryId: widget.categoryId,
          ),
        );
      }
    }

    if (downloadProgress.value != null) return;

    // `show_img` is only the lightweight card preview.
    // `img` is the actual animation asset to preload/send.
    // Direct cache downloads require a full fetchable URL.
    final giftUrl = EndPoints.getImage(widget.gift.img);
    final isSvga = widget.gift.giftType == 'svga';
    final isMp4 = widget.gift.giftType == 'mp4';
    final isVap = widget.gift.giftType == 'vap';
    final isAlpha = widget.gift.giftType == 'alpha';

    // Keep selection instant. Only cache real animation formats.
    if (giftUrl.trim().isEmpty ||
        (!isSvga && !isMp4 && !isVap && !isAlpha)) {
      return;
    }

    File? cachedFile;
    if (isSvga) {
      cachedFile = await SVGAAssetCacheManager().isExistFile(giftUrl);
    } else if (isMp4) {
      cachedFile = await VideoAssetCacheManager().isExistFile(giftUrl);
    } else if (isVap) {
      cachedFile = await VapAssetCacheManager().isExistFile(giftUrl);
    } else if (isAlpha) {
      cachedFile = await AlphaAssetCacheManager().isExistFile(giftUrl);
    }

    if (cachedFile == null) {
      downloadProgress.value = 0.0;
      di<GiftBloc>().add(const SetGiftDownloadingEvent(isDownloading: true));

      void callback(int received, int total) {
        if (total != -1) {
          downloadProgress.value = received / total;
        }
      }

      if (isSvga) {
        await SVGAAssetCacheManager().downloadWithProgress(
          EndPoints.getImage(giftUrl),
          onReceiveProgress: callback,
        );
      } else if (isMp4) {
        await VideoAssetCacheManager().downloadWithProgress(
          EndPoints.getImage(giftUrl),
          onReceiveProgress: callback,
        );
      } else if (isVap) {
        await VapAssetCacheManager().downloadWithProgress(
          EndPoints.getImage(giftUrl),
          onReceiveProgress: callback,
        );
      } else if (isAlpha) {
        await AlphaAssetCacheManager().downloadWithProgress(
          EndPoints.getImage(giftUrl),
          onReceiveProgress: callback,
        );
      }

      downloadProgress.value = null;
      di<GiftBloc>().add(const SetGiftDownloadingEvent(isDownloading: false));
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GiftBloc, GiftState>(
      bloc: di<GiftBloc>(),
      listenWhen: (prev, curr) =>
      prev.numOfGift != curr.numOfGift ||
          prev.selectedCategoryId != curr.selectedCategoryId,
      listener: (_, state) {
        if (widget.enableAnimation) {
          final isSelected = state.numOfGift == widget.index &&
              state.selectedCategoryId == widget.categoryId;

          if (isSelected) {
            _scaleController.repeat(reverse: true);
          } else {
            _scaleController.stop();
            _scaleController.value = 1.0;
          }
        }
      },
      builder: (context, state) {
        final isSelected = state.numOfGift == widget.index &&
            state.selectedCategoryId == widget.categoryId;

        return InkWell(
          onTap: () => _handleGiftTap(context, state),
          child: Container(
            padding: context.paddingZero(),
            decoration: BoxDecoration(
              borderRadius: 5.radius,
              color: widget.cardBackgroundColor,
              border: Border.all(
                color: isSelected
                    ? widget.selectedBorderColor
                    : ColorManager.transparent,
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      4.0.hBox,
                      _buildImage(),
                      12.hBox,
                      _buildName(context),
                      if (widget.isBagItem) _buildExpiry(context),
                      if (widget.isBagItem) 0.5.hBox,
                      if (!widget.isBagItem) _buildPrice(context, isSelected),
                      if (widget.isBagItem) _buildQuantity(context),
                      4.0.hBox,
                    ],
                  ),
                ),
                if (widget.showDownloadProgress)
                  ValueListenableBuilder<double?>(
                    valueListenable: downloadProgress,
                    builder: (_, value, __) {
                      if (value == null) return const SizedBox.shrink();

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: 15.radius,
                        ),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: LinearProgressIndicator(
                              value: value,
                              backgroundColor: const Color(0x73000000),
                              color: ColorManager.white,
                              minHeight: 7.h,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                if (widget.gift.isMusic == 1 && widget.showMusicIcon)
                  Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: context.paddingAll(2),
                        decoration: BoxDecoration(
                            color: ColorManager.pink, borderRadius: 2.radius),
                        child: Image.asset(
                          AssetsManager.musicIcon,
                          scale: 1.8,
                        ),
                      ))
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImage() {
    return Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ClipRRect(
          borderRadius: 10.radius,
          child: ImageViewWidget(
            boxFit: BoxFit.contain,
            // Card/grid must always show the static `show_img` preview.
            url: (widget.gift.showImg?.trim().isNotEmpty ?? false)
                ? widget.gift.showImg!
                : (widget.gift.img ?? ''),
            height: 60.h,
            width: 60.w,
          ),
        ),
      ),
    );
  }

  Widget _buildName(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 5.w, maxWidth: 60.w),
      child: AutoScrollText(
        text: widget.gift.name ?? '',
        style: context.bodyMedium.size(10).w400.colorExt(ColorManager.white),
        textAlign: TextAlign.center,
        velocity: 30.0,
        pauseDuration: const Duration(milliseconds: 1500),
      ),
    );
  }

  Widget _buildPrice(BuildContext context, bool isSelected) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AssetsManager.coinPayment,
            scale: 7.5,
          ),
          6.wBox,
          FittedBox(
            child: Text(
              widget.gift.price?.toString() ?? '',
              style: context.bodyMedium
                  .size(9)
                  .colorExt(isSelected
                  ? widget.selectedPriceColor
                  : widget.normalPriceColor)
                  .w400
                  .copyWith(height: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiry(BuildContext context) {
    return Container(
      padding: context.paddingSymmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        color: ColorManager.primary,
        borderRadius: 50.radius,
      ),
      child: TextWidget(
        "Expires in: ${widget.gift.expiry ?? 0}",
        style: context.bodySmall.colorExt(ColorManager.textPrimary).size(8),
        maxLines: 2,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildQuantity(BuildContext context) {
    return Container(
      padding: context.paddingSymmetric(horizontal: 5.0, vertical: 1.0),
      child: TextWidget(
        "x ${widget.gift.quantity ?? 0}",
        style: context.bodySmall.colorExt(ColorManager.textPrimary).size(10),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}
