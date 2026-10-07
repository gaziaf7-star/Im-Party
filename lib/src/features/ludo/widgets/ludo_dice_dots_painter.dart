import 'package:flutter/material.dart';

/// CustomPainter rendering classic dots (1-6) on Ludo 3D Dice faces.
class LudoDiceDotsPainter extends CustomPainter {
  final int value;

  LudoDiceDotsPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final darkDotPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    final redDotPaint = Paint()
      ..color = const Color(0xFFDC2626)
      ..style = PaintingStyle.fill;

    final dotRadius = size.width * 0.105;

    final left = size.width * 0.25;
    final center = size.width * 0.5;
    final right = size.width * 0.75;

    final top = size.height * 0.25;
    final middle = size.height * 0.5;
    final bottom = size.height * 0.75;

    final tl = Offset(left, top);
    final tr = Offset(right, top);
    final ml = Offset(left, middle);
    final c = Offset(center, middle);
    final mr = Offset(right, middle);
    final bl = Offset(left, bottom);
    final br = Offset(right, bottom);

    switch (value) {
      case 1:
        canvas.drawCircle(c, dotRadius * 1.35, redDotPaint);
        break;
      case 2:
        canvas.drawCircle(tl, dotRadius, darkDotPaint);
        canvas.drawCircle(br, dotRadius, darkDotPaint);
        break;
      case 3:
        canvas.drawCircle(tl, dotRadius, darkDotPaint);
        canvas.drawCircle(c, dotRadius, darkDotPaint);
        canvas.drawCircle(br, dotRadius, darkDotPaint);
        break;
      case 4:
        canvas.drawCircle(tl, dotRadius, darkDotPaint);
        canvas.drawCircle(tr, dotRadius, darkDotPaint);
        canvas.drawCircle(bl, dotRadius, darkDotPaint);
        canvas.drawCircle(br, dotRadius, darkDotPaint);
        break;
      case 5:
        canvas.drawCircle(tl, dotRadius, darkDotPaint);
        canvas.drawCircle(tr, dotRadius, darkDotPaint);
        canvas.drawCircle(c, dotRadius, darkDotPaint);
        canvas.drawCircle(bl, dotRadius, darkDotPaint);
        canvas.drawCircle(br, dotRadius, darkDotPaint);
        break;
      case 6:
        canvas.drawCircle(tl, dotRadius, darkDotPaint);
        canvas.drawCircle(tr, dotRadius, darkDotPaint);
        canvas.drawCircle(ml, dotRadius, darkDotPaint);
        canvas.drawCircle(mr, dotRadius, darkDotPaint);
        canvas.drawCircle(bl, dotRadius, darkDotPaint);
        canvas.drawCircle(br, dotRadius, darkDotPaint);
        break;
      default:
        canvas.drawCircle(c, dotRadius * 1.35, redDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant LudoDiceDotsPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
