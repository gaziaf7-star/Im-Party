import 'package:flutter/material.dart';

class ArcContainerPainter extends CustomPainter {
  final Color backgroundColor;

  ArcContainerPainter({required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(_buildArcPath(size), fillPaint);
  }

  Path _buildArcPath(Size size) {
    const double arcDepth = 6.0;
    const double radius = 10.0;

    final path = Path();

    path.moveTo(0, arcDepth);
    path.quadraticBezierTo(size.width / 2, 0, size.width, arcDepth);
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(size.width, size.height, size.width - radius, size.height);
    path.lineTo(radius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);
    path.close();

    return path;
  }

  @override
  bool shouldRepaint(ArcContainerPainter oldDelegate) =>
      oldDelegate.backgroundColor != backgroundColor;
}