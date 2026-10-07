import 'package:flutter/material.dart';

import '../models/seat_layout.dart';
import '../models/seat_model.dart';
import '../theme/utd_room_theme.dart';
import 'default_avatar.dart';
import 'speaking_ring.dart';

// Individual seat — accepts custom builders for avatar, empty state, foreground
class UTDSeatWidget extends StatelessWidget {
  /// When set, seat display names are painted with this gradient (the host app
  /// sets it once, e.g. to its brand gradient).
  static Gradient? nameGradient;

  final SeatState seat;
  final double? size;
  final bool isSpeaking;

  /// The participant's role (host, admin, guest, audience, visitor).
  /// Read from participant metadata `role` field.
  final String? role;

  /// True when the occupant is muted via the live RTC mute state (separate
  /// from the backend [SeatState.isMuted]); the mic-off icon shows if either is
  /// set.
  final bool isMutedLive;

  /// Whether to render the occupant's display name under the avatar (the default
  /// rendering only — custom [avatarBuilder]s draw their own).
  final bool showName;

  /// Whether this is the reserved host seat (affects nothing visually by default
  /// but is available for custom builders / future styling).
  final bool isHostSeat;

  /// Color tokens. When null, falls back to the package's historical constants.
  final UTDRoomTheme? theme;

  final VoidCallback? onTap;
  final Widget Function(SeatState seat, double size)? seatBuilder;

  /// `size` is the FULL seat slot size — identical to what [emptySeatBuilder]
  /// and [lockedSeatBuilder] receive — so all three seat states can size their
  /// content from one shared value and stay visually consistent. (The builder
  /// is responsible for any inset, e.g. drawing the avatar at `size * ratio`.)
  final Widget Function(
    String userId,
    double size,
    Map<String, String> attributes,
    bool isMuted,
    int seatIndex,
    String userName,
  )? avatarBuilder;
  final Widget Function(int index, double size)? emptySeatBuilder;
  final Widget Function(int index, double size)? lockedSeatBuilder;

  const UTDSeatWidget({
    super.key,
    required this.seat,
    this.size,
    this.isSpeaking = false,
    this.role,
    this.isMutedLive = false,
    this.showName = true,
    this.isHostSeat = false,
    this.theme,
    this.onTap,
    this.seatBuilder,
    this.avatarBuilder,
    this.emptySeatBuilder,
    this.lockedSeatBuilder,
  });

  // sizeOf (not MediaQuery.of): the full-MediaQuery dependency would rebuild
  // the seat on every keyboard-inset animation frame.
  double _resolvedSize(BuildContext context) =>
      size ?? MediaQuery.sizeOf(context).width / 6;

  bool get _isMuted => seat.isMuted || isMutedLive;

  Color get _onSurface => theme?.onSurface ?? Colors.white;
  Color get _emptyFill => theme?.seatEmptyFill ?? Colors.white.withValues(alpha: 0.4);
  Color get _ring => theme?.seatRingSpeaking ?? Colors.green;
  Color get _danger => theme?.danger ?? Colors.red;

  @override
  Widget build(BuildContext context) {
    final s = _resolvedSize(context);
    if (seatBuilder != null) {
      return GestureDetector(onTap: onTap, child: seatBuilder!(seat, s));
    }

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: s,
        height: s,
        child: seat.isOccupied
            ? _occupiedSeat(s)
            : seat.isLocked
                ? _lockedSeat(s)
                : _emptySeat(s),
      ),
    );
  }

  Widget _lockedSeat(double s) {
    if (lockedSeatBuilder != null) return lockedSeatBuilder!(seat.index, s);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: s * UTDSeatLayout.active.avatarRatio,
          height: s * UTDSeatLayout.active.avatarRatio,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme?.seatLockedFill ?? Colors.white.withValues(alpha: 0.4),
          ),
          child: Icon(Icons.lock,
              color: _onSurface.withValues(alpha: 0.6), size: s * 0.3),
        ),
        const SizedBox(height: 2),
        Text('${seat.index + 1}',
            style: TextStyle(color: _onSurface, fontSize: 10)),
      ],
    );
  }

  Widget _emptySeat(double s) {
    if (emptySeatBuilder != null) return emptySeatBuilder!(seat.index, s);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          children: [
            Container(
              width: s * UTDSeatLayout.active.avatarRatio,
              height: s * UTDSeatLayout.active.avatarRatio,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _emptyFill,
              ),
              child: Icon(Icons.mic_none,
                  color: _onSurface.withValues(alpha: 0.6), size: s * 0.3),
            ),
            // Reserved seat badge
            if (seat.isReserved)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: s * 0.22,
                  height: s * 0.22,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amber,
                  ),
                  child: Icon(Icons.star, color: Colors.white, size: s * 0.14),
                ),
              ),
          ],
        ),
        const SizedBox(height: 2),
        Text('${seat.index + 1}',
            style: TextStyle(color: _onSurface, fontSize: 10)),
      ],
    );
  }

  Widget _occupiedSeat(double s) {
    if (avatarBuilder != null) {
      // Pass the FULL slot size (same as empty/locked builders) so the app sizes
      // all three seat states from one shared ratio. The builder applies its own
      // avatar inset.
      return avatarBuilder!(
        seat.occupantUserId!,
        s,
        seat.attributes,
        _isMuted,
        seat.index,
        seat.attributes['name'] ?? '',
      );
    }

    final name = seat.attributes['name'] ?? '';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          // The speaking ring/glow paints just OUTSIDE the avatar circle (see
          // UTDSpeakingRing) — don't clip it to the avatar bounds.
          clipBehavior: Clip.none,
          children: [
            UTDSpeakingRing(
              active: isSpeaking,
              color: _ring,
              size: s * UTDSeatLayout.active.avatarRatio,
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: UTDDefaultAvatar(
                  url: seat.attributes['avatar'],
                  name: name,
                  fallbackId: seat.occupantUserId ?? '',
                  size: s * UTDSeatLayout.active.avatarRatio - 4,
                  theme: theme ?? const UTDRoomTheme(),
                ),
              ),
            ),
            // Mute indicator
            if (_isMuted)
              Positioned(
                bottom: 0,
                right: 0,
                child: Icon(Icons.mic_off, color: _danger, size: s * 0.2),
              ),
            // Reserved seat badge on occupied seat
            if (seat.isReserved)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: s * 0.22,
                  height: s * 0.22,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amber,
                  ),
                  child: Icon(Icons.star, color: Colors.white, size: s * 0.14),
                ),
              ),
            // Role badge (host/admin/guest) — bottom left
            if (role != null && _isPrivilegedRole(role!))
              Positioned(
                bottom: 0,
                left: 0,
                child: _roleBadge(s),
              ),
          ],
        ),
        // Display name (the dead `showSeatNames` config is now honored here).
        if (showName && name.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: SizedBox(
              width: s,
              child: _gradientName(
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: nameGradient == null ? _onSurface : Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _gradientName(Widget text) {
    final g = nameGradient;
    if (g == null) return text;
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => g.createShader(bounds),
      child: text,
    );
  }

  /// Whether the role should show a badge.
  bool _isPrivilegedRole(String r) {
    return r == 'host' || r == 'admin' || r == 'guest';
  }

  /// Builds a small role badge widget.
  Widget _roleBadge(double s) {
    Color badgeColor;
    String label;

    switch (role) {
      case 'host':
        badgeColor = theme?.badgeHost ?? Colors.orangeAccent;
        label = 'H';
        break;
      case 'admin':
        badgeColor = theme?.badgeAdmin ?? Colors.blueAccent;
        label = 'A';
        break;
      case 'guest':
        badgeColor = theme?.badgeGuest ?? Colors.green;
        label = 'G';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      width: s * 0.22,
      height: s * 0.22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: badgeColor,
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: s * 0.12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
