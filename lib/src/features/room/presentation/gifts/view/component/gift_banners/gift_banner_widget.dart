import 'dart:io';
import 'package:general/src/core/cache/image_cache_manager.dart';
import 'package:general/src/core/cache/svga_movie_cache.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/banners_bloc/banners_bloc.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/banners_bloc/banners_event.dart';
import 'dart:ui' as ui;
import 'package:general/src/features/room/room.dart';
import 'package:flutter_svga/flutter_svga.dart';


class GiftBannerWidgetNew extends StatefulWidget {
  final RoomVisitorModel sendDataUser;
  final RoomVisitorModel receiverDataUser;
  final String giftImage;
  final bool isPassword;
  final String giftPrice;
  final String speed;

  const GiftBannerWidgetNew({
    super.key,
    required this.isPassword,
    required this.sendDataUser,
    required this.receiverDataUser,
    required this.giftImage,
    required this.speed,
    required this.giftPrice,
  });

  @override
  State<GiftBannerWidgetNew> createState() => _GiftBannerWidgetNewState();
}

class _GiftBannerWidgetNewState extends State<GiftBannerWidgetNew>
    with SingleTickerProviderStateMixin {
  late SVGAAnimationController animationController;
  final AssetCacheManager _assetCacheManager = AssetCacheManager();
  @override
  void initState() {
    animationController = SVGAAnimationController(vsync: this);
    getAnimation();
    super.initState();
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
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void getAnimation() async {
    final videoItem =
        await SvgaMovieCache.instance.loadFromAsset(getBannerImage());
    if (videoItem == null) return;

    animationController.videoItem = videoItem;

    if (widget.speed == "fast") {
      animationController.duration = const Duration(seconds: 2);
    }

    String senderImage =
        await _loadCachedOrRemoteAsset(widget.sendDataUser.image ?? '');
    String receiverImage =
        await _loadCachedOrRemoteAsset(widget.receiverDataUser.image ?? '');
    if (senderImage.isEmpty) {
      try {
        await animationController.videoItem?.dynamicItem.setImageWithUrl(
            EndPoints.getImage(widget.sendDataUser.image ?? ''), "avator2");
      } catch (e) {
        debugPrint('Error loading sender avatar image: $e');
      }
    } else {
      // Same guard as the receiver branch — corrupt cached file must not
      // crash the banner.
      try {
        final File imageFile = File(senderImage);
        final Uint8List imageBytes = await imageFile.readAsBytes();
        final ui.Image image =
            await decodeImageFromList(imageBytes.buffer.asUint8List());
        animationController.videoItem?.dynamicItem.setImage(image, "avator2");
      } catch (e) {
        debugPrint('Error decoding sender avatar file: $e');
      }
    }
    if (receiverImage.isEmpty) {
      try {
        await animationController.videoItem?.dynamicItem.setImageWithUrl(
            EndPoints.getImage(widget.receiverDataUser.image ?? ''), "avator1");
      } catch (e) {
        debugPrint('Error loading receiver avatar image: $e');
      }
    } else {
      // Guarded like the URL branch: a corrupt/partial cached avatar file
      // threw "Invalid image data" and crashed the banner (Crashlytics
      // ae877441, 18 events). A bad avatar must never kill the banner.
      try {
        final File imageFile = File(receiverImage);
        final Uint8List imageBytes = await imageFile.readAsBytes();
        final ui.Image image =
            await decodeImageFromList(imageBytes.buffer.asUint8List());
        animationController.videoItem?.dynamicItem.setImage(image, "avator1");
      } catch (e) {
        debugPrint('Error decoding receiver avatar file: $e');
      }
    }

    animationController.videoItem?.dynamicItem.setText(
        TextPainter(
            text: TextSpan(
          children: [
            TextSpan(
                text: ' ${StringManager.received.tr()} ',
                style: context.bodyMedium.colorExt(ColorManager.white).size(30)),
            TextSpan(
                text:
                    '${widget.giftPrice.isNotEmpty ? widget.giftPrice.length > 8 ? widget.giftPrice.substring(0, 7) : widget.giftPrice : ''} ${StringManager.coins_.tr()}',
                style: context.bodyMedium.colorExt(ColorManager.white).size(30)),
          ],
        )),
        'name');

    if (!mounted) return;

    animationController.forward().whenComplete(() {
      if (!mounted) return;
      animationController.clear();
      di<ShowBannersBloc>().add(const ShowBannerInAppEvent(bannerData: {}));
      if (GiftController().userBannerData.isNotEmpty) {
        GiftController().userBannerData.removeAt(0);
      }
      Future.delayed(
        const Duration(milliseconds: 300),
        () => GiftController().advanceQueue(),
      );
    });
  }

  String getBannerImage() {
    if (int.parse(widget.giftPrice) <= 100000) {
      return AssetsManager.bannerRoom1;
    } else if (int.parse(widget.giftPrice) <= 200000) {
      return AssetsManager.bannerRoom2;
    } else {
      return AssetsManager.bannerRoom3;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().screenWidth,
      height: 80.h,
      color: ColorManager.transparent,
      child: SVGAImage(
        animationController,
        fit: BoxFit.cover,
      ),
    );
  }
}
