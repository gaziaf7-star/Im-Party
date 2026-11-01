import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svga/flutter_svga.dart';
import 'package:general/src/core/cache/asset_preview_prefetch.dart';
import 'package:general/src/core/cache/svga_movie_cache.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/mall_bag/mall_bag.dart';

/// Shared look of the Store (Mall) and My Items (Bag) pages: near-black
/// page, podium artwork on top, lilac pill tabs and buttons, checker cards.
class StoreColors {
  static const Color bg = Color(0xFF07060B);
  static const Color lilacA = Color(0xFFCBB8FF);
  static const Color lilacB = Color(0xFFA77DFF);
  static const Color lilac = Color(0xFFB596FF);
  static const Color tabIdle = Color(0xFF8F8C9C);
  static const Color gold = Color(0xFFFFD66B);
  static const List<Color> button = [lilacA, lilacB];
}

/// What the podium needs to show an item, from either a store ware or a
/// backpack item.
class StorePreview {
  const StorePreview({
    required this.id,
    required this.name,
    this.image,
    this.svg,
    this.imageType,
  });

  factory StorePreview.mall(MallEntity e) => StorePreview(
        id: 'mall_${e.id}',
        name: e.name ?? '',
        image: e.image,
        svg: e.svg,
        imageType: e.imageType,
      );

  factory StorePreview.bag(MyBagEntity e) => StorePreview(
        id: 'bag_${e.id}',
        name: e.name ?? '',
        image: e.image,
        svg: e.svg,
        imageType: e.imageType,
      );

  final String id;
  final String name;
  final String? image;
  final String? svg;
  final String? imageType;

  TestMallBagParam get param =>
      TestMallBagParam(image: image, svg: svg, type: imageType, name: name);

  AssetPreviewSource get source => TestItemsController.sourceOf(param);
}

/// Background downloads of item animations (3 at a time, each file once), so
/// the podium can play them right away instead of waiting on tap.
class StoreWarmer {
  final Set<String> _queued = {};

  void warm(Iterable<StorePreview> items) {
    final queue = <AssetPreviewSource>[];
    for (final it in items) {
      final src = it.source;
      if (!src.isAnimated || !_queued.add(src.url)) continue;
      queue.add(src);
    }
    if (queue.isEmpty) return;
    Future<void> worker() async {
      while (queue.isNotEmpty) {
        final src = queue.removeAt(0);
        try {
          await AssetPreviewPrefetch.ensureCached(src);
        } catch (_) {
          _queued.remove(src.url);
        }
      }
    }

    for (var i = 0; i < 3; i++) {
      worker();
    }
  }
}

/// Opens the full-screen preview (frame on your avatar, entry over the
/// screen...), downloading the file first. [onProgress] gets 0..1 while
/// downloading and null when done.
Future<void> openStorePreview(
  BuildContext context,
  StorePreview item,
  MallOrBagType type, {
  required void Function(double? progress) onProgress,
}) async {
  final source = item.source;
  if (await AssetPreviewPrefetch.cachedFile(source) == null &&
      source.isPlayable) {
    onProgress(0);
    await AssetPreviewPrefetch.ensureCached(
      source,
      onProgress: (received, total) {
        if (total > 0) onProgress(received / total);
      },
    );
    onProgress(null);
  }
  if (!context.mounted) return;
  TestItemsController.instance.onMallCardTap(context, item.param, type);
}

/// Top of the page: the podium artwork (`mall top image.png`) fading into
/// the page at the bottom, the item playing above the podium and its name on
/// the podium's front.
class StoreStage extends StatelessWidget {
  const StoreStage({
    super.key,
    required this.item,
    required this.type,
    required this.progress,
    required this.onPreview,
  });

  final StorePreview? item;
  final MallOrBagType type;
  final double? progress;
  final VoidCallback? onPreview;

  static const String _art = 'assets/icons/ui_icons/mall top image.png';

  /// Width / height of the artwork (1344 × 1170).
  static const double _artAspect = 1344 / 1170;

  @override
  Widget build(BuildContext context) {
    final w = ScreenUtil().screenWidth;
    final h = w / _artAspect;
    final topInset = MediaQuery.of(context).padding.top + kToolbarHeight;
    final it = item;
    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              _art,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              filterQuality: FilterQuality.medium,
            ),
          ),
          // Bottom of the artwork melts into the page colour.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: h * .16,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, StoreColors.bg],
                ),
              ),
            ),
          ),
          // Name on the podium's front face (≈ 78–88 % of the artwork).
          Positioned(
            left: w * .14,
            right: w * .14,
            top: h * .785,
            height: h * .09,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  it?.name ?? '',
                  key: ValueKey(it?.id),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFFE6E6EE),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    letterSpacing: .2,
                  ),
                ),
              ),
            ),
          ),
          // The item, standing on the podium's top surface (≈ 70 %).
          Positioned(
            left: w * .12,
            right: w * .12,
            top: topInset,
            bottom: h * .29,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: ScaleTransition(
                  scale: Tween(begin: .82, end: 1.0).animate(
                    CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                  ),
                  child: child,
                ),
              ),
              child: it == null
                  ? const SizedBox.shrink()
                  : LayoutBuilder(
                      key: ValueKey('stage_${it.id}'),
                      builder: (context, c) => GestureDetector(
                        onTap: onPreview,
                        child: SizedBox(
                          width: c.maxWidth,
                          height: c.maxHeight,
                          child: _StageAnimation(
                            item: it,
                            type: type,
                            box: Size(c.maxWidth, c.maxHeight),
                          ),
                        ),
                      )
                          .animate(onPlay: (a) => a.repeat(reverse: true))
                          .moveY(
                            begin: -3,
                            end: 3,
                            duration: const Duration(milliseconds: 1900),
                            curve: Curves.easeInOut,
                          ),
                    ),
            ),
          ),
          // Full-screen preview, small and out of the way.
          if (it != null)
            Positioned(
              right: 14.w,
              top: topInset + 2.h,
              child: GestureDetector(
                onTap: onPreview,
                child: Container(
                  width: 32.w,
                  height: 32.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: .08),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: .14)),
                  ),
                  child: progress == null
                      ? Icon(Icons.fullscreen_rounded,
                          color: Colors.white70, size: 20.sp)
                      : SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 2,
                            color: StoreColors.lilac,
                          ),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The item on the podium. Frames, bubbles, IDs... loop their animation; an
/// entry plays once and then rests on its still image.
class _StageAnimation extends StatelessWidget {
  const _StageAnimation({
    required this.item,
    required this.type,
    required this.box,
  });

  final StorePreview item;
  final MallOrBagType type;
  final Size box;

  @override
  Widget build(BuildContext context) {
    final source = item.source;
    final still = ImageViewWidget(
      url: item.image ?? '',
      width: box.width,
      height: box.height,
      boxFit: BoxFit.contain,
    );
    if (!source.isPlayable) return still;
    if (type == MallOrBagType.intro) {
      return source.kind == AssetPreviewKind.svga
          ? _PlayOnceSvga(url: source.url, still: still)
          : still;
    }
    return TestItemsController.buildPreview(
      source,
      width: box.width,
      height: box.height,
    );
  }
}

/// Plays an SVGA a single time, then cross-fades to [still]. The still also
/// shows while the file loads, so the podium is never empty.
class _PlayOnceSvga extends StatefulWidget {
  const _PlayOnceSvga({required this.url, required this.still});
  final String url;
  final Widget still;

  @override
  State<_PlayOnceSvga> createState() => _PlayOnceSvgaState();
}

class _PlayOnceSvgaState extends State<_PlayOnceSvga>
    with SingleTickerProviderStateMixin {
  SVGAAnimationController? _controller;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _play();
  }

  Future<void> _play() async {
    try {
      final movie = await SvgaMovieCache.instance
          .loadFromUrl(EndPoints.getImage(widget.url));
      if (!mounted) return;
      if (movie == null) {
        setState(() => _done = true);
        return;
      }
      final controller = SVGAAnimationController(vsync: this)
        ..videoItem = movie;
      setState(() => _controller = controller);
      await controller.forward().orCancel;
    } catch (_) {
      // Cancelled (widget closed) or a bad file: fall back to the still.
    }
    if (mounted) setState(() => _done = true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playing = _controller != null && !_done;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: playing
          ? SVGAImage(
              _controller!,
              key: const ValueKey('playing'),
              fit: BoxFit.contain,
              clearsAfterStop: false,
            )
          : KeyedSubtree(key: const ValueKey('still'), child: widget.still),
    );
  }
}

/// Horizontal pill tabs; the selected one is a lilac pill and is scrolled
/// into view.
class StoreTabBar extends StatefulWidget {
  const StoreTabBar({
    super.key,
    required this.labels,
    required this.selected,
    required this.onTap,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onTap;

  @override
  State<StoreTabBar> createState() => _StoreTabBarState();
}

class _StoreTabBarState extends State<StoreTabBar> {
  late List<GlobalKey> _keys =
      List.generate(widget.labels.length, (_) => GlobalKey());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
  }

  @override
  void didUpdateWidget(covariant StoreTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.labels.length != widget.labels.length) {
      _keys = List.generate(widget.labels.length, (_) => GlobalKey());
    }
    if (oldWidget.selected != widget.selected) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
    }
  }

  void _reveal() {
    if (widget.selected < 0 || widget.selected >= _keys.length) return;
    final ctx = _keys[widget.selected].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: .5,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34.h,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Row(
          children: [
            for (var i = 0; i < widget.labels.length; i++)
              Padding(
                key: _keys[i],
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: GestureDetector(
                  onTap: () => widget.onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    height: 30.h,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22.r),
                      gradient: i == widget.selected
                          ? const LinearGradient(colors: StoreColors.button)
                          : null,
                    ),
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 240),
                      style: TextStyle(
                        color: i == widget.selected
                            ? Colors.white
                            : StoreColors.tabIdle,
                        fontSize: 13.sp,
                        fontWeight: i == widget.selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                      child: Text(widget.labels[i]),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Store / backpack card: fine dark checker background with a warm glow at
/// the bottom, a hairline border that is light purple at the top-right,
/// light gold at the bottom-left and fades away at the other two corners
/// (thick lilac when selected), the item, its name, and a [footer] line.
class StoreItemCard extends StatelessWidget {
  const StoreItemCard({
    super.key,
    required this.image,
    required this.name,
    required this.selected,
    required this.onTap,
    this.footer,
    this.badge,
  });

  final String image;
  final String name;
  final bool selected;
  final VoidCallback onTap;
  final Widget? footer;

  /// Small marker in the top-left corner (e.g. "In use").
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final radius = 20.r;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: selected ? 1.0 : .97,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          // The outer box is the border: a gradient seen through the padding.
          padding: EdgeInsets.all(selected ? 2.6 : 1.1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: selected
                ? const LinearGradient(
                    colors: [StoreColors.lilacA, StoreColors.lilacB],
                  )
                : const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(0xFFC3AEFF),
                      Color(0x667A62D6),
                      Color(0x0F2A2733),
                      Color(0x0F2A2733),
                      Color(0x66B88A4E),
                      Color(0xFFF0C27E),
                    ],
                    stops: [0, .22, .42, .58, .78, 1],
                  ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: StoreColors.lilacB.withValues(alpha: .45),
                      blurRadius: 16,
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius - 1.5),
            child: Stack(
              children: [
                const Positioned.fill(
                  child: ColoredBox(color: Color(0xFF0D0C11)),
                ),
                Positioned.fill(
                  child: CustomPaint(painter: _CheckerPainter()),
                ),
                // Warm glow rising from the bottom edge.
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          const Color(0xFF4A2412).withValues(alpha: .70),
                          const Color(0xFF26140C).withValues(alpha: .30),
                          Colors.transparent,
                        ],
                        stops: const [0, .3, .62],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(6.w, 10.h, 6.w, 8.h),
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: ImageViewWidget(
                            url: image,
                            width: 90.w,
                            height: 80.h,
                            boxFit: BoxFit.contain,
                          ),
                        ),
                      ),
                      6.hBox,
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (footer != null) ...[
                        4.hBox,
                        FittedBox(fit: BoxFit.scaleDown, child: footer),
                      ],
                    ],
                  ),
                ),
                if (badge != null)
                  Positioned(left: 7.w, top: 7.h, child: badge!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Fine, faint checkerboard over the whole card, a little softer towards the
/// bottom.
class _CheckerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cell = 4.0;
    final paint = Paint();
    for (var y = 0.0; y < size.height; y += cell) {
      final fade = 1 - .55 * (y / size.height).clamp(0.0, 1.0);
      paint.color = const Color(0xFF24232C).withValues(alpha: .75 * fade);
      final odd = (y / cell).floor().isOdd;
      for (var x = odd ? cell : 0.0; x < size.width; x += cell * 2) {
        canvas.drawRect(Rect.fromLTWH(x, y, cell, cell), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Pill button: lilac gradient, or dark with a lilac outline; shrinks a
/// little while pressed.
class StorePillButton extends StatefulWidget {
  const StorePillButton({
    super.key,
    required this.child,
    required this.onTap,
    required this.enabled,
    this.outlined = false,
  });

  final Widget child;
  final VoidCallback onTap;
  final bool enabled;
  final bool outlined;

  @override
  State<StorePillButton> createState() => _StorePillButtonState();
}

class _StorePillButtonState extends State<StorePillButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedScale(
        scale: _down ? .96 : 1,
        duration: const Duration(milliseconds: 120),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: widget.enabled ? 1 : .45,
          child: Container(
            height: 42.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28.r),
              color: widget.outlined ? const Color(0xFF15131C) : null,
              gradient: widget.outlined
                  ? null
                  : const LinearGradient(colors: StoreColors.button),
              border: widget.outlined
                  ? Border.all(color: StoreColors.lilac, width: 1.4)
                  : null,
              boxShadow: widget.outlined
                  ? null
                  : [
                      BoxShadow(
                        color: StoreColors.lilacB.withValues(alpha: .35),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Staggered fade + scale-in for grid cards.
extension StoreCardEntrance on Widget {
  Widget storeEntrance(int index) => animate(
        delay: Duration(milliseconds: 35 * index.clamp(0, 12)),
      )
          .fadeIn(duration: const Duration(milliseconds: 280))
          .scaleXY(
            begin: .92,
            end: 1,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
          );
}
