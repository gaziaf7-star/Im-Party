import 'package:flutter_svga/flutter_svga.dart';
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
