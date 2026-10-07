import 'package:flutter/material.dart';

class MultiTapCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Duration tapDelay;

  const MultiTapCard({
    super.key,
    required this.child,
    required this.onTap,
    this.tapDelay = const Duration(milliseconds: 300),
  });

  @override
  // ignore: library_private_types_in_public_api
  _MultiTapCardState createState() => _MultiTapCardState();
}

class _MultiTapCardState extends State<MultiTapCard> {
  DateTime? lastTapTime;
  void _handleTap() {
    final now = DateTime.now();

    if (lastTapTime != null) {
      if ((now.difference(lastTapTime!).inMilliseconds < 2500)) {
        return;
      }
    }
    lastTapTime = now;
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: widget.child,
    );
  }
}
