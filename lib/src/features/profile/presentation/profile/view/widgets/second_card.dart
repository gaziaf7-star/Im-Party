part of 'package:general/src/features/profile/presentation/profile/view/profile_screen.dart';

/// SVIP banner on the Me page: the `svipimage.png` artwork with twinkling
/// stars, glinting coins and a light sweep across it. Taps open SVIP.
class SecondCard extends StatefulWidget {
  const SecondCard({super.key});

  @override
  State<SecondCard> createState() => _SecondCardState();
}

class _SecondCardState extends State<SecondCard>
    with SingleTickerProviderStateMixin {
  static const String _art = 'assets/icons/ui_icons/svipimage.png';
  static const double _aspect = 804 / 257;

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  /// Sparkles laid over the artwork's own stars (x, y as fractions of the
  /// image, size as a fraction of its height, phase offset 0..1).
  static const List<(double, double, double, double)> _stars = [
    // Over the artwork's own stars.
    (0.245, 0.10, 0.22, 0.00),
    (0.355, 0.30, 0.18, 0.35),
    (0.950, 0.50, 0.20, 0.62),
    (0.030, 0.47, 0.16, 0.18),
    (0.880, 0.86, 0.15, 0.80),
    // Extra ones across the banner and around the wallet.
    (0.555, 0.22, 0.13, 0.50),
    (0.105, 0.08, 0.15, 0.27),
    (0.300, 0.62, 0.12, 0.70),
    (0.480, 0.78, 0.12, 0.08),
    (0.640, 0.32, 0.11, 0.88),
    (0.700, 0.80, 0.12, 0.42),
    (0.780, 0.18, 0.14, 0.15),
    (0.990, 0.22, 0.12, 0.55),
    (0.060, 0.80, 0.13, 0.92),
    (0.150, 0.55, 0.11, 0.60),
    (0.420, 0.18, 0.11, 0.75),
  ];

  /// Quick glints on the gold coins.
  static const List<(double, double, double, double)> _coins = [
    (0.190, 0.37, 0.17, 0.10),
    (0.395, 0.62, 0.16, 0.45),
    (0.330, 0.80, 0.16, 0.72),
    (0.425, 0.86, 0.14, 0.28),
    (0.255, 0.30, 0.14, 0.90),
    (0.145, 0.33, 0.13, 0.55),
    (0.225, 0.40, 0.12, 0.20),
    (0.365, 0.58, 0.13, 0.83),
    (0.300, 0.88, 0.13, 0.35),
    (0.410, 0.72, 0.12, 0.62),
    (0.350, 0.70, 0.11, 0.05),
    (0.270, 0.78, 0.12, 0.48),
  ];

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// 0 -> 1 -> 0 over the part of the cycle starting at [phase].
  double _pulse(double phase, {double width = .35}) {
    final t = (_c.value - phase) % 1.0;
    if (t > width) return 0;
    final half = width / 2;
    return t < half ? t / half : (width - t) / half;
  }

  Widget _sparkle(
    double w,
    double h,
    (double, double, double, double) s, {
    required Color color,
    double width = .35,
  }) {
    final (x, y, size, phase) = s;
    final v = _pulse(phase, width: width);
    if (v <= 0) return const SizedBox.shrink();
    final d = h * size * (0.55 + 0.45 * v);
    return Positioned(
      left: w * x - d / 2,
      top: h * y - d / 2,
      width: d,
      height: d,
      child: Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.rotate(
          angle: v * 0.6,
          child: CustomPaint(painter: _StarPainter(color)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.paddingSymmetric(horizontal: 12),
      child: Semantics(
        button: true,
        label: StringManager.svip.tr(),
        child: GestureDetector(
          onTap: () => context.pushNamedRoute(Routes.vipScreen),
          behavior: HitTestBehavior.opaque,
          child: AspectRatio(
            aspectRatio: _aspect,
            child: LayoutBuilder(
              builder: (context, box) {
                final w = box.maxWidth, h = box.maxHeight;
                return AnimatedBuilder(
                  animation: _c,
                  builder: (context, _) {
                    // Light sweep: a soft diagonal band crossing the art in
                    // the first ~45% of each cycle, clipped to the artwork.
                    final sweep = (_c.value / .45).clamp(0.0, 1.0);
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: ShaderMask(
                            blendMode: BlendMode.srcATop,
                            shaderCallback: (rect) => LinearGradient(
                              begin: const Alignment(-1, -.6),
                              end: const Alignment(1, .6),
                              colors: [
                                Colors.white.withValues(alpha: 0),
                                Colors.white.withValues(alpha: .7),
                                Colors.white.withValues(alpha: 0),
                              ],
                              stops: const [.42, .5, .58],
                              transform: _SweepTransform(sweep * 2.4 - 1.2),
                            ).createShader(rect),
                            child: Image.asset(_art, fit: BoxFit.fill),
                          ),
                        ),
                        for (final s in _stars)
                          _sparkle(w, h, s, color: Colors.white, width: .42),
                        for (final s in _coins)
                          _sparkle(w, h, s,
                              color: const Color(0xFFFFF6C2), width: .26),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SweepTransform extends GradientTransform {
  const _SweepTransform(this.t);
  final double t;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * t, 0, 0);
}

/// Four-point twinkle star with a soft glow.
class _StarPainter extends CustomPainter {
  const _StarPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final r = size.width / 2;
    final k = r * .18; // waist of the star
    final path = Path()
      ..moveTo(cx, cy - r)
      ..quadraticBezierTo(cx + k, cy - k, cx + r, cy)
      ..quadraticBezierTo(cx + k, cy + k, cx, cy + r)
      ..quadraticBezierTo(cx - k, cy + k, cx - r, cy)
      ..quadraticBezierTo(cx - k, cy - k, cx, cy - r)
      ..close();
    canvas.drawCircle(
      Offset(cx, cy),
      r * .45,
      Paint()
        ..color = color.withValues(alpha: .55)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * .35),
    );
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _StarPainter old) => old.color != color;
}
