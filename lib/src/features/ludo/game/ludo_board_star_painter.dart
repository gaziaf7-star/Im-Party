import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Helper painter for rendering metallic star safe zone badges on Ludo board tracks.
class LudoBoardStarPainter {
  static void drawStar(
    Canvas canvas,
    Offset center,
    double radius, [
    Color starColor = const Color(0xFFFFD700),
  ]) {
    final path = Path();
    const points = 5;
    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : radius * 0.45;
      final angle = (i * math.pi / points) - math.pi / 2;
      final dx = center.dx + r * math.cos(angle);
      final dy = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black45
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    final paintFill = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFE082),
          starColor,
          Color.lerp(starColor, Colors.black, 0.35)!,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawPath(path, paintFill);

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white70
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }
}
