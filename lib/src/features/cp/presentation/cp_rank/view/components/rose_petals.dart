import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Rose petals drifting down over the CP ranking header art. Purely
/// decorative: ignores touches and fills whatever box it is given.
class RosePetals extends StatefulWidget {
  const RosePetals({super.key, this.count = 20});

  final int count;

  @override
  State<RosePetals> createState() => _RosePetalsState();
}

class _RosePetalsState extends State<RosePetals>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat();

  late final List<_Petal> _petals = List.generate(widget.count, (i) {
    final r = math.Random(i * 7919 + 13);
    return _Petal(
      x: r.nextDouble(),
      phase: r.nextDouble(),
      speed: 0.6 + r.nextDouble() * 0.8,
      size: 9 + r.nextDouble() * 9,
      sway: 0.02 + r.nextDouble() * 0.04,
      spin: (r.nextBool() ? 1 : -1) * (0.5 + r.nextDouble()),
      shade: r.nextInt(_PetalPainter.colors.length),
    );
  });

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _PetalPainter(_petals, _clock),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _Petal {
  const _Petal({
    required this.x,
    required this.phase,
    required this.speed,
    required this.size,
    required this.sway,
    required this.spin,
    required this.shade,
  });

  final double x; // 0..1 across the width
  final double phase; // start offset in the fall cycle
  final double speed; // falls per clock cycle
  final double size;
  final double sway; // side-to-side drift, fraction of width
  final double spin; // turns per cycle
  final int shade;
}

class _PetalPainter extends CustomPainter {
  _PetalPainter(this.petals, this.clock) : super(repaint: clock);

  final List<_Petal> petals;
  final Animation<double> clock;

  static const colors = [
    [Color(0xFFFF5C8A), Color(0xFFFFA3BE)],
    [Color(0xFFE8335F), Color(0xFFFF8FAF)],
    [Color(0xFFFF7FA6), Color(0xFFFFD0DE)],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final t = clock.value;
    for (final p in petals) {
      final progress = (p.phase + t * p.speed) % 1.0;
      // Start just above the box, finish just below it.
      final y = -p.size + progress * (size.height + p.size * 2);
      final x = (p.x + math.sin((progress + p.phase) * math.pi * 2) * p.sway) *
          size.width;
      // Fade out over the last fifth so petals melt into the page.
      final fade = progress > 0.8 ? (1 - progress) / 0.2 : 1.0;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * math.pi * 2 * p.spin);
      // Squash on one axis so the petal seems to tumble.
      canvas.scale(1, 0.55 + 0.45 * math.cos(progress * math.pi * 4).abs());

      final s = p.size;
      final path = Path()
        ..moveTo(0, -s / 2)
        ..cubicTo(s * 0.55, -s * 0.45, s * 0.5, s * 0.35, 0, s / 2)
        ..cubicTo(-s * 0.5, s * 0.35, -s * 0.55, -s * 0.45, 0, -s / 2)
        ..close();
      final shade = colors[p.shade];
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            shade[0].withValues(alpha: 0.9 * fade),
            shade[1].withValues(alpha: 0.8 * fade),
          ],
        ).createShader(Rect.fromCenter(center: Offset.zero, width: s, height: s));
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PetalPainter old) => false;
}
