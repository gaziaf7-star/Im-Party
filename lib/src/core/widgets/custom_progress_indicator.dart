import 'package:flutter/material.dart';

class CustomProgressIndicator extends StatelessWidget {
  final double progress; // 0.0 → 1.0
  final double height;
  final Color backgroundColor;
  final Color progressColor;
  final Widget? indicator;
  final Duration duration;
  final Curve curve;

  const CustomProgressIndicator({
    super.key,
    required this.progress,
    this.height = 12,
    this.backgroundColor = Colors.grey,
    this.progressColor = Colors.blue,
    this.indicator,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOut,
  });

  @override
  Widget build(BuildContext context) {
    final targetProgress = progress.clamp(0.0, 1.0);

    // 🔥 Detect current text direction (English = LTR, Arabic = RTL)
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;

        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: targetProgress),
          duration: duration,
          curve: curve,
          builder: (context, animatedProgress, child) {
            final iconSize =
                (indicator is Icon) ? (indicator as Icon).size ?? 24.0 : 24.0;

            // 🔥 Adjust indicator position depending on RTL/LTR
            final left = isRTL
                ? (barWidth - iconSize) * (1 - animatedProgress)
                : (barWidth - iconSize) * animatedProgress;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // background bar
                Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                ),
                // progress fill
                Align(
                  alignment:
                      isRTL ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    height: height,
                    width: barWidth * animatedProgress,
                    decoration: BoxDecoration(
                      color: progressColor,
                      borderRadius: BorderRadius.circular(height / 2),
                    ),
                  ),
                ),
                // indicator (optional)
                if (indicator != null)
                  Positioned(
                    left: left,
                    top: -(iconSize / 2 - height / 5),
                    child: indicator!,
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
