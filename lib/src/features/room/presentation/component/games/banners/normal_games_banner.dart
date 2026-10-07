import 'dart:io';
import 'dart:ui' as ui;
import 'package:general/src/core/cache/image_cache_manager.dart';
import 'package:general/src/core/cache/svga_movie_cache.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/banners_bloc/banners_bloc.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/banners_bloc/banners_event.dart';
import 'package:general/src/features/room/room.dart';
import '../../../../../../core/index.dart';
import 'package:flutter_svga/flutter_svga.dart';

class NormalGamesBanner extends StatefulWidget {
  const NormalGamesBanner({
    super.key,
    required this.userImage,
    required this.username,
    required this.coins,
    required this.gameImage,
    required this.speed,
  });
  final String userImage, username, coins, gameImage, speed;

  @override
  State<NormalGamesBanner> createState() => _NormalGamesBannerState();
}

class _NormalGamesBannerState extends State<NormalGamesBanner>
    with SingleTickerProviderStateMixin {
  late SVGAAnimationController animationController;
  final AssetCacheManager _assetCacheManager = AssetCacheManager();

  @override
  void initState() {
    super.initState();
    animationController = SVGAAnimationController(vsync: this);
    loadAnimation();
  }

  Future<String> _loadCachedOrRemoteAsset(String path) async {
    File? assetFile;
    try {
      assetFile = await _assetCacheManager.getCachedAsset(path);
      if (assetFile != null) {
        path = assetFile.path;
      }
    } catch (error) {
      Methods.printLog("failed_to_load_asset");
    }
    return assetFile?.path ?? "";
  }

  void loadAnimation() async {
    final videoItem = await SvgaMovieCache.instance
        .loadFromAsset(AssetsManager.bannerGameWinSVGA);
    if (videoItem == null) {
      // Asset missing: never leave this entry stuck at the head — it would
      // freeze the whole queue (only the animation teardown advances it).
      _skipAndAdvanceQueue();
      return;
    }

    animationController.videoItem = videoItem;

    if (widget.speed == "fast") {
      animationController.duration = const Duration(seconds: 2);
    }

    String gameImage = widget.gameImage.isNotEmpty
        ? await _loadCachedOrRemoteAsset(widget.gameImage)
        : "";
    String userImage = widget.userImage.isNotEmpty
        ? await _loadCachedOrRemoteAsset(widget.userImage)
        : "";

    // --- Game Image ---
    if (gameImage.isNotEmpty) {
      try {
        final Uint8List imageBytes = await File(gameImage).readAsBytes();
        final ui.Image image =
            await decodeImageFromList(imageBytes.buffer.asUint8List());
        animationController.videoItem?.dynamicItem.setImage(image, "game");
      } catch (e) {
        debugPrint('Error loading cached game image: $e');
      }
    } else if (widget.gameImage.isNotEmpty) {
      try {
        await animationController.videoItem?.dynamicItem
            .setImageWithUrl(EndPoints.getImage(widget.gameImage), "game");
      } catch (e) {
        debugPrint('Error loading remote game image: $e');
      }
    }

    // --- User Image ---
    if (userImage.isNotEmpty) {
      try {
        final Uint8List imageBytes = await File(userImage).readAsBytes();
        final ui.Image image =
            await decodeImageFromList(imageBytes.buffer.asUint8List());
        animationController.videoItem?.dynamicItem
            .setImage(image, "sendheadimg");
      } catch (e) {
        debugPrint('Error loading cached user image: $e');
      }
    } else if (widget.userImage.isNotEmpty) {
      try {
        await animationController.videoItem?.dynamicItem.setImageWithUrl(
            EndPoints.getImage(widget.userImage), "sendheadimg");
      } catch (e) {
        debugPrint('Error loading remote user image: $e');
      }
    }

    // --- Coins Text ---
    animationController.videoItem?.dynamicItem.setText(
      TextPainter(
        text: TextSpan(
          children: [
            TextSpan(
              text: widget.coins,
              style: context.bodyMedium.size(20).bold.colorExt(
                    ColorManager.whiteColor,
                  ),
            ),
          ],
        ),
      ),
      'font_ffffff_108_28_26',
    );

    // --- Username Text ---
    animationController.videoItem?.dynamicItem.setText(
      TextPainter(
        text: TextSpan(
          children: [
            TextSpan(
              text: widget.username,
              style: context.bodyMedium.size(18).bold.colorExt(
                    ColorManager.whiteColor,
                  ),
            ),
          ],
        ),
      ),
      'sendfont_ffffff_330_30_24',
    );

    // --- Start Animation ---
    try {
      animationController.forward().whenComplete(
        () {
          animationController.clear();
          di<ShowBannersBloc>().add(const ShowBannerInAppEvent(bannerData: {}));
          if (GiftController().userBannerData.isNotEmpty) {
            GiftController().userBannerData.removeAt(0);
          }
          Future.delayed(
            const Duration(milliseconds: 300),
            () => GiftController().advanceQueue(),
          );
        },
      );
    } catch (_) {
      _skipAndAdvanceQueue();
    }
  }

  /// Drop the head and advance when this banner cannot animate, so a failed
  /// game banner never freezes the shared queue.
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

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SVGAImage(animationController);
  }
}
