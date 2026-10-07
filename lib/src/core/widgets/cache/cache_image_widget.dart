import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:shimmer/shimmer.dart';
import 'package:general/src/core/cache/image_cache_manager.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/services/connectivity_service.dart';

class CacheImageWidget extends StatefulWidget {
  final String url;
  final double? width;
  final double? height;
  final double? maxHeight;
  final double? widthLoading;
  final double? heightLoading;
  final double? widthError;
  final double? heightError;
  final double? radius;
  final double? scale;
  final BoxFit? boxFit;
  final BoxShape? shape;
  final Widget? child;
  final EdgeInsetsDirectional? padding;
  final EdgeInsetsDirectional? margin;
  final Border? border;
  final bool? isFromRoom;
  final bool? isCp;
  final bool? isBubble;
  final bool? isRoomProfile;
  final bool isStopLoadingAndError;
  final bool isStopForProfileRoom;
  final void Function()? detectError;
  final bool? isGift;
  final bool showLoadingIndicator;
  final bool canRetry;
  final String? displayName;

  /// When true this image is a ROOM/LIVE COVER: on empty/failed it falls back to
  /// the neutral [RoomCoverPlaceholder] instead of the app logo. Ignored for
  /// avatars ([displayName] takes precedence and renders initials).
  final bool isRoomCover;

  /// When true the empty/failed fallback keeps the BRAND APP LOGO. Defaults to
  /// FALSE so a photoless image NEVER shows the brand logo — the generic
  /// fallback is the neutral [PersonPlaceholder] (grey circle + person glyph).
  /// Set true ONLY at genuine brand-logo slots. [displayName] (initials) and
  /// [isRoomCover] (room cover) still take precedence when set.
  final bool fallbackToLogo;

  const CacheImageWidget({
    required this.url,
    super.key,
    this.height,
    this.width,
    this.padding,
    this.shape,
    this.boxFit,
    this.margin,
    this.border,
    this.child,
    this.radius,
    this.isFromRoom,
    this.widthError,
    this.heightError,
    this.isCp,
    this.isBubble = false,
    this.isRoomProfile = false,
    this.heightLoading,
    this.scale,
    this.maxHeight,
    this.widthLoading,
    this.detectError,
    this.isStopLoadingAndError = true,
    this.isStopForProfileRoom = false,
    this.isGift = false,
    this.showLoadingIndicator = false,
    this.canRetry = false,
    this.displayName,
    this.isRoomCover = false,
    this.fallbackToLogo = false,
  });

  @override
  State<CacheImageWidget> createState() => _CacheImageWidgetState();
}

class _CacheImageWidgetState extends State<CacheImageWidget> {
  final _assetCacheManager = AssetCacheManager();
  final _isLoading = ValueNotifier<bool>(true);
  final _isError = ValueNotifier<bool>(false);

  String _cachedFilePath = '';

  // ── Slow-network resilience ───────────────────────────────────────────────
  // On very slow networks the download dio can time out (even after its own
  // built-in retries) and getCachedAsset() returns null. Without this, the
  // widget would set _isError once and stay on the placeholder forever. We
  // instead retry a BOUNDED number of times with a short backoff, then — only
  // while still in error — listen for connectivity to come back and make ONE
  // more attempt. Everything is cancelled on success / dispose, so there is no
  // infinite loop and no leaked timer/subscription.
  static const int _maxRetries = 2;
  static const List<int> _backoffMs = [800, 1600];
  int _retryCount = 0;
  Timer? _retryTimer;
  StreamSubscription<bool>? _connectivitySub;

  // Monotonic token: every _loadImage() call bumps it. An in-flight async load
  // whose token is stale (a newer load started, e.g. the url changed or a retry
  // superseded it) must not mutate state — prevents races / out-of-order writes.
  int _loadToken = 0;

  // A cached file that fails to decode is evicted below. Re-download it ONCE:
  // a truncated or half-written cache entry heals on a single refetch, and
  // without this the widget parks on the retry placeholder until someone taps
  // it by hand — which is why one home card stayed grey while its neighbour
  // loaded, and why the server never saw a request for that file at all.
  // One attempt only, so a genuinely undecodable source cannot loop.
  bool _refetchedAfterCorruptCache = false;

  @override
  void initState() {
    super.initState();
    // The very first image request of a session can race the app's own
    // storage-host config fetch: this widget may build its url from the
    // cold-start bootstrap host, fail, and (once its own bounded retries
    // are exhausted) settle on the error placeholder -- all before the
    // real host even arrives. Once EndPoints corrects it, give an image
    // that's still sitting in that error state exactly one more try. This
    // is what fixes "gift images don't show the first time, but do after
    // closing and reopening the sheet" without requiring a remount.
    EndPoints.storageBaseUrlVersion.addListener(_onStorageBaseUrlChanged);
    // Synchronous disk-cache hit: if the file is already on disk, set the path
    // and start NOT in the loading state so the success widget paints on the
    // first frame (no shimmer flash). This is the core of "served from cache":
    // a reopen of an already-cached image never shows a loading placeholder and
    // never re-runs the async download path. Flutter's in-memory ImageCache +
    // gaplessPlayback then keep the decoded frame across rebuilds.
    if (_trySyncCacheHit()) {
      _isLoading.value = false;
      // Dimensionless callers still need an aspect ratio; compute it off the UI
      // thread without blocking the first paint (the image shows immediately at
      // its container size, then settles once the cheap header read returns).
      if (widget.height == null && widget.width == null) {
        _resolveDisplaySize(_cachedFilePath, ++_loadToken);
      }
      return;
    }
    _loadImage();
  }

  /// Resolves the on-disk cache path for [widget.url] WITHOUT any await and,
  /// if the file already exists with content, records it in [_cachedFilePath].
  /// Returns true on a hit so the caller can skip the async/loading path.
  bool _trySyncCacheHit() {
    final raw = widget.url.trim();
    if (raw.isEmpty) return false;
    try {
      final url = EndPoints.getImage(raw);
      final path =
          '${EndPoints.localPath}/${_assetCacheManager.extractRelativePath(url)}';
      final f = File(path);
      if (f.existsSync() && f.lengthSync() > 0) {
        _cachedFilePath = path;
        return true;
      }
    } catch (_) {}
    return false;
  }

  @override
  void dispose() {
    EndPoints.storageBaseUrlVersion.removeListener(_onStorageBaseUrlChanged);
    _retryTimer?.cancel();
    _connectivitySub?.cancel();
    _isLoading.dispose();
    _isError.dispose();
    super.dispose();
  }

  void _onStorageBaseUrlChanged() {
    if (!mounted) return;
    if (_isError.value) {
      _resetRetryState();
      _loadImage();
    }
  }

  @override
  void didUpdateWidget(covariant CacheImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.url != oldWidget.url) {
      // New url => abandon any pending retry/backoff for the old one and start
      // a fresh attempt cycle.
      _resetRetryState();
      _loadImage();
    }
  }

  void _resetRetryState() {
    _retryCount = 0;
    _retryTimer?.cancel();
    _retryTimer = null;
    _connectivitySub?.cancel();
    _connectivitySub = null;
  }

  /// Called when a load attempt fails. Schedules a bounded backoff retry; once
  /// retries are exhausted, marks the image as errored and arms a one-shot
  /// connectivity-recovery listener so a returning network re-attempts instead
  /// of leaving a permanent placeholder.
  void _onLoadFailed() {
    if (!mounted) return;
    if (_retryCount < _maxRetries) {
      final delay = _backoffMs[_retryCount];
      _retryCount++;
      _retryTimer?.cancel();
      _retryTimer = Timer(Duration(milliseconds: delay), () {
        if (mounted) _loadImage();
      });
      return;
    }
    // Retries exhausted: surface the placeholder, then wait for the network to
    // come back for one more shot (re-armed each failure cycle).
    _isError.value = true;
    _isLoading.value = false;
    _armConnectivityRetry();
  }

  void _armConnectivityRetry() {
    if (_connectivitySub != null) return; // already waiting
    _connectivitySub =
        ConnectivityService().connectionStream.listen((isConnected) {
          if (!isConnected || !mounted) return;
          // Network restored while we are still showing an error: reset the retry
          // budget and try once more. Cancel the listener so a flapping connection
          // can't spin us — a fresh failure re-arms it.
          _connectivitySub?.cancel();
          _connectivitySub = null;
          _retryCount = 0;
          _loadImage();
        });
  }

  double? _imageWidth;
  double? _imageHeight;

  /// Reads ONLY the intrinsic dimensions of [path] by decoding a tiny
  /// (header-bounded) frame instead of the full-resolution bitmap. The codec is
  /// asked for a 64px-wide target, so it allocates a negligible buffer yet
  /// reports a frame whose width/height preserve the source aspect ratio — all
  /// we need to lay the container out. Replaces the old full-res getImageSize()
  /// decode that was the dominant per-open render cost.
  Future<Size?> _readDisplayAspect(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: 64);
      final frame = await codec.getNextFrame();
      final img = frame.image;
      final size = Size(img.width.toDouble(), img.height.toDouble());
      img.dispose();
      codec.dispose();
      return size;
    } catch (_) {
      return null;
    }
  }

  /// Computes [_imageWidth]/[_imageHeight] for dimensionless callers from the
  /// cheap aspect read above, mapping the source ratio into the available box
  /// (same math as before, just fed by a header decode instead of a full one).
  Future<void> _resolveDisplaySize(String path, int token) async {
    final size = await _readDisplayAspect(path);
    if (size == null || size.width <= 0 || size.height <= 0) return;
    if (!mounted || token != _loadToken) return;
    final imageAspectRatio = size.width / size.height;
    final containerAspectRatio =
        (ScreenUtil().screenWidth - 50.w) / (widget.maxHeight ?? 260.0);
    setState(() {
      if (imageAspectRatio > containerAspectRatio) {
        _imageWidth = (ScreenUtil().screenWidth - 50.w);
        _imageHeight = (ScreenUtil().screenWidth - 50.w) / imageAspectRatio;
      } else {
        _imageHeight = widget.maxHeight ?? 260.0;
        _imageWidth = (widget.maxHeight ?? 260.0) * imageAspectRatio;
      }
    });
  }

  Future<void> _loadImage() async {
    final int token = ++_loadToken;
    _retryTimer?.cancel();

    // Fast-path: empty URL → show InitialsAvatar immediately (no 3s retry delay)
    if (widget.url.trim().isEmpty) {
      _isLoading.value = false;
      _isError.value = true;
      return;
    }

    _isLoading.value = true;
    _isError.value = false;

    final url = EndPoints.getImage(widget.url);

    final appPath = EndPoints.localPath;
    final cleanKey = _assetCacheManager.extractRelativePath(url);
    final path = '$appPath/$cleanKey';
    final xfile = File(path);
    if (xfile.existsSync() && xfile.lengthSync() > 0) {
      _cachedFilePath = path;
      // Show the cached image immediately; resolve the aspect ratio (header
      // decode only) in the background so it never gates the first paint.
      if (!mounted || token != _loadToken) return;
      _resetRetryState();
      _isLoading.value = false;
      if (widget.height == null && widget.width == null) {
        await _resolveDisplaySize(path, token);
      }
      return;
    }

    if (widget.url.isEmpty) {
      // Genuinely no source: not a transient failure, so never retry — fall
      // straight to the placeholder.
      widget.detectError?.call();
      if (!mounted || token != _loadToken) return;
      _isError.value = true;
      _isLoading.value = false;
      return;
    }

    try {
      final file = await _assetCacheManager.getCachedAsset(widget.url);
      if (token != _loadToken) return; // superseded by a newer load
      if (file != null) {
        _cachedFilePath = file.path;
        if (!mounted || token != _loadToken) return;
        _resetRetryState();
        _isError.value = false;
        _isLoading.value = false;
        if (widget.height == null && widget.width == null) {
          await _resolveDisplaySize(file.path, token);
        }
      } else {
        // Download failed (timeout / network error on a slow connection).
        // detectError is only signalled once retries are exhausted so callers
        // aren't told the image failed while we are still trying.
        if (!mounted || token != _loadToken) return;
        final exhausted = _retryCount >= _maxRetries;
        if (exhausted) widget.detectError?.call();
        _onLoadFailed();
      }
    } catch (_) {
      if (!mounted || token != _loadToken) return;
      final exhausted = _retryCount >= _maxRetries;
      if (exhausted) widget.detectError?.call();
      _onLoadFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoading,
      builder: (_, isLoading, __) {
        if (widget.isBubble == true) {
          if (!_isError.value && _cachedFilePath.isNotEmpty) {
            return _buildSuccessWidget();
          }
          return _buildBubbleFallback();
        }

        if (isLoading && !(widget.isFromRoom ?? false)) {
          if (widget.isStopLoadingAndError == true) {
            if (widget.isRoomProfile == true) {
              return Center(child: _buildShimmer());
            } else {
              return _buildShimmer();
            }
          } else {
            return const SizedBox();
          }
        }

        return ValueListenableBuilder<bool>(
          valueListenable: _isError,
          builder: (_, isError, __) {
            if (widget.isStopForProfileRoom == false) {
              if (!isError && _cachedFilePath.isNotEmpty) {
                return _buildSuccessWidget();
              } else {
                if (widget.isGift ?? false) {
                  return const SizedBox.shrink();
                }
                return _buildErrorWidget();
              }
            } else {
              return const SizedBox();
            }
          },
        );
      },
    );
  }

  ImageProvider _resizedImage() {
    final file = FileImage(File(_cachedFilePath));
    // Effective display size in logical pixels (caller-passed or auto-computed).
    final displayWidth = widget.width ?? _imageWidth;
    final displayHeight = widget.height ?? _imageHeight;
    // Unknown size: never guess a tiny target (would blur) — decode as-is.
    if (displayWidth == null && displayHeight == null) return file;
    // Decode at exactly the physical pixels the screen will paint.
    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2.0;
    // Non-finite dimensions (Infinity from unbounded constraints / double.infinity
    // callers, or NaN from a zero-sized source) would crash .ceil() with
    // "Unsupported operation: Infinity or NaN toInt" — skip resizing that axis.
    // Non-positive targets (a 0/0-derived dimension is finite but invalid) are
    // rejected by ResizeImage, so treat them as "no target" too.
    final scaledWidth = (displayWidth == null || !displayWidth.isFinite)
        ? null
        : (displayWidth * dpr).ceil();
    final scaledHeight = (displayHeight == null || !displayHeight.isFinite)
        ? null
        : (displayHeight * dpr).ceil();
    final cacheWidth = (scaledWidth != null && scaledWidth > 0) ? scaledWidth : null;
    final cacheHeight =
    (scaledHeight != null && scaledHeight > 0) ? scaledHeight : null;
    // Neither axis is a usable target: decode the file as-is.
    if (cacheWidth == null && cacheHeight == null) return file;
    // policy: fit => decode preserves the source aspect ratio inside the target
    // box, so the widget's BoxFit.cover still center-crops correctly (the default
    // 'exact' policy would squish non-matching aspect ratios before cover runs).
    // allowUpscaling:false => never decode above source (memory only, no blur).
    return ResizeImage(
      file,
      width: cacheWidth,
      height: cacheHeight,
      allowUpscaling: false,
      policy: ResizeImagePolicy.fit,
    );
  }

  Widget _buildSuccessWidget() {
    return Container(
      height: widget.height ?? _imageHeight,
      width: widget.width ?? _imageWidth,
      margin: widget.margin,
      padding: widget.padding,
      decoration: BoxDecoration(
        shape: widget.shape ?? BoxShape.rectangle,
        borderRadius: widget.shape == BoxShape.circle
            ? null
            : BorderRadius.circular(widget.radius ?? 0),
        image: DecorationImage(
          fit: widget.boxFit ?? BoxFit.cover,
          scale: widget.scale ?? 1,
          image: _resizedImage(),
          onError: (exception, stackTrace) {
            // Corrupt/invalid cached bytes => codec fails during paint.
            // Delete the bad file so the next build re-downloads it, then
            // fall back to the error widget. Deferred past the current frame
            // (cannot mutate state during paint) and guarded for mounted.
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (!mounted) return;
              await _assetCacheManager.evict(widget.url);
              if (!mounted) return;

              // The bad bytes are gone; fetch them again before giving up.
              if (!_refetchedAfterCorruptCache) {
                _refetchedAfterCorruptCache = true;
                _cachedFilePath = '';
                _resetRetryState();
                _loadImage();
                return;
              }

              widget.detectError?.call();
              _isError.value = true;
            });
          },
        ),
      ),
      child: widget.child,
    );
  }

  Widget _buildErrorWidget() {
    final name = widget.displayName?.trim() ?? '';
    final errorSize = widget.widthError ?? widget.width ?? widget.height ?? 60;
    // Fallback precedence on empty/failed image:
    //  1. displayName != null  -> AVATAR with a known name -> InitialsAvatar
    //     (even an empty name renders '?'), NEVER the brand logo.
    //  2. isRoomCover          -> neutral RoomCoverPlaceholder.
    //  3. fallbackToLogo       -> genuine brand-logo slot keeps the app logo.
    //  4. default              -> neutral PersonPlaceholder (grey circle +
    //     person glyph). A photoless user/image NEVER shows the brand logo.
    final Widget errorContainer = widget.displayName != null
        ? Container(
      height: widget.heightError ?? widget.height,
      width: widget.widthError ?? widget.width,
      margin: widget.margin,
      padding: widget.padding,
      decoration: BoxDecoration(
        border: widget.border,
        shape: widget.shape ?? BoxShape.rectangle,
        borderRadius: widget.shape == BoxShape.circle
            ? null
            : BorderRadius.circular(widget.radius ?? 0),
      ),
      clipBehavior: Clip.antiAlias,
      child: InitialsAvatar(
        name: name,
        size: errorSize,
        borderRadius: widget.shape == BoxShape.circle
            ? null
            : BorderRadius.circular(widget.radius ?? 0),
      ),
    )
        : widget.isRoomCover
        ? RoomCoverPlaceholder(
      width: widget.widthError ?? widget.width,
      height: widget.heightError ?? widget.height,
      radius: widget.radius,
      shape: widget.shape,
      margin: widget.margin,
      padding: widget.padding,
      border: widget.border,
    )
        : widget.fallbackToLogo
        ? Container(
      height: widget.heightError ?? widget.height,
      width: widget.widthError ?? widget.width,
      margin: widget.margin,
      padding: widget.padding,
      decoration: BoxDecoration(
        border: widget.border,
        shape: widget.shape ?? BoxShape.rectangle,
        borderRadius: widget.shape == BoxShape.circle
            ? null
            : BorderRadius.circular(widget.radius ?? 0),
        image: DecorationImage(
          colorFilter: const ColorFilter.mode(
            ColorManager.grey,
            BlendMode.color,
          ),
          fit: widget.boxFit ?? BoxFit.cover,
          image: AssetImage(AssetsManager.logo),
        ),
      ),
    )
        : PersonPlaceholder(
      width: widget.widthError ?? widget.width,
      height: widget.heightError ?? widget.height,
      radius: widget.radius,
      shape: widget.shape,
      margin: widget.margin,
      padding: widget.padding,
      border: widget.border,
    );
    if (!widget.canRetry) return errorContainer;
    return GestureDetector(
      onTap: () {
        // Manual tap = fresh attempt cycle: restore the full retry budget so
        // the user-initiated load isn't immediately short-circuited.
        _resetRetryState();
        _loadImage();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          errorContainer,
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.refresh,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubbleFallback() {
    return Container(
      height: widget.height,
      width: widget.width,
      margin: widget.margin,
      padding: widget.padding,
      decoration: BoxDecoration(
        borderRadius: 8.radius,
        color: const Color(0xFFD9D9D9).withValues(alpha: 0.25),
      ),
      child: widget.child,
    );
  }

  Widget _buildShimmer() {
    final shimmer = Shimmer.fromColors(
      baseColor: ColorManager.baseColor,
      highlightColor: ColorManager.highlightColor,
      child: Container(
        height: widget.heightLoading ?? widget.height,
        width: widget.widthLoading ?? widget.width,
        decoration: BoxDecoration(
          shape: widget.shape ?? BoxShape.rectangle,
          color: Colors.grey[300],
          borderRadius: widget.shape == BoxShape.circle
              ? null
              : BorderRadius.circular(widget.radius ?? 0),
        ),
      ),
    );
    if (!widget.showLoadingIndicator) return shimmer;
    return Stack(
      alignment: Alignment.center,
      children: [
        shimmer,
        const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: ColorManager.grey,
          ),
        ),
      ],
    );
  }
}