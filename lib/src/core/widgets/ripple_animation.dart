import 'dart:async';
import 'package:flutter/material.dart';

class RippleAnimation extends StatefulWidget {
  const RippleAnimation({
    required this.child,
    this.color = Colors.black,
    this.delay = Duration.zero,
    this.repeat = false,
    this.minRadius = 60,
    this.maxRadius = 120,
    this.ripplesCount = 5,
    this.borderRadius = 0.0,
    this.duration = const Duration(milliseconds: 2300),
    super.key,
  });

  final Widget child;
  final Duration delay;
  final double minRadius;
  final double maxRadius;
  final double borderRadius;
  final Color color;
  final int ripplesCount;
  final Duration duration;
  final bool repeat;

  @override
  RippleAnimationState createState() => RippleAnimationState();
}

class RippleAnimationState extends State<RippleAnimation>
    with TickerProviderStateMixin<RippleAnimation> {
  AnimationController? _controller;

  @override
  void initState() {
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    Timer? animationTimer;

    animationTimer = Timer(widget.delay, () {
      if (_controller != null && mounted) {
        widget.repeat ? _controller!.repeat() : _controller!.forward();
      }
      animationTimer?.cancel();
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: CirclePainter(
      _controller,
      color: widget.color,
      minRadius: widget.minRadius,
      maxRadius: widget.maxRadius,
      wavesCount: widget.ripplesCount + 2,
      borderRadius: widget.borderRadius,
    ),
    child: widget.child,
  );
}

class CirclePainter extends CustomPainter {
  CirclePainter(
      this.animation, {
        required this.wavesCount,
        required this.color,
        this.minRadius,
        this.maxRadius,
        this.borderRadius = 0.0,
      }) : super(repaint: animation);

  final Color color;
  final double? minRadius;
  final double? maxRadius;
  final double borderRadius;
  final int wavesCount;
  final Animation<double>? animation;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTRB(0, 0, size.width, size.height);
    for (int wave = 0; wave <= wavesCount; wave++) {
      roundedContainer(
        canvas,
        rect,
        minRadius,
        maxRadius,
        wave,
        animation!.value,
        wavesCount,
        color,
        borderRadius,
      );
    }
  }

  void roundedContainer(
      Canvas canvas,
      Rect rect,
      double? minRadius,
      double? maxRadius,
      int wave,
      double value,
      int? length,
      Color containerColor,
      double borderRadius,
      ) {
    Color color = containerColor;
    if (wave != 0) {
      final double opacity =
      ((1 - ((wave - 1) / length!) - value) * 3.0).clamp(0.0, 1.0);
      color = color.withValues(alpha: (opacity ));



      final double sizeFactor = minRadius! + ((maxRadius! - minRadius) * value);
      final double r = sizeFactor * (1 + (wave * value)) * value;

      final RRect rRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: rect.center,
          width: r,
          height: r,
        ),
        Radius.circular(borderRadius),
      );

      final Paint paint = Paint()..color = color;
      canvas.drawRRect(rRect, paint);
    }
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate)=>true;
}
