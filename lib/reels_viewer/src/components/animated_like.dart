part of 'package:general/reels_viewer/src/reels_viewer.dart';

/// One transient heart spawned by a double-tap "like" at a recorded position.
/// Each heart owns its own controller and removes itself once its animation
/// completes, allowing several to float concurrently (TikTok-style burst).
class _BurstHeart {
  _BurstHeart({required this.id, required this.position, required this.angle});

  final int id;
  final Offset position;

  /// Slight, deterministic rotation per heart so concurrent hearts fan out.
  final double angle;
}

/// Renders a list of active [_BurstHeart]s; the parent ([_ReelsWidgetState])
/// owns the list + controllers and adds a heart at the tap [Offset] on a
/// double-tap. Multiple hearts may animate at once.
class _HeartBurstLayer extends StatelessWidget {
  const _HeartBurstLayer({required this.hearts});

  final List<_HeartBurstEntry> hearts;

  @override
  Widget build(BuildContext context) {
    if (hearts.isEmpty) return const SizedBox.shrink();
    return IgnorePointer(
      child: Stack(
        children: [
          for (final entry in hearts) _AnimatedBurstHeart(entry: entry),
        ],
      ),
    );
  }
}

/// Pairs a [_BurstHeart] with the controller driving its float-up/fade-out.
class _HeartBurstEntry {
  _HeartBurstEntry({required this.heart, required this.controller});

  final _BurstHeart heart;
  final AnimationController controller;
}

class _AnimatedBurstHeart extends StatelessWidget {
  const _AnimatedBurstHeart({required this.entry});

  final _HeartBurstEntry entry;

  @override
  Widget build(BuildContext context) {
    final controller = entry.controller;
    final heart = entry.heart;
    final size = 100.w;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = controller.value;
        // Pop in fast (first ~18%), then float up and fade out.
        final scale = t < 0.18
            ? Curves.easeOutBack.transform(t / 0.18)
            : 1.0 - (0.15 * ((t - 0.18) / 0.82));
        final opacity = t < 0.7 ? 1.0 : (1.0 - (t - 0.7) / 0.3);
        final dy = -120.h * Curves.easeOut.transform(t);

        return Positioned(
          left: heart.position.dx - size / 2,
          top: heart.position.dy - size / 2,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, dy),
              child: Transform.rotate(
                angle: heart.angle,
                child: Transform.scale(
                  scale: scale.clamp(0.0, 1.2),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
      child: Image.asset(
        AssetsManager.reelsLiked,
        width: size,
        height: size,
        color: ColorManager.red,
      ),
    );
  }
}
