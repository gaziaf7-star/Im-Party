import 'package:flutter/material.dart';

/// Wraps [child] (a circular avatar) and, while [active], paints a gently
/// pulsing ring around it. When inactive it is a transparent pass-through, so it
/// is cheap to keep mounted for every seat.
class UTDSpeakingRing extends StatefulWidget {
  final bool active;
  final Color color;
  final double size;
  final Widget child;

  const UTDSpeakingRing({
    super.key,
    required this.active,
    required this.color,
    required this.size,
    required this.child,
  });

  @override
  State<UTDSpeakingRing> createState() => _UTDSpeakingRingState();
}

class _UTDSpeakingRingState extends State<UTDSpeakingRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.active) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant UTDSpeakingRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.active && _controller.isAnimating) {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The tree structure is IDENTICAL whether active or not (only decoration
    // values change). Returning the bare child when inactive would change the
    // child's element slot on every speaking start/stop, tearing down and
    // re-inflating the avatar subtree (visible as an avatar flash + re-decode
    // when the image cache entry was evicted). When inactive the controller
    // is stopped at 0, so keeping the AnimatedBuilder mounted costs nothing
    // per frame.
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final active = widget.active;
        final t = active ? _controller.value : 0.0; // 0..1
        final borderWidth = active ? 1.5 + 1.5 * t : 0.0;
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // strokeAlignOutside: the pulsing ring grows OUTWARD, into the
              // slot padding around the avatar, instead of inward. The old
              // approach insetting the child by `borderWidth` shrank the avatar
              // by up to 2×borderWidth and made it visibly pulse smaller every
              // time the occupant spoke (owner report: speaking waves shrink the
              // seat image). The ring must never change the avatar's size.
              border: active
                  ? Border.all(
                      color: widget.color.withValues(alpha: 0.5 + 0.5 * t),
                      width: borderWidth,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    )
                  : null,
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.35 * t),
                        blurRadius: 6 * t,
                        spreadRadius: 2 * t,
                      ),
                    ]
                  : null,
            ),
            // The avatar fills the FULL box size with no inset, so it stays a
            // constant size whether or not the occupant is speaking. The ring
            // and glow are painted outside these bounds (see strokeAlignOutside
            // above); the parent seat must not clip them.
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
