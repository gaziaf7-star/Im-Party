import 'package:flutter/material.dart';

import '../theme/utd_room_theme.dart';
import 'default_avatar.dart';

/// A circular avatar with animated "sound wave" pulse rings.
///
/// This is the camera-off representation of a live participant: their profile
/// image (or initials) in the middle, with concentric rings that expand and fade
/// outward while [isSpeaking] is true — the same concept used for the host's
/// full-screen tile and the floating guest squares when a camera is closed.
///
/// The rings only animate while speaking; when silent the widget is a plain
/// static avatar (the [AnimationController] is stopped, so it costs nothing).
class UTDAvatarWaves extends StatefulWidget {
  final String? url;
  final String name;

  /// Diameter of the central avatar in logical pixels.
  final double size;

  final UTDRoomTheme theme;

  /// Whether the occupant is actively speaking (drives the ring animation).
  final bool isSpeaking;

  /// Ring color; defaults to [UTDRoomTheme.seatRingSpeaking].
  final Color? waveColor;

  /// Number of concentric rings.
  final int waveCount;

  /// How far (as a fraction of [size]) the outermost ring expands beyond the
  /// avatar at the peak of its pulse.
  final double waveSpread;

  const UTDAvatarWaves({
    super.key,
    required this.name,
    required this.size,
    required this.theme,
    this.url,
    this.isSpeaking = false,
    this.waveColor,
    this.waveCount = 3,
    this.waveSpread = 0.85,
  });

  @override
  State<UTDAvatarWaves> createState() => _UTDAvatarWavesState();
}

class _UTDAvatarWavesState extends State<UTDAvatarWaves>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Construct eagerly here (not as a lazy `late` initializer): the avatar may
    // never speak during its lifetime, in which case a lazy controller would be
    // built for the first time inside dispose() — and constructing a Ticker
    // looks up the TickerMode ancestor of an already-deactivated element, which
    // throws "Looking up a deactivated widget's ancestor is unsafe."
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    if (widget.isSpeaking) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant UTDAvatarWaves oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSpeaking == oldWidget.isSpeaking) return;
    if (widget.isSpeaking) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatar = UTDDefaultAvatar(
      url: widget.url,
      name: widget.name,
      size: widget.size,
      theme: widget.theme,
    );

    if (!widget.isSpeaking) return avatar;

    final waveColor = widget.waveColor ?? widget.theme.seatRingSpeaking;
    // The outermost ring reaches size * (1 + waveSpread); size the layout box so
    // rings are never clipped by a tight parent constraint.
    final extent = widget.size * (1 + widget.waveSpread);

    return SizedBox(
      width: extent,
      height: extent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              for (int i = 0; i < widget.waveCount; i++)
                _ring(i, waveColor),
              child!,
            ],
          );
        },
        child: avatar,
      ),
    );
  }

  Widget _ring(int index, Color color) {
    // Stagger each ring's phase so they pulse in sequence.
    final phase = (_controller.value + index / widget.waveCount) % 1.0;
    final scale = 1.0 + (phase * widget.waveSpread);
    final opacity = (1.0 - phase).clamp(0.0, 1.0) * 0.55;
    return Transform.scale(
      scale: scale,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withValues(alpha: opacity),
            width: 2.5,
          ),
        ),
      ),
    );
  }
}
