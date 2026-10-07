import 'dart:io';
import 'dart:ui' as ui;
import 'package:general/src/core/cache/image_cache_manager.dart';
import 'package:general/src/core/cache/svga_movie_cache.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/gifts/controller/gift_controller.dart';
import 'package:flutter_svga/flutter_svga.dart';

class ShowEntroWidget extends StatefulWidget {
  final Map<String, dynamic> userIntroData;
  final dynamic offsetAnimationEntro;

  const ShowEntroWidget({
    super.key,
    required this.userIntroData,
    this.offsetAnimationEntro,
  });

  static ValueNotifier<Map<String, dynamic>?> showEntro =
      ValueNotifier<Map<String, dynamic>?>(null);

  @override
  State<ShowEntroWidget> createState() => _ShowEntroWidgetState();
}

class _ShowEntroWidgetState extends State<ShowEntroWidget>
    with TickerProviderStateMixin {
  late SVGAAnimationController animationController;
  Animation<Offset>? animationControllerPng;
  AnimationController? controllerEntroPng;

  final AssetCacheManager _assetCacheManager = AssetCacheManager();
  late final bool _isAR;

  @override
  void initState() {
    super.initState();
    // Read locale once — avoids synchronous Hive I/O inside build().
    _isAR = HiveManager().getData<String>(
          KeysManager.USER_BOX,
          KeysManager.LANG_CODE_KEY,
        ) ==
        "ar";
    animationController = SVGAAnimationController(vsync: this);
    controllerEntroPng = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    animationControllerPng = Tween(
      begin: const Offset(1, 0.0),
      end: const Offset(-1, 0.0),
    ).animate(
      CurvedAnimation(
        parent: controllerEntroPng!,
        curve: Curves.easeInOut,
      ),
    );
    _validateUserIntroData();
  }

  void _validateUserIntroData() {
    final String? image = widget.userIntroData['wappelImage'];

    bool isSVGA = image != null &&
        (image.toLowerCase().endsWith('.svga') ||
            image.toLowerCase().endsWith('.zz') ||
            image.toLowerCase().endsWith('.zzz'));
    bool isMP4 = image != null && image.toLowerCase().endsWith('.mp4');
    bool isPNG = image != null &&
        (image.toLowerCase().endsWith('.png') ||
            image.toLowerCase().endsWith('.jpg') ||
            image.toLowerCase().endsWith('.jpeg'));

    bool isTypeMatch = false;

    if (isSVGA) {
      widget.userIntroData['wappelType'] = 'svga';
      isTypeMatch = true;
    } else if (isMP4) {
      widget.userIntroData['wappelType'] = 'mp4';
      isTypeMatch = true;
    } else if (isPNG) {
      widget.userIntroData['wappelType'] = 'png';
      isTypeMatch = true;
    }

    if (!isTypeMatch || image == null || image.isEmpty) {
      final defaultWabble = Methods().getUserWabble(0);
      widget.userIntroData['wappelImage'] = defaultWabble?.image ?? '';
      widget.userIntroData['wappelType'] = defaultWabble?.imageType ?? '';
      widget.userIntroData['wappelKeyName'] = defaultWabble?.keyJson ?? {};
    }

    final fixedType = widget.userIntroData['wappelType'];
    if (fixedType == 'svga') {
      loadAnimation();
    } else {
      loadAnimationPng();
    }
  }

  void loadAnimationPng() {
    animationControllerPng = Tween(
      begin: const Offset(1, 0.0),
      end: const Offset(-1, 0.0),
    ).animate(
      CurvedAnimation(
        parent: controllerEntroPng!,
        curve: Curves.easeInOut,
      ),
    );

    controllerEntroPng?.forward().whenComplete(() {
      animationController.reverse();
      ShowEntroWidget.showEntro.value = null;
    });
  }

  Future<String> _loadCachedOrRemoteAsset(String path) async {
    File? assetFile;
    try {
      assetFile = await _assetCacheManager.getCachedAsset(path);
      if (assetFile != null) {
        path = assetFile.path;
      }
    } catch (error) {
      Methods.printLog("Failed to load asset");
    }
    return assetFile?.path ?? "";
  }

  void loadAnimation() async {
    try {
      final svgaRawPath = widget.userIntroData['wappelImage'] ?? '';
      final videoItem = await SvgaMovieCache.instance.loadFromUrl(svgaRawPath);
      if (!mounted || videoItem == null) return;
      animationController.videoItem = videoItem;

      final String? userImage = widget.userIntroData['user_image_intro'];
      final Map<String, dynamic>? keyMap =
          widget.userIntroData['wappelKeyName'];

      if (keyMap == null || keyMap.isEmpty) {
        Methods.printLog("⚠️ No key_map provided");
        return;
      }

      for (final entry in keyMap.entries) {
        final String key = entry.key;
        final String type = entry.value;

        if (type == 'avatar') {
          if ((userImage ?? '').isEmpty) {
            final ByteData assetData =
                await rootBundle.load(AssetsManager.logo);
            final Uint8List imageBytes = assetData.buffer.asUint8List();
            // instantiateImageCodec uses the engine's image-decoder thread
            // instead of blocking the UI isolate's event loop.
            final codec = await ui.instantiateImageCodec(imageBytes);
            final frame = await codec.getNextFrame();
            codec.dispose();
            animationController.videoItem?.dynamicItem.setImage(frame.image, key);
          } else {
            final String cachedPath =
                await _loadCachedOrRemoteAsset(userImage!);
            if (cachedPath.isEmpty) {
              try {
                await animationController.videoItem?.dynamicItem.setImageWithUrl(
                  EndPoints.getImage(userImage),
                  key,
                );
              } catch (e) {
                debugPrint('Error loading intro image: $e');
              }
            } else {
              final File imageFile = File(cachedPath);
              final Uint8List imageBytes = await imageFile.readAsBytes();
              final codec = await ui.instantiateImageCodec(imageBytes);
              final frame = await codec.getNextFrame();
              codec.dispose();
              animationController.videoItem?.dynamicItem.setImage(frame.image, key);
            }
          }
        } else if (type == 'text') {
          final String firstName =
              (widget.userIntroData['user_name_intro'] ?? '').split(' ').first;

          final textPainter = TextPainter(
            text: TextSpan(
              text: StringManager.joinedRoom(firstName),
              style: TextStyle(
                fontSize: 25.sp,
                fontWeight: FontWeight.bold,
                color: ColorManager.white,
              ),
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
          )..layout();

          animationController.videoItem?.dynamicItem.setText(textPainter, key);
        } else {
          Methods.printLog("⚠️ Unknown type '$type' for key '$key'");
        }
      }

      if (!mounted) return;
      animationController.forward().whenComplete(() {
        animationController.reverse();
        ShowEntroWidget.showEntro.value = null;
        GiftController().userIntroData.clear();
      });
    } catch (e, stack) {
      ShowEntroWidget.showEntro.value = null;
      Methods.printLog('❌ Error in loadAnimation: $e\n$stack');
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    controllerEntroPng?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Methods.printLog('🔁 ShowEntroWidget is called ${widget.userIntroData}');
    String? defaultWabbleImage;
    if (widget.userIntroData['wappelImage'] == null ||
        widget.userIntroData['wappelImage'].isEmpty) {
      defaultWabbleImage = Methods().getUserWabble(0)?.image ?? '';
    }

    String userName = '';

    // check if user name letters number more than 20
    if (widget.userIntroData['user_name_intro'] != null) {
      if ((widget.userIntroData['user_name_intro'] ?? '')
              .toString()
              .split(' ')
              .first
              .length >
          16) {
        userName =
            "${(widget.userIntroData['user_name_intro'] ?? '').toString().split(' ').first.substring(0, 16)}...";
      } else {
        userName = widget.userIntroData['user_name_intro'] ?? '';
      }
    }

    return widget.userIntroData['wappelType'] == 'svga'
        ? SVGAImage(
            animationController,
            preferredSize: const Size(300, 300),
          )
        : SlideTransition(
            position: animationControllerPng!,
            child: Container(
              height: 40.h,
              width: ScreenUtil().screenWidth,
              padding: context.paddingOnly(
                start: _isAR ? 40 : 15,
                end: _isAR ? 15 : 40,
                top: 5,
                bottom: 5,
              ),
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  ImageViewWidget(
                    url: widget.userIntroData['wappelImage']?.isNotEmpty == true
                        ? widget.userIntroData['wappelImage']
                        : defaultWabbleImage ?? '',
                    height: 40.h,
                    width: ScreenUtil().screenWidth,
                    boxFit: BoxFit.contain,
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: ScreenUtil().screenWidth * 0.5,
                      minWidth: 1.w,
                    ),
                    child: Text(
                      StringManager.joinedRoom(
                        userName,
                      ),
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ColorManager.white,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
