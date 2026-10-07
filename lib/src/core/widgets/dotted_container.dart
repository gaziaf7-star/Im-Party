import 'dart:ui';

import 'package:flutter/material.dart';

class DashedBorderContainer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color borderColor;
  final double strokeWidth;
  final Widget? child;

  const DashedBorderContainer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 5,
    this.borderColor = Colors.grey,
    this.strokeWidth = 2,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        radius: borderRadius,
        borderColor: borderColor,
        strokeWidth: strokeWidth,
      ),
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final double radius;
  final Color borderColor;
  final double strokeWidth;

  _DashedBorderPainter({
    required this.radius,
    required this.borderColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    const dashWidth = 6.0;
    const dashSpace = 4.0;

    Path path = Path()..addRRect(rect);
    PathMetrics pathMetrics = path.computeMetrics();

    for (var metric in pathMetrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final extractedPath =
            metric.extractPath(distance, distance + dashWidth);
        canvas.drawPath(extractedPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
