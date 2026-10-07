import 'package:flutter/material.dart';

import '../constants/enums.dart';

class MDIndicator extends Decoration {
  final double indicatorHeight;
  final Color? indicatorColor;
  final Gradient? indicatorGradient;
  final MDIndicatorSize indicatorSize;
  final double? indicatorWidth;
  final double radius;

  const MDIndicator({
    required this.indicatorHeight,
    this.indicatorSize = MDIndicatorSize.full,
    this.indicatorColor,
    this.indicatorGradient,
    this.radius = 0,
    this.indicatorWidth,
  }) : assert(indicatorColor != null || indicatorGradient != null,
            'Either indicatorColor or indicatorGradient must be provided');

  @override
  MDPainter createBoxPainter([VoidCallback? onChanged]) {
    return MDPainter(this, onChanged!);
  }
}

class MDPainter extends BoxPainter {
  final MDIndicator decoration;

  MDPainter(this.decoration, VoidCallback onChanged) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);

    Rect? rect;
    double width = decoration.indicatorWidth ?? configuration.size!.width;

    double dx = offset.dx + (configuration.size!.width - width) / 2;

    if (decoration.indicatorSize == MDIndicatorSize.full) {
      rect = Offset(
              dx, (configuration.size!.height - decoration.indicatorHeight)) &
          Size(width, decoration.indicatorHeight);
    } else if (decoration.indicatorSize == MDIndicatorSize.normal) {
      rect = Offset(dx + 6,
              (configuration.size!.height - decoration.indicatorHeight)) &
          Size(width - 12, decoration.indicatorHeight);
    } else if (decoration.indicatorSize == MDIndicatorSize.tiny) {
      rect = Offset(dx + configuration.size!.width / 2 - 8,
              (configuration.size!.height - decoration.indicatorHeight)) &
          Size(16, decoration.indicatorHeight);
    }

    final Paint paint = Paint()..style = PaintingStyle.fill;

    if (decoration.indicatorGradient != null) {
      paint.shader = decoration.indicatorGradient!.createShader(rect!);
    } else {
      paint.color = decoration.indicatorColor!;
    }

    canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect!,
          topRight: Radius.circular(decoration.radius),
          topLeft: Radius.circular(decoration.radius),
          bottomRight: Radius.circular(decoration.radius),
          bottomLeft: Radius.circular(decoration.radius),
        ),
        paint);
  }
}
