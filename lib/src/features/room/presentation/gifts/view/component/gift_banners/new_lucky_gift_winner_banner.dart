import 'dart:io';
import 'dart:ui' as ui;
import 'package:general/src/core/cache/image_cache_manager.dart';
import 'package:general/src/core/cache/svga_movie_cache.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/banners_bloc/banners_bloc.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/banners_bloc/banners_event.dart';
import 'package:flutter_svga/flutter_svga.dart';

class NewLuckyGiftWinnerBanner extends StatefulWidget {
  final Map<String, dynamic> data;

  const NewLuckyGiftWinnerBanner({
    super.key,
    required this.data,
  });

  @override
  State<NewLuckyGiftWinnerBanner> createState() =>
      _NewLuckyGiftWinnerBannerState();
}

class _NewLuckyGiftWinnerBannerState extends State<NewLuckyGiftWinnerBanner>
    with SingleTickerProviderStateMixin {
  late SVGAAnimationController animationController;
  final AssetCacheManager _assetCacheManager = AssetCacheManager();

  @override
  void initState() {
    animationController = SVGAAnimationController(vsync: this);
    _getAnimation();
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void _getAnimation() async {
    final bannerImage = getBannerImage();

    // Asset failed to resolve/load: NEVER just return — this banner sits at
    // userBannerData[0], and only the animation's whenComplete advances the
    // queue, so a silent return froze EVERY later banner for the whole
    // session (owner report 2026-06-12: x5..x100 wins rendered nothing and
    // blocked the queue). Skip this entry and let the next one show.
    if (bannerImage.isEmpty) {
      _skipAndAdvanceQueue();
      return;
    }

    final videoItem = await SvgaMovieCache.instance.loadFromAsset(bannerImage);

    if (!mounted) return;
    if (videoItem == null) {
      _skipAndAdvanceQueue();
      return;
    }

    animationController.videoItem = videoItem;

    if (widget.data['speed'] == "fast") {
      animationController.duration = const Duration(seconds: 2);
    }

    animationController.videoItem?.dynamicItem.setText(
      TextPainter(
        text: TextSpan(
          children: [
            TextSpan(
              text:
                  "${widget.data["uName"] ?? ""} ${StringManager.win.tr()} \n",
              style: TextStyle(
                color: ColorManager.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: "${widget.data["per"] ?? ""}",
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 20.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: " ${StringManager.coin.tr()}",
              style: TextStyle(
                color: ColorManager.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      "test",
    );

    final String senderImage =
        await _loadCachedOrRemoteAsset(widget.data["uImg"] ?? "");

    if (!mounted) return;

    if (senderImage.isEmpty) {
      try {
        await animationController.videoItem?.dynamicItem.setImageWithUrl(
          EndPoints.getImage(widget.data["uImg"] ?? ""),
          "Avatar",
        );
      } catch (e) {
        debugPrint('Error loading avatar image: $e');
      }
    } else {
      try {
        final File imageFile = File(senderImage);
        final Uint8List imageBytes = await imageFile.readAsBytes();

        if (!mounted) return;

        final ui.Image image =
            await decodeImageFromList(imageBytes.buffer.asUint8List());

        if (!mounted) return;

        animationController.videoItem?.dynamicItem.setImage(image, "Avatar");
      } catch (e) {
        debugPrint('Error decoding image: $e');
      }
    }

    if (!mounted) return;

    // Final safety check before calling forward()
    if (animationController.videoItem == null) {
      _skipAndAdvanceQueue();
      return;
    }

    animationController.forward().whenComplete(() {
      if (!mounted) return;

      animationController.clear();
      di<ShowBannersBloc>().add(const ShowBannerInAppEvent(bannerData: {}));

      if (GiftController().userBannerData.isNotEmpty) {
        GiftController().userBannerData.removeAt(0);
      }
      // Single owner of queue advancement: clears the in-flight flag and pulls
      // the next banner (or idles). The 300ms gap lets the cleared overlay
      // settle before the next banner's host widget mounts.
      Future.delayed(
        const Duration(milliseconds: 300),
        () => GiftController().advanceQueue(),
      );
    });
  }

  /// Mirrors the whenComplete teardown for entries that can't render: drop
  /// the head of the queue and advance to the next banner.
  void _skipAndAdvanceQueue() {
    di<ShowBannersBloc>().add(const ShowBannerInAppEvent(bannerData: {}));
    if (GiftController().userBannerData.isNotEmpty) {
      GiftController().userBannerData.removeAt(0);
    }
    Future.delayed(
      const Duration(milliseconds: 300),
      () => GiftController().advanceQueue(),
    );
  }

  Future<String> _loadCachedOrRemoteAsset(String path) async {
    File? assetFile;
    try {
      assetFile = await _assetCacheManager.getCachedAsset(
        path,
      );
      if (assetFile != null) {
        path = assetFile.path;
      }
    } catch (error) {
      Methods.printLog("failed_to_load_asset");
    }
    return assetFile?.path ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ScreenUtil().screenWidth,
      height: 100.h,
      child: SVGAImage(
        animationController,
        fit: BoxFit.contain,
      ),
    );
  }

  String getBannerImage() {
    final navContext = SafeNavigator.context;
    final isArabic =
        navContext != null && Methods().getAppLanguage(navContext) == "ar";
    // TIERED, not exact-match: the backend gates this banner by COIN value
    // (lucky_gift_coins threshold) since 2026-06-10, so any multiplier can
    // arrive here (x5, x20, x100...). Exact-match on 250/500/1000 made every
    // other win an invisible banner. Any qualified win gets the nearest tier.
    final gNum = int.tryParse(widget.data["gNum"].toString()) ?? 0;
    if (gNum >= 1000) {
      return isArabic ? AssetsManager.arBanner1000 : AssetsManager.enBanner1000;
    } else if (gNum >= 500) {
      return isArabic ? AssetsManager.arBanner500 : AssetsManager.enBanner500;
    }
    return isArabic ? AssetsManager.arBanner250 : AssetsManager.enBanner250;
  }
}
