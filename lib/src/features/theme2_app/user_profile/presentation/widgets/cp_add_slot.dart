import 'package:general/src/core/index.dart';

/// The CP "Add" slot: a glossy pink glass tile in a gold frame with heart
/// gems (top middle, bottom corners), a soft pink glow and a light sweep.
class CpAddSlot extends StatefulWidget {
  const CpAddSlot({super.key, required this.label});

  final String label;

  @override
  State<CpAddSlot> createState() => _CpAddSlotState();
}

class _CpAddSlotState extends State<CpAddSlot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        // Glow breathes a little; the shine crosses in the first 40%.
        final breathe = 0.5 + 0.5 * (1 - (2 * _c.value - 1).abs());
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF4F9A)
                    .withValues(alpha: 0.25 + 0.25 * breathe),
                blurRadius: 10 + 8 * breathe,
                spreadRadius: 0.5,
              ),
            ],
          ),
          child: CustomPaint(
            painter: _GlassTilePainter(shine: _c.value),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 34.sp,
                    shadows: const [
                      Shadow(
                        color: Color(0x99C2185B),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      shadows: const [
                        Shadow(
                          color: Color(0x99C2185B),
                          blurRadius: 4,
                          offset: Offset(0, 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GlassTilePainter extends CustomPainter {
  _GlassTilePainter({required this.shine});

  /// 0..1 animation phase.
  final double shine;

  static const _goldLight = Color(0xFFFFF0B3);
  static const _gold = Color(0xFFF4C34E);
  static const _goldDeep = Color(0xFFB9781C);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final frameW = (w * 0.055).clamp(3.0, 7.0);
    final outer = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(w * 0.2),
    );
    final inner = outer.deflate(frameW);

    // 1. Pink glass body: light top, rich pink bottom (3D depth).
    canvas.drawRRect(
      inner,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFC2DE), Color(0xFFFF6FB2), Color(0xFFFF3E8A)],
          stops: [0.0, 0.55, 1.0],
        ).createShader(inner.outerRect),
    );
    // Inner shade along the bottom edge.
    canvas.drawRRect(
      inner,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.center,
          colors: [
            const Color(0xFFB0115E).withValues(alpha: 0.35),
            Colors.transparent,
          ],
        ).createShader(inner.outerRect),
    );

    canvas.save();
    canvas.clipRRect(inner);
    // 2. Glass gloss: bright curved highlight over the top half.
    final gloss = Path()
      ..moveTo(inner.left, inner.top)
      ..lineTo(inner.right, inner.top)
      ..lineTo(inner.right, inner.top + inner.height * 0.30)
      ..quadraticBezierTo(inner.center.dx, inner.top + inner.height * 0.52,
          inner.left, inner.top + inner.height * 0.30)
      ..close();
    canvas.drawPath(
      gloss,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.65),
            Colors.white.withValues(alpha: 0.08),
          ],
        ).createShader(inner.outerRect),
    );
    // 3. Moving light sweep (first 40% of the cycle).
    final t = (shine / 0.4).clamp(0.0, 1.0);
    if (t > 0 && t < 1) {
      final x = inner.left - w * 0.6 + t * (w * 1.8);
      final band = Path()
        ..moveTo(x, inner.top)
        ..lineTo(x + w * 0.22, inner.top)
        ..lineTo(x - w * 0.18, inner.bottom)
        ..lineTo(x - w * 0.40, inner.bottom)
        ..close();
      canvas.drawPath(
        band,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.38)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
    canvas.restore();

    // 4. Gold frame with a bright inner rim.
    final goldShader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [_goldLight, _gold, _goldDeep, _gold, _goldLight],
      stops: [0.0, 0.3, 0.55, 0.8, 1.0],
    ).createShader(Offset.zero & size);
    canvas.drawRRect(
      outer.deflate(frameW / 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = frameW
        ..shader = goldShader,
    );
    canvas.drawRRect(
      inner.inflate(0.6),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = _goldLight.withValues(alpha: 0.9),
    );
    // Gold swoosh curls along the top corners.
    final curl = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = frameW * 0.55
      ..strokeCap = StrokeCap.round
      ..shader = goldShader;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.10, h * 0.18)
        ..quadraticBezierTo(w * 0.12, h * 0.03, w * 0.32, h * 0.04),
      curl,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.90, h * 0.18)
        ..quadraticBezierTo(w * 0.88, h * 0.03, w * 0.68, h * 0.04),
      curl,
    );

    // 5. Heart gems: top middle and the two bottom corners.
    final r = w * 0.085;
    _heart(canvas, Offset(w / 2, frameW * 0.6), r * 1.1);
    _heart(canvas, Offset(w * 0.13, h - frameW * 0.9), r);
    _heart(canvas, Offset(w * 0.87, h - frameW * 0.9), r);
  }

  void _heart(Canvas canvas, Offset c, double r) {
    final p = Path()
      ..moveTo(c.dx, c.dy + r * 0.85)
      ..cubicTo(c.dx - r * 1.3, c.dy - r * 0.05, c.dx - r * 0.75, c.dy - r * 1.05,
          c.dx, c.dy - r * 0.45)
      ..cubicTo(c.dx + r * 0.75, c.dy - r * 1.05, c.dx + r * 1.3, c.dy - r * 0.05,
          c.dx, c.dy + r * 0.85)
      ..close();
    final bounds = Rect.fromCircle(center: c, radius: r * 1.3);
    canvas.drawPath(
      p,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD1E6), Color(0xFFFF4F9A), Color(0xFFB0115E)],
        ).createShader(bounds),
    );
    canvas.drawPath(
      p,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = _gold,
    );
    canvas.drawCircle(
      c.translate(-r * 0.35, -r * 0.35),
      r * 0.16,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(covariant _GlassTilePainter old) => old.shine != shine;
}
