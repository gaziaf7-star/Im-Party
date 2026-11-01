import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/component/seat_config/seat_metrics.dart';
import 'package:general/src/features/room/presentation/room_controls/room_controls.dart';

/// The red mute circle at the bottom-right of a seat.
class SeatMuteIcon extends StatelessWidget {
  final double avatarSize;

  const SeatMuteIcon({super.key, required this.avatarSize});

  @override
  Widget build(BuildContext context) {
    final m = SeatMetrics.forAvatar(avatarSize);
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        width: m.micCircle,
        height: m.micCircle,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ColorManager.onDark,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Image.asset(
          AssetsManager.muteUser,
          color: ColorManager.redIcons,
          width: m.micInner,
          height: m.micInner,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

/// Shows [SeatMuteIcon] on an empty or locked seat while All Mute is on.
/// Must be placed inside a Stack.
class AllMuteSeatBadge extends StatelessWidget {
  final double avatarSize;

  const AllMuteSeatBadge({super.key, required this.avatarSize});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<RoomControlsState>(
      valueListenable: RoomControls.instance.state,
      builder:
          (context, s, _) =>
              s.allMute
                  ? SeatMuteIcon(avatarSize: avatarSize)
                  : const SizedBox.shrink(),
    );
  }
}
