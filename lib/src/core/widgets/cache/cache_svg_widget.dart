import 'dart:io';
import 'package:shimmer/shimmer.dart';
import 'package:general/src/core/cache/svg_cache_manager.dart';
import 'package:general/src/core/index.dart';

class CacheSvgWidget extends StatefulWidget {
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
  final String? displayName;

  /// When true the empty/failed fallback keeps the BRAND APP LOGO. Defaults to
  /// FALSE so a photoless image NEVER shows the brand logo — the generic
  /// fallback is the neutral [PersonPlaceholder]. Set true ONLY at genuine
  /// brand-logo slots. [displayName] (initials) still takes precedence.
  final bool fallbackToLogo;

  const CacheSvgWidget({
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
    this.displayName,
    this.fallbackToLogo = false,
  });

  @override
  State<CacheSvgWidget> createState() => _CacheSvgWidgetState();
}

class _CacheSvgWidgetState extends State<CacheSvgWidget> {
  final _svgCacheManager = SvgCacheManager();
  final _isLoading = ValueNotifier<bool>(true);
  final _isError = ValueNotifier<bool>(false);

  String _cachedFilePath = '';
  File? _cachedFile;

  @override
  void initState() {
    super.initState();
    // Synchronous disk-cache hit: an already-cached SVG paints on the first
    // frame with no shimmer flash and no async re-resolve (the owner's "loads
    // every time" complaint). Only the cache MISS falls through to _loadSvg().
    if (_trySyncCacheHit()) {
      _isLoading.value = false;
      return;
    }
    _loadSvg();
  }

  /// Resolves the on-disk cache path for [widget.url] WITHOUT any await and,
  /// if the file already exists with content, records it. Returns true on a hit.
  bool _trySyncCacheHit() {
    final raw = widget.url.trim();
    if (raw.isEmpty || !raw.toLowerCase().endsWith('.svg')) return false;
    try {
      final url = EndPoints.getImage(raw);
      final path =
          '${EndPoints.localPath}/${_svgCacheManager.extractRelativePath(url)}';
      final f = File(path);
      if (f.existsSync() && f.lengthSync() > 0) {
        _cachedFilePath = path;
        _cachedFile = f;
        return true;
      }
    } catch (_) {}
    return false;
  }

  @override
  void didUpdateWidget(covariant CacheSvgWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.url != oldWidget.url) _loadSvg();
  }

  Future<void> _loadSvg() async {
    _isLoading.value = true;
    _isError.value = false;

    final url = EndPoints.getImage(widget.url);

    if (widget.url.isEmpty) {
      widget.detectError?.call();
      _isError.value = true;
      _isLoading.value = false;
      return;
    }

    try {
      final file = await _svgCacheManager.getCachedSvg(url);
      if (file != null && await file.exists()) {
        _cachedFilePath = file.path;
        _cachedFile = file;
        _isError.value = false;
      } else {
        widget.detectError?.call();
        _isError.value = true;
      }
    } catch (_) {
      widget.detectError?.call();
      _isError.value = true;
    } finally {
      _isLoading.value = false;
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

  Widget _buildSuccessWidget() {
    return Container(
      height: widget.height,
      width: widget.width,
      margin: widget.margin,
      padding: widget.padding,
      decoration: BoxDecoration(
        shape: widget.shape ?? BoxShape.rectangle,
        border: widget.border,
        borderRadius: widget.shape == BoxShape.circle
            ? null
            : BorderRadius.circular(widget.radius ?? 0),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          SvgPicture.file(
            _cachedFile!,
            fit: widget.boxFit ?? BoxFit.contain,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    // displayName != null marks an AVATAR context: fall back to the user's
    // initials (InitialsAvatar), never the app logo. Generic (non-avatar) SVGs
    // pass no displayName and keep the logo placeholder.
    if (widget.displayName != null) {
      final errorSize =
          widget.widthError ?? widget.width ?? widget.height ?? 60;
      return Container(
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
          name: widget.displayName!.trim(),
          size: errorSize,
          borderRadius: widget.shape == BoxShape.circle
              ? null
              : BorderRadius.circular(widget.radius ?? 0),
        ),
      );
    }
    // Genuine brand-logo slot: keep the app logo. Otherwise the generic
    // fallback is the neutral PersonPlaceholder — never the brand logo.
    if (!widget.fallbackToLogo) {
      return PersonPlaceholder(
        width: widget.widthError ?? widget.width,
        height: widget.heightError ?? widget.height,
        radius: widget.radius,
        shape: widget.shape,
        margin: widget.margin,
        padding: widget.padding,
        border: widget.border,
      );
    }
    return Container(
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
          fit: widget.boxFit ?? BoxFit.contain,
          colorFilter: const ColorFilter.mode(
            ColorManager.grey,
            BlendMode.srcIn,
          ),
          image: AssetImage(AssetsManager.logo),
        ),
      ),
      child: widget.child,
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
    return Shimmer.fromColors(
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
  }
}
