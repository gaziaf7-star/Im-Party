import 'package:general/src/core/index.dart';
import 'package:utd_live_room_kit/utd_live_room_kit.dart' as live;

/// A circular control button used by the live room's bottom bar and "more"
/// sheet. Live-room only — styled from the live kit theme when available, with a
/// translucent fallback so it stays legible over the host video.
class LiveControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  /// Overrides the glyph color (e.g. danger red for a muted mic).
  final Color? iconColor;
  final double size;

  /// Small count badge (e.g. pending speaker requests). Hidden when `0`.
  final int badgeCount;

  /// When set, the button is rendered with a caption below it (used by the
  /// "more" sheet's labelled actions).
  final String? label;

  const LiveControlButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.size = 44,
    this.badgeCount = 0,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = live.UTDRoomScope.maybeOf(context)?.theme;
    // Same visual language as the audio room's bar buttons
    // (CircleAvatar 19.5r, black 10% tile, white icon 24sp) -- tile
    // background changed from light-white to light-black to match.
    final fg = iconColor ?? theme?.onSurface ?? Colors.white;

    final button = Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: 19.5.r,
            backgroundColor: Colors.black.withValues(alpha: 0.1),
            child: Icon(icon, color: fg, size: 24.sp),
          ),
        ),
        if (badgeCount > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: BoxDecoration(
                color: theme?.pendingBadge ?? ColorManager.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$badgeCount',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
      ],
    );

    if (label == null) return button;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        button,
        6.hBox,
        Text(label!, style: context.bodySmall.colorExt(Colors.white).size(12)),
      ],
    );
  }
}