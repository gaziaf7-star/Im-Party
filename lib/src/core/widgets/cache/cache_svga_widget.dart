import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter_svga/flutter_svga.dart';
import 'package:general/src/core/cache/image_cache_manager.dart';
import 'package:general/src/core/cache/svga_movie_cache.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/utils/app_lifecycle_signal.dart';
import 'package:general/src/features/room/presentation/gifts/gift.dart';
import 'package:general/src/features/room/room.dart';
import 'package:shimmer/shimmer.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Global signal: counts how many gift SVGAs (`isShowGift == true`) are
/// currently mid-playback anywhere in the app. Lets unrelated overlays (e.g.
/// the Rocket room-reward launch sequence) wait for gift playback to fully
/// finish before taking over the screen, instead of racing it. Deliberately
/// a plain counter rather than a per-gift queue/path check, since gifts reach
/// [CacheSvgaWidget] through more than one enqueue path (sender's own instant
/// display vs. RTM-received gifts) and this hooks the one thing common to
/// all of them: the actual SVGA animation controller's play/complete cycle.
class GiftPlaybackSignal {
  GiftPlaybackSignal._();
  static final ValueNotifier<int> activeCount = ValueNotifier<int>(0);
  static bool get isPlaying => activeCount.value > 0;
}

class CacheSvgaWidget extends StatefulWidget {
  final String url;
  final double? height, width;
  final bool isShowGift;
  final BoxFit? boxFit;
  final bool? isNeedLoading;
  final BoxShape? shape;
  final double? radius;
  final bool isStopErrorAndLoadingFrame;
  final void Function()? detectError;
  final bool isStopForProfileRoom;
  final bool isAsset;

  /// When true, the looping animation is paused while the widget is off-screen
  /// or the app is backgrounded, and resumed when visible + foregrounded.
  /// Only honored for the looping case ([isShowGift] == false); the one-shot
  /// gift path is never gated. Defaults to false so gift / emoji / boom
  /// instances are unaffected.
  final bool pauseWhenHidden;

  /// When false, the movie loads and paints frame 0 only -- never calls
  /// repeat()/forward(). Used for static picker thumbnails (e.g. the emoji
  /// grid), which should show a still preview instead of every cell playing
  /// its animation at once like it does in the room itself.
  final bool autoPlay;

  /// Pictures painted into named image slots of the movie once it is decoded
  /// (slot key -> image url), e.g. the joining user's photo into the
  /// `sender_avatar` slot of an SVIP entry animation. Each picture is cropped
  /// to a circle. Keys the movie does not contain are ignored.
  final Map<String, String>? dynamicImageUrls;

  /// Text painted into named slots of the movie (slot key -> text), e.g.
  /// the joining user's name under [kSenderNameKey]. See [applySenderName]
  /// for which slot a name lands in. Keys the movie cannot take are ignored.
  final Map<String, String>? dynamicTexts;

  const CacheSvgaWidget({
    required this.url,
    this.height,
    this.boxFit,
    this.width,
    this.isNeedLoading,
    this.shape,
    this.radius,
    this.detectError,
    this.isShowGift = false,
    this.isStopErrorAndLoadingFrame = true,
    this.isStopForProfileRoom = true,
    this.isAsset = false,
    this.pauseWhenHidden = false,
    this.autoPlay = true,
    this.dynamicImageUrls,
    this.dynamicTexts,
    super.key,
  });

  @override
  CacheSvgaWidgetState createState() => CacheSvgaWidgetState();
}

class CacheSvgaWidgetState extends State<CacheSvgaWidget>
    with TickerProviderStateMixin {
  SVGAAnimationController? _animationController;

  final ValueNotifier<bool> _isLoading = ValueNotifier(true);
  final ValueNotifier<String?> _isError = ValueNotifier(null);
  bool _isDisposed = false;
  bool _countedAsGiftPlaying = false;

  void _markGiftPlaying() {
    if (_countedAsGiftPlaying) return;
    _countedAsGiftPlaying = true;
    GiftPlaybackSignal.activeCount.value++;
  }

  void _unmarkGiftPlaying() {
    if (!_countedAsGiftPlaying) return;
    _countedAsGiftPlaying = false;
    final current = GiftPlaybackSignal.activeCount.value;
    GiftPlaybackSignal.activeCount.value = current > 0 ? current - 1 : 0;
  }

  // ---- Looping-frame gating (only when widget.pauseWhenHidden == true) ----
  late final GlobalKey _visibilityKey =
  GlobalKey(debugLabel: 'svga_frame_gate');
  bool _isVisible = true;
  bool _isRepeating = false;

  bool get _gateEnabled => widget.pauseWhenHidden && !widget.isShowGift;

  @override
  void initState() {
    super.initState();
    if (_gateEnabled) {
      AppLifecycleSignal.isForeground.addListener(_applyGate);
    }
    _loadSvga();
  }

  @override
  void didUpdateWidget(CacheSvgaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.url != oldWidget.url) {
      _loadSvga();
    }
  }

  Future<void> _loadSvga() async {
    if (_isDisposed) return;

    _isLoading.value = true;
    _isError.value = null;

    // Marked from the moment this widget starts trying to show a gift (i.e.
    // before the asset fetch/decode even begins), not just once decoded, so
    // GiftPlaybackSignal covers the whole visible lifetime of the gift and
    // closes most of the race window for anything waiting on it (e.g. the
    // Rocket launch overlay).
    if (widget.isShowGift) _markGiftPlaying();

    try {
      final MovieEntity? movie;

      if (widget.isAsset) {
        movie = await SvgaMovieCache.instance.loadFromAsset(widget.url);
      } else {
        final url = EndPoints.getImage(widget.url);

        if (widget.isShowGift) {
          Methods.printLog(
            '🎁 [SVGA] loading gift => $url',
          );
        }

        movie = await SvgaMovieCache.instance.loadFromUrl(url);
      }

      if (movie != null) {
        _disposeAnimationController();

        if (_isDisposed) return;

        _animationController = SVGAAnimationController(vsync: this)
          ..videoItem = movie;

        await _applyDynamicImages(movie);
        _applyDynamicTexts(movie);
        if (_isDisposed) return;

        if (widget.isShowGift) {
          Methods.printLog(
            '✅ [SVGA] gift decoded; starting animation',
          );

          _animationController?.forward().whenComplete(() {
            Methods.printLog(
              '✅ [SVGA] gift animation completed',
            );
            _unmarkGiftPlaying();
            _handleGiftQueue();
            _animationController?.videoItem = null;
          });
        } else if (!widget.autoPlay) {
          // Static preview: leave the controller at frame 0, never ticking.
        } else if (_gateEnabled) {
          // Start (or stay paused) according to current visibility + lifecycle.
          _isRepeating = false;
          _applyGate();
        } else {
          _animationController?.repeat();
        }

        if (mounted) _isLoading.value = false;
      } else {
        _handleErrorWithGiftFallback("svga_file_not_found");
      }
    } catch (error, stack) {
      if (widget.isShowGift) {
        Methods.printLog(
          '🚨 [SVGA] failed to load gift ${widget.url}: $error',
        );
        Methods.printLog(
          '🚨 [SVGA] stack: $stack',
        );
      }

      _handleErrorWithGiftFallback("failed_to_load_svga");
    }
  }

  /// Paints [CacheSvgaWidget.dynamicImageUrls] into the movie's image slots.
  Future<void> _applyDynamicImages(MovieEntity movie) async {
    final urls = widget.dynamicImageUrls;
    if (urls == null || urls.isEmpty) return;
    for (final entry in urls.entries) {
      final key = entry.key;
      final raw = entry.value.trim();
      if (raw.isEmpty) continue;
      if (key == kSenderAvatarKey) {
        await applySenderAvatar(movie, raw);
        continue;
      }
      if (!movie.bitmapCache.containsKey(key)) continue;
      try {
        final image = await loadCircularSvgaAvatar(raw, slot: key);
        if (image != null) movie.dynamicItem.setImage(image, key);
      } catch (e) {
        Methods.printLog('⚠️ [SVGA] slot "$key" failed: $e');
      }
    }
  }

  /// Paints [CacheSvgaWidget.dynamicTexts] into the movie's text slots.
  void _applyDynamicTexts(MovieEntity movie) {
    final texts = widget.dynamicTexts;
    if (texts == null || texts.isEmpty) return;
    for (final entry in texts.entries) {
      final text = entry.value.trim();
      if (text.isEmpty) continue;
      if (entry.key == kSenderNameKey) {
        applySenderName(movie, text);
      } else if (movie.bitmapCache.containsKey(entry.key)) {
        movie.dynamicItem.setText(_svgaTextPainter(text, 24), entry.key);
      }
    }
  }

  void _handleGiftQueue() {
    di<GiftBloc>().add(
      const ShowGiftsEvent(
        pathGift: "",
        isShowGift: false,
        giftType: ShowGiftType.svga,
      ),
    );

    if (GiftController().normalGiftsToShow.isNotEmpty) {
      GiftController().normalGiftsToShow.removeAt(0);

      if (GiftController().normalGiftsToShow.isEmpty) {
        di<GiftBloc>().add(const ShowGiftsEvent(
          pathGift: "",
          isShowGift: false,
          giftType: ShowGiftType.svga,
        ));
      } else {
        final gift = GiftController().normalGiftsToShow[0];
        _showNextGift(gift);
      }
    }
  }

  void _showNextGift(Map<String, dynamic> gift) {
    final type = gift['giftType'];
    final path = gift['pathGift'];
    final isFamous = gift['isFamousGift'];
    final wappelImage = gift['wappel']['wappelImage'] ?? '';

    Future.delayed(
      Duration(milliseconds: type == 'svga' ? 650 : 100),
          () {
        if (type == 'alpha') {
          di<AlphaGiftManagerBloc>().add(
            ShowAlphaGift(imgFile: path, isFamousGift: isFamous),
          );
        } else {
          di<GiftBloc>().add(
            ShowGiftsEvent(
              isShowGift: true,
              pathGift: path,
              isFamousGift: isFamous,
              giftType: _mapGiftType(type),
            ),
          );
        }

        if (wappelImage.isNotEmpty) {
          ShowEntroWidget.showEntro.value = gift['wappel'];
        }
      },
    );
  }

  ShowGiftType _mapGiftType(String type) {
    switch (type) {
      case 'alpha':
        return ShowGiftType.alpha;
      case 'vap':
        return ShowGiftType.vap;
      case 'mp4':
        return ShowGiftType.mp4;
      default:
        return ShowGiftType.svga;
    }
  }

  void _handleErrorWithGiftFallback(String message) {
    _unmarkGiftPlaying();
    _handleGiftQueue();
    if (mounted) {
      _isLoading.value = false;
      widget.detectError?.call();
      _isError.value = message;
    }
  }

  /// Resume the loop when visible + foregrounded, pause it otherwise.
  /// Never touches the one-shot gift path (guarded by [_gateEnabled], which is
  /// false when [widget.isShowGift] is true). Idempotent: guarded by
  /// [_isRepeating] so we never double-start or get stuck stopped.
  void _applyGate() {
    if (!_gateEnabled || _isDisposed) return;
    final controller = _animationController;
    if (controller == null) return;

    final shouldRun = _isVisible && AppLifecycleSignal.isForeground.value;

    if (shouldRun) {
      if (!_isRepeating) {
        _isRepeating = true;
        controller.repeat();
      }
    } else {
      if (_isRepeating) {
        _isRepeating = false;
      }
      // stop() halts ticking without clearing; last frame stays painted
      // because SVGAImage uses clearsAfterStop: false.
      controller.stop();
    }
  }

  void _disposeAnimationController() {
    _animationController?.stop();
    _animationController?.dispose();
    _animationController = null;
    _isRepeating = false;
  }

  @override
  void dispose() {
    _isDisposed = true;
    // Safety net: if this widget is torn down mid-play (e.g. the user leaves
    // the room) the `whenComplete` callback above never fires, which would
    // otherwise leave GiftPlaybackSignal stuck incremented forever.
    _unmarkGiftPlaying();
    if (widget.pauseWhenHidden) {
      AppLifecycleSignal.isForeground.removeListener(_applyGate);
    }
    _disposeAnimationController();
    _isLoading.dispose();
    _isError.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoading,
      builder: (context, isLoading, child) {
        if (isLoading &&
            (widget.isStopErrorAndLoadingFrame ||
                widget.isStopForProfileRoom)) {
          return widget.isNeedLoading == true
              ? Shimmer.fromColors(
            baseColor: ColorManager.baseColor,
            highlightColor: ColorManager.highlightColor,
            child: Container(
              height: widget.height ??
                  (widget.isShowGift
                      ? MediaQuery.of(context).size.height
                      : 200),
              width: widget.width ??
                  (widget.isShowGift
                      ? MediaQuery.of(context).size.width
                      : 200),
              decoration: BoxDecoration(
                shape: widget.shape ?? BoxShape.rectangle,
                color: Colors.grey[300],
                borderRadius: widget.shape == BoxShape.circle
                    ? null
                    : BorderRadius.circular(widget.radius ?? 0),
              ),
            ),
          )
              : SizedBox(
            height: widget.height ??
                (widget.isShowGift
                    ? MediaQuery.of(context).size.height
                    : 200),
            width: widget.width ??
                (widget.isShowGift
                    ? MediaQuery.of(context).size.width
                    : 200),
          );
        }

        return ValueListenableBuilder<String?>(
          valueListenable: _isError,
          builder: (context, isError, child) {
            if (isError != null &&
                (widget.isStopErrorAndLoadingFrame ||
                    widget.isStopForProfileRoom)) {
              return SizedBox(
                height: widget.height ?? 200,
                width: widget.width ?? 200,
              );
            }

            if (_isDisposed || _animationController == null) {
              return const SizedBox();
            }

            final double? resolvedHeight =
                widget.height ??
                    (widget.isShowGift
                        ? MediaQuery.of(context).size.height
                        : null);

            final double? resolvedWidth =
                widget.width ??
                    (widget.isShowGift
                        ? MediaQuery.of(context).size.width
                        : null);

            final Widget image = SizedBox(
              height: resolvedHeight,
              width: resolvedWidth,
              child: RepaintBoundary(
                child: SVGAImage(
                  _animationController!,
                  fit: widget.boxFit ?? BoxFit.contain,
                  clearsAfterStop: false,
                ),
              ),
            );

            if (!_gateEnabled) return image;

            return VisibilityDetector(
              key: _visibilityKey,
              onVisibilityChanged: (info) {
                if (_isDisposed) return;
                final visible = info.visibleFraction > 0;
                if (visible == _isVisible) return;
                _isVisible = visible;
                _applyGate();
              },
              child: image,
            );
          },
        );
      },
    );
  }
}



/// Image slot the SVIP entry animations name for the joining user's picture.
const String kSenderAvatarKey = 'sender_avatar';

/// Text slot for the joining user's name. Designers can add a layer with
/// this key to any entry animation and the name is filled in automatically.
const String kSenderNameKey = 'sender_name';

/// Entry animations that already carry a name strip under another key,
/// matched by image size so an unrelated layer with the same key is never
/// written over: SVIP 8's `banner` (320x32) sits right under the avatar
/// badge.
const List<(String, int, int)> _nameBanners = [('banner', 320, 32)];

TextPainter _svgaTextPainter(String text, double fontSize) => TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          shadows: const [Shadow(color: Color(0xAA000000), blurRadius: 3)],
        ),
      ),
      maxLines: 1,
      ellipsis: '...',
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 300);

/// Writes the joining user's [name] into [movie]: into its `sender_name`
/// slot when it has one, otherwise into a known name strip. Returns false
/// when the movie has nowhere to show a name.
bool applySenderName(MovieEntity movie, String name) {
  final text = name.trim();
  if (text.isEmpty) return false;
  final slot = movie.bitmapCache[kSenderNameKey];
  if (slot != null) {
    movie.dynamicItem
        .setText(_svgaTextPainter(text, slot.height * 0.6), kSenderNameKey);
    return true;
  }
  for (final (key, w, h) in _nameBanners) {
    final img = movie.bitmapCache[key];
    if (img != null && img.width == w && img.height == h) {
      movie.dynamicItem.setText(_svgaTextPainter(text, h * 0.62), key);
      return true;
    }
  }
  return false;
}

/// Entry animations that have NO `sender_avatar` slot but an empty badge hole
/// baked into one of their images (e.g. SVIP 8): the picture is drawn over the
/// hole with the movie's dynamic drawer, so it follows the sprite's own
/// transform and fades in/out with it.
class _AvatarHole {
  final String spriteKey;
  final String companionKey;
  final int width;
  final int height;
  final Offset center;
  final double radius;
  final int fadeInFrom;
  final int fadeInTo;
  final int fadeOutFrom;
  final int fadeOutTo;

  const _AvatarHole({
    required this.spriteKey,
    required this.companionKey,
    required this.width,
    required this.height,
    required this.center,
    required this.radius,
    required this.fadeInFrom,
    required this.fadeInTo,
    required this.fadeOutFrom,
    required this.fadeOutTo,
  });

  double alphaAt(int frame) {
    if (frame <= fadeInFrom) return 0;
    if (frame < fadeInTo) {
      return (frame - fadeInFrom) / (fadeInTo - fadeInFrom);
    }
    if (frame >= fadeOutTo) return 0;
    if (frame >= fadeOutFrom) {
      return (fadeOutTo - frame) / (fadeOutTo - fadeOutFrom);
    }
    return 1;
  }
}

// SVIP 8 entry ("sVIP 8 entry.svga"): the hexagon badge is part of image "66"
// (554x195, hole centre ~(275,78)); its sprite fades in over frames 12-18 and
// out over 146-149.
const List<_AvatarHole> _avatarHoles = [
  _AvatarHole(
    spriteKey: '66',
    companionKey: 'banner',
    width: 554,
    height: 195,
    center: Offset(275, 78),
    radius: 28,
    fadeInFrom: 12,
    fadeInTo: 18,
    fadeOutFrom: 145,
    fadeOutTo: 149,
  ),
];

_AvatarHole? _avatarHoleFor(MovieEntity movie) {
  for (final h in _avatarHoles) {
    final img = movie.bitmapCache[h.spriteKey];
    if (img != null &&
        img.width == h.width &&
        img.height == h.height &&
        movie.bitmapCache.containsKey(h.companionKey)) {
      return h;
    }
  }
  return null;
}

/// Puts the joining user's picture (circle) into [movie]: into its
/// `sender_avatar` slot when it has one, otherwise over the known badge hole.
/// Returns false when the movie offers neither or the picture is unavailable.
Future<bool> applySenderAvatar(MovieEntity movie, String raw) async {
  final bool hasSlot = movie.bitmapCache.containsKey(kSenderAvatarKey);
  final hole = hasSlot ? null : _avatarHoleFor(movie);
  if (!hasSlot && hole == null) return false;
  try {
    final image = await loadCircularSvgaAvatar(raw, slot: kSenderAvatarKey);
    if (image == null) return false;
    if (hasSlot) {
      movie.dynamicItem.setImage(image, kSenderAvatarKey);
    } else {
      final src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
      final dst = Rect.fromCircle(center: hole!.center, radius: hole.radius);
      movie.dynamicItem.setDynamicDrawer((canvas, frame) {
        final a = hole.alphaAt(frame);
        if (a <= 0) return;
        canvas.drawImageRect(
          image,
          src,
          dst,
          Paint()
            ..isAntiAlias = true
            ..filterQuality = FilterQuality.high
            ..color = Color.fromARGB((a * 255).round(), 255, 255, 255),
        );
      }, hole.spriteKey);
    }
    return true;
  } catch (e) {
    Methods.printLog('⚠️ [SVGA] sender avatar failed: $e');
    return false;
  }
}

/// Loads [raw] (a backend picture url / relative path) as a square, circular
/// `ui.Image` ready to be painted into an SVGA image slot; null when the
/// picture is not available.
Future<ui.Image?> loadCircularSvgaAvatar(String raw, {String slot = ''}) async {
  final url = _fixBackendUrl(raw.trim());
  Methods.printLog('🎭 [SVGA] slot "$slot" <- "$raw" -> "$url"');
  final file = await AssetCacheManager().getCachedAsset(url);
  if (file == null) {
    Methods.printLog('⚠️ [SVGA] slot "$slot": image not available ($url)');
    return null;
  }
  return _circularImage(await file.readAsBytes());
}

/// `https://host/profile/x.jpg` is a 404: the file is under `/storage/`.
String _fixBackendUrl(String raw) {
  final host = '${EndPoints.domainURL}/';
  if (raw.startsWith(host)) {
    final rest = raw.substring(host.length);
    if (rest.startsWith('profile/')) return EndPoints.getImage(rest);
  }
  return EndPoints.getImage(raw);
}

/// Centre-crops [bytes] to a square and clips it to a circle.
Future<ui.Image?> _circularImage(Uint8List bytes) async {
  const double side = 256;
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  codec.dispose();
  final src = frame.image;
  final m = math.min(src.width, src.height).toDouble();
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.clipPath(Path()..addOval(const Rect.fromLTWH(0, 0, side, side)));
  canvas.drawImageRect(
    src,
    Rect.fromLTWH((src.width - m) / 2, (src.height - m) / 2, m, m),
    const Rect.fromLTWH(0, 0, side, side),
    Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high,
  );
  return recorder.endRecording().toImage(side.toInt(), side.toInt());
}
