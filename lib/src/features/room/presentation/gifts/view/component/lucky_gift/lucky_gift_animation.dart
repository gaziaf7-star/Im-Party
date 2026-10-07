import 'dart:developer';

import 'package:general/src/core/index.dart';
import 'package:general/src/core/utils/lucky_log.dart';
import 'package:general/src/features/room/presentation/gifts/controller/lucky_gift_controller.dart';

/// Exposes a stable, full-screen overlay [GlobalKey] to descendant
/// [LuckyGiftSeatAnimation]s. The host (foreground_widget) attaches this same
/// key to a `Positioned.fill` Stack, so its RenderBox always spans the entire
/// overlay. The flying candy converts GLOBAL seat coordinates into THIS box's
/// local space, which is exactly the space its own `Positioned(left, top)` is
/// laid out in — eliminating the fragile per-item `context.findRenderObject()`
/// conversion that collapsed to zero-size once all children became Positioned.
class LuckyOverlayAnchor extends InheritedWidget {
  final GlobalKey overlayKey;

  const LuckyOverlayAnchor({
    super.key,
    required this.overlayKey,
    required super.child,
  });

  static GlobalKey? of(BuildContext context) {
    final anchor =
        context.dependOnInheritedWidgetOfExactType<LuckyOverlayAnchor>();
    return anchor?.overlayKey;
  }

  @override
  bool updateShouldNotify(LuckyOverlayAnchor oldWidget) =>
      overlayKey != oldWidget.overlayKey;
}

class LuckyGiftSeatAnimation extends StatefulWidget {
  final String? img;
  final double? left;
  final double? right;
  final List<SeatPosition> seatPosition;
  final int numberOfCircles;

  const LuckyGiftSeatAnimation({
    super.key,
    this.img = "",
    this.left,
    this.right,
    required this.seatPosition,
    required this.numberOfCircles,
  });

  @override
  LuckyGiftSeatAnimationState createState() => LuckyGiftSeatAnimationState();
}

class LuckyGiftSeatAnimationState extends State<LuckyGiftSeatAnimation>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _moveController;

  final Duration bounceDuration = const Duration(milliseconds: 150);
  final Duration moveDuration = const Duration(milliseconds: 600);

  final List<Animation<Offset>> _animations = [];
  final List<Animation<double>> _sizeAnimations = [];
  final List<Animation<double>> _opacityAnimations = [];

  late Animation<double> _bounceScale;
  bool _isBounceCompleted = false;
  ValueNotifier<int> luckyGiftAnimationWidgetsRebuild = ValueNotifier(0);

  // One-shot diagnostic guard: log the first converted frame per seat only,
  // so logcat shows the resolved coordinate space without flooding at 60fps.
  bool _loggedFirstFrame = false;

  @override
  void initState() {
    super.initState();
    log('🎁 LUCKYFLY: animation mounted — circles=${widget.numberOfCircles}, '
        'seatPositions(global)=${widget.seatPosition.map((p) => '(${p.x.toStringAsFixed(1)},${p.y.toStringAsFixed(1)})').toList()}, '
        'img=${widget.img}');
    LuckyLog.write('LUCKYFLY: animation mounted — circles=${widget.numberOfCircles}, '
        'seatPositions(global)=${widget.seatPosition.map((p) => '(${p.x.toStringAsFixed(1)},${p.y.toStringAsFixed(1)})').toList()}, '
        'img=${widget.img}');

    _bounceController = AnimationController(
      duration: bounceDuration,
      vsync: this,
    );

    _bounceScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _moveController = AnimationController(
      duration: moveDuration,
      vsync: this,
    );

    for (int i = 0; i < widget.numberOfCircles; ++i) {
      final double endX = widget.seatPosition[i].x;
      final double endY = widget.seatPosition[i].y;

      // Begin/end are GLOBAL screen coords. They are converted to the overlay's
      // local space per-frame in the builder using the stable overlay RenderBox.
      _animations.add(
        Tween<Offset>(
          begin: Offset(
            ScreenUtil().screenWidth / 3,
            ScreenUtil().screenHeight / 3,
          ),
          end: Offset(endX, endY),
        ).animate(
          CurvedAnimation(
            parent: _moveController,
            curve: Curves.easeOutCubic,
          ),
        ),
      );

      _sizeAnimations.add(
        Tween<double>(begin: 130.h, end: 30.h).animate(
          CurvedAnimation(parent: _moveController, curve: Curves.easeOutCubic),
        ),
      );

      _opacityAnimations.add(
        Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(
            parent: _moveController,
            curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
          ),
        ),
      );
    }

    _bounceController.forward().whenComplete(() {
      if (!mounted) return;
      setState(() {
        _isBounceCompleted = true;
      });
      _moveController.forward().whenComplete(() {
        luckyGiftAnimationWidgetsRebuild.value++;
      });
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _moveController.dispose();
    super.dispose();
  }

  /// Resolves the stable overlay RenderBox (the full-screen `Positioned.fill`
  /// host keyed by [LuckyOverlayAnchor]). Converting global → this box's local
  /// space yields coordinates in exactly the space our `Positioned` children
  /// are laid out in, regardless of where the UTD kit mounts the foreground.
  RenderBox? _overlayBox() {
    final overlayKey = LuckyOverlayAnchor.of(context);
    final renderObject = overlayKey?.currentContext?.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      return renderObject;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: luckyGiftAnimationWidgetsRebuild,
      builder: (context, show, _) {
        if (show != 0) return const SizedBox();

        // SizedBox.expand pins this layer to the full overlay so its origin
        // matches the overlay box origin even after every child becomes
        // Positioned (a bare Stack would collapse to zero-size here).
        return SizedBox.expand(
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              if (!_isBounceCompleted)
                Center(
                  child: ScaleTransition(
                    scale: _bounceScale,
                    child: widget.img == ""
                        ? const CircleAvatar(
                            backgroundColor: Colors.yellow,
                            radius: 90,
                          )
                        : ImageViewWidget(
                            width: 130.w,
                            height: 130.h,
                            radius: 90.r,
                            boxFit: BoxFit.fill,
                            url: widget.img ?? "",
                            isFromRoom: true,
                            isGift: true,
                          ),
                  ),
                ),
              if (_isBounceCompleted)
                ...List.generate(widget.numberOfCircles, (index) {
                  return AnimatedBuilder(
                    animation: _moveController,
                    builder: (context, child) {
                      final animationValue = _animations[index].value;
                      final size = _sizeAnimations[index].value;
                      final opacity = _opacityAnimations[index].value;

                      // Convert the animated GLOBAL offset into the stable
                      // overlay box's local space. This box is the full-screen
                      // host, so its local space == the space these Positioned
                      // children sit in. If the box is not ready yet (first
                      // frame), fall back to raw global coords (overlay origin
                      // is screen origin in the common case).
                      final RenderBox? overlayBox = _overlayBox();
                      final Offset localOffset = overlayBox != null
                          ? overlayBox.globalToLocal(animationValue)
                          : animationValue;

                      if (!_loggedFirstFrame) {
                        _loggedFirstFrame = true;
                        log('🎁 LUCKYFLY: first move frame — overlayBox='
                            '${overlayBox == null ? 'NULL(using raw global)' : 'size=${overlayBox.size}'}, '
                            'targetGlobal=(${_animations[index].value.dx.toStringAsFixed(1)},${_animations[index].value.dy.toStringAsFixed(1)}), '
                            'startLocal=(${localOffset.dx.toStringAsFixed(1)},${localOffset.dy.toStringAsFixed(1)})');
                        LuckyLog.write('LUCKYFLY: first move frame — overlayBox='
                            '${overlayBox == null ? 'NULL(using raw global)' : 'size=${overlayBox.size}'}, '
                            'targetGlobal=(${_animations[index].value.dx.toStringAsFixed(1)},${_animations[index].value.dy.toStringAsFixed(1)}), '
                            'startLocal=(${localOffset.dx.toStringAsFixed(1)},${localOffset.dy.toStringAsFixed(1)})');
                      }

                      final left = localOffset.dx;
                      final top = localOffset.dy;

                      return Positioned(
                        left: left,
                        top: top,
                        child: Opacity(
                          opacity: opacity,
                          child: widget.img == ""
                              ? const CircleAvatar(
                                  backgroundColor: Colors.yellow,
                                  radius: 23.0,
                                )
                              : ImageViewWidget(
                                  width: size,
                                  height: size,
                                  radius: 50.r,
                                  boxFit: BoxFit.fill,
                                  url: widget.img ?? "",
                                  isFromRoom: true,
                                  isGift: true,
                                ),
                        ),
                      );
                    },
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}
