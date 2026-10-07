import 'dart:developer';
import 'dart:io';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/cache/svga_movie_cache.dart';
import 'package:flutter_svga/flutter_svga.dart';

class ShowSVGA extends StatefulWidget {
  final double? width;
  final double? height;
  final String? url;
  final BoxFit? fit;
  final String? svgaAssetPath;
  final File? fileCacheSvga;
  final bool? isNeedToRepeat;
  final bool isPlaying;
  final bool isPhoto;
  final String? pngImg;

  const ShowSVGA({
    super.key,
    this.width,
    this.height,
    this.url,
    this.svgaAssetPath,
    this.fileCacheSvga,
    this.fit,
    this.isNeedToRepeat,
    this.pngImg,
    this.isPlaying = true,
    this.isPhoto = false,
  });

  @override
  ShowSVGAState createState() => ShowSVGAState();
}

class ShowSVGAState extends State<ShowSVGA> with TickerProviderStateMixin {
  late final SVGAAnimationController animationController;

  String? _lastAssetPath;
  String? _lastUrl;
  File? _lastFile;

  @override
  void initState() {
    super.initState();
    animationController = SVGAAnimationController(vsync: this);
    _initSvgaController(
      url: widget.url,
      isNeedToRepeat: widget.isNeedToRepeat,
      svgaAssetPath: widget.svgaAssetPath,
      fileCacheSvga: widget.fileCacheSvga,
    );
  }

  @override
  void didUpdateWidget(ShowSVGA oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isPlaying != oldWidget.isPlaying) {
      if (!widget.isPlaying) {
        animationController.stop();
      } else {
        _initSvgaController(
          url: widget.url,
          isNeedToRepeat: widget.isNeedToRepeat,
          svgaAssetPath: widget.svgaAssetPath,
          fileCacheSvga: widget.fileCacheSvga,
        );
      }
    } else if (widget.svgaAssetPath != _lastAssetPath ||
        widget.fileCacheSvga?.path != _lastFile?.path ||
        widget.url != _lastUrl) {
      _initSvgaController(
        url: widget.url,
        isNeedToRepeat: widget.isNeedToRepeat,
        svgaAssetPath: widget.svgaAssetPath,
        fileCacheSvga: widget.fileCacheSvga,
      );
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: widget.isPhoto == true
          ? (widget.pngImg != null && widget.pngImg!.trim().isNotEmpty
              ? Image.asset(
                  widget.pngImg!,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                )
              : const SizedBox.shrink())
          : RepaintBoundary(
              child: SVGAImage(
                animationController,
                fit: widget.fit ?? BoxFit.contain,
                clearsAfterStop: false,
              ),
            ),
    );
  }

  Future<void> _initSvgaController({
    String? url,
    bool? isNeedToRepeat,
    String? svgaAssetPath,
    File? fileCacheSvga,
  }) async {
    try {
      animationController.videoItem = null;

      MovieEntity? videoItem;

      if (svgaAssetPath != null && svgaAssetPath != _lastAssetPath) {
        videoItem = await SvgaMovieCache.instance.loadFromAsset(svgaAssetPath);
        if (videoItem == null) return;
        _lastAssetPath = svgaAssetPath;
        _lastUrl = null;
        _lastFile = null;
      } else if (fileCacheSvga != null &&
          await fileCacheSvga.exists() &&
          fileCacheSvga.path != _lastFile?.path) {
        videoItem = await SvgaMovieCache.instance.loadFromFile(fileCacheSvga);
        if (videoItem == null) return;
        _lastFile = fileCacheSvga;
        _lastAssetPath = null;
        _lastUrl = null;
      } else if (url != null && url != _lastUrl) {
        videoItem = await SvgaMovieCache.instance.loadFromUrl(url);
        if (videoItem == null) return;
        _lastUrl = url;
        _lastAssetPath = null;
        _lastFile = null;
      } else {
        return;
      }

      if (!mounted) return;

      _playAnimation(videoItem, isNeedToRepeat);
      _hiddenSomeKeys();
    } catch (e) {
      if (kDebugMode) log("SVGA load error: $e");
    }
  }

  void _hiddenSomeKeys() {
    if (ConstantsManager.isTheme1 || ConstantsManager.isShowGridView) {
      animationController.videoItem?.dynamicItem
          .setHidden(true, "img_2103121722");
      animationController.videoItem?.dynamicItem.setHidden(true, "img_19");
      animationController.videoItem?.dynamicItem.setHidden(true, "img_17");
      animationController.videoItem?.dynamicItem.setHidden(true, "img_15");
      animationController.videoItem?.dynamicItem.setHidden(true, "img_69");
      animationController.videoItem?.dynamicItem.setHidden(true, "img_27");
      animationController.videoItem?.dynamicItem.setHidden(true, "img_29");
      animationController.videoItem?.dynamicItem.setHidden(true, "img_35");
      animationController.videoItem?.dynamicItem.setHidden(true, "img_37");
      // animationController.videoItem?.dynamicItem.setHidden(true, "img_41");
      // animationController.videoItem?.dynamicItem.setHidden(true, "img_43");
      animationController.videoItem?.dynamicItem.setHidden(true, "img_75");
      animationController.videoItem?.dynamicItem.setHidden(true, "img_79");
    }
  }

  void _playAnimation(MovieEntity videoItem, bool? isNeedToRepeat) {
    animationController.videoItem = videoItem;

    if (!widget.isPlaying) {
      animationController.stop();
      return;
    }

    if (isNeedToRepeat == false) {
      animationController.forward().whenComplete(() {
        animationController.stop();
      });
    } else {
      animationController.repeat();
    }
  }
}
