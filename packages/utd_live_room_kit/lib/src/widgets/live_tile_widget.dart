import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

import '../theme/utd_room_theme.dart';
import 'live_avatar_waves.dart';

/// A single live video tile.
///
/// Used full-bleed for the host and as a floating square for guests. Renders
/// [track] via [VideoTrackRenderer] when [isCameraOn] and a track is available;
/// otherwise it shows an avatar/initials placeholder over [theme]'s background.
///
/// The widget does NOT store a track across frames — the caller resolves the
/// current [VideoTrack] each build and passes it in. Give the tile a stable
/// `key` (by occupant identity) so the underlying renderer is reused rather than
/// recreated, which would flicker (VideoTrackRenderer auto-disposes its
/// RTCVideoRenderer).
class UTDLiveTile extends StatelessWidget {
  final String displayName;
  final String? avatarUrl;
  final VideoTrack? track;

  /// Whether the occupant's camera is on. When false (or [track] is null) the
  /// placeholder is shown instead of the video.
  final bool isCameraOn;

  /// Whether the occupant's mic is muted (drives the mic-off badge).
  final bool isMicMuted;

  /// Whether the occupant is actively speaking (drives the speaking border).
  final bool isSpeaking;

  final VideoViewFit fit;
  final VideoViewMirrorMode mirrorMode;

  /// Occupant role: 'host' | 'admin' | 'guest' | … . Drives the role badge.
  final String? role;

  final UTDRoomTheme theme;

  /// Whether to render a host/admin role badge (top-start).
  final bool showRoleBadge;

  /// Whether to draw the speaking border. Disabled for the full-bleed host tile.
  final bool showSpeakingBorder;

  /// Radius of the placeholder avatar (full diameter = 2× this).
  final double avatarRadius;

  /// Where the camera-off avatar sits inside the tile. Guest tiles keep it
  /// centered; the full-bleed host tile raises it so it doesn't fight the
  /// chat overlay at mid-screen.
  final AlignmentGeometry avatarAlignment;

  final BorderRadius borderRadius;
  final VoidCallback? onTap;

  const UTDLiveTile({
    super.key,
    required this.displayName,
    required this.theme,
    this.avatarUrl,
    this.track,
    this.isCameraOn = false,
    this.isMicMuted = false,
    this.isSpeaking = false,
    this.fit = VideoViewFit.cover,
    this.mirrorMode = VideoViewMirrorMode.off,
    this.role,
    this.showRoleBadge = true,
    this.showSpeakingBorder = true,
    this.avatarRadius = 40,
    this.avatarAlignment = Alignment.center,
    this.borderRadius = BorderRadius.zero,
    this.onTap,
  });

  bool get _hasVideo => isCameraOn && track != null;

  @override
  Widget build(BuildContext context) {
    final Widget content = _hasVideo
        ? VideoTrackRenderer(track!, fit: fit, mirrorMode: mirrorMode)
        : Align(
            alignment: avatarAlignment,
            child: UTDAvatarWaves(
              url: avatarUrl,
              name: displayName,
              size: avatarRadius * 2,
              theme: theme,
              isSpeaking: isSpeaking,
            ),
          );

    final stack = Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: theme.background)),
        Positioned.fill(child: content),
        if (showRoleBadge && _badgeColor != null)
          Positioned(top: 8, left: 8, child: _roleBadge()),
      ],
    );

    final tile = Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: (showSpeakingBorder && isSpeaking)
            ? Border.all(color: theme.seatRingSpeaking, width: 2.5)
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: stack,
    );

    if (onTap == null) return tile;
    return GestureDetector(onTap: onTap, child: tile);
  }

  /// Badge color for host/admin only; null => no badge.
  Color? get _badgeColor {
    switch (role) {
      case 'host':
        return theme.badgeHost;
      case 'admin':
        return theme.badgeAdmin;
      default:
        return null;
    }
  }

  Widget _roleBadge() {
    final label = role == 'host' ? 'HOST' : 'ADMIN';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _badgeColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
