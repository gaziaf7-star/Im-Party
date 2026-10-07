import 'package:flutter/material.dart';

typedef MiniOverlayBuilder = Widget Function({
  required VoidCallback onRestore,
  required VoidCallback onClose,
});

class UTDMinimizeConfig {
  final VoidCallback? onClose;
  final MiniOverlayBuilder? overlayBuilder;
  final double overlayWidth;
  final double overlayHeight;
  final double overlayBottomOffset;
  final double overlayRightOffset;

  final String? roomImage;
  final bool showMicToggle;
  final bool showLeaveButton;
  final Color? soundWaveColor;
  final double borderRadius;

  // ── Live (video) mini-overlay / PiP ──

  /// Identity whose camera is shown in the mini-overlay and PiP (the host). The
  /// minimize/PiP composition is "host video only". Null → fall back to
  /// [roomImage] / [videoPlaceholderBuilder].
  final String? hostIdentity;

  /// When true (default), the mini-overlay and PiP render the host's live video
  /// (via [hostIdentity]) instead of the room cover. Camera-off / no-track falls
  /// back to [videoPlaceholderBuilder] or [roomImage].
  final bool showHostVideoInMini;

  /// Placeholder shown in the mini-overlay / PiP when the host's camera is off
  /// or its track is not yet available. Defaults to the [roomImage] cover.
  final Widget Function(BuildContext context)? videoPlaceholderBuilder;

  /// Enables Android OS-level Picture-in-Picture, *in addition to* the in-app
  /// minimize overlay above. When `true` and running on Android 12+ (API 31+),
  /// the app auto-enters a system PiP window when backgrounded (Home gesture)
  /// while the user is on the room screen. iOS and Android < 31 ignore this and
  /// keep using the minimize overlay. Defaults to `false` (no behavior change).
  final bool enableOSPip;

  /// Aspect ratio of the PiP window (numerator/denominator). Defaults to a
  /// 9:16 portrait (the live host-video aspect), which is within Android's
  /// bounds (between 1/2.39 and 2.39/1) — outside them, PiP entry is skipped.
  final int pipAspectWidth;
  final int pipAspectHeight;

  const UTDMinimizeConfig({
    this.onClose,
    this.overlayBuilder,
    this.overlayWidth = 120,
    this.overlayHeight = 180,
    this.overlayBottomOffset = 120,
    this.overlayRightOffset = 16,
    this.roomImage,
    this.showMicToggle = true,
    this.showLeaveButton = true,
    this.soundWaveColor,
    this.borderRadius = 16,
    this.hostIdentity,
    this.showHostVideoInMini = true,
    this.videoPlaceholderBuilder,
    this.enableOSPip = false,
    this.pipAspectWidth = 9,
    this.pipAspectHeight = 16,
  });
}
