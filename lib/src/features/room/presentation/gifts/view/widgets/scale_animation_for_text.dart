import 'package:flutter/material.dart';

class TextScaleAnimation extends StatefulWidget {
  final String text;

  const TextScaleAnimation({super.key, required this.text});

  @override
  TextScaleAnimationState createState() => TextScaleAnimationState();
}

class TextScaleAnimationState extends State<TextScaleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 2,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _controller.reset();

    _controller.forward();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Text(
            widget.text,
            // Keep the combo count (e.g. x31968) on ONE line — inside the narrow
            // countdown circle it was wrapping to two lines. Allow it to overflow
            // horizontally rather than wrap.
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.visible,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: "BungeeSpice",
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
