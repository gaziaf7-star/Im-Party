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

  /// Enables Android OS-level Picture-in-Picture, *in addition to* the in-app
  /// minimize overlay above. When `true` and running on Android 12+ (API 31+),
  /// the app auto-enters a system PiP window when backgrounded (Home gesture)
  /// while the user is on the room screen. iOS and Android < 31 ignore this and
  /// keep using the minimize overlay. Defaults to `false` (no behavior change).
  final bool enableOSPip;

  /// Aspect ratio of the PiP window (numerator/denominator). Defaults to a
  /// 1:1 square, matching the audio-room look. Must satisfy Android's bounds
  /// (between 1/2.39 and 2.39/1) or PiP entry is skipped.
  final int pipAspectWidth;
  final int pipAspectHeight;

  const UTDMinimizeConfig({
    this.onClose,
    this.overlayBuilder,
    this.overlayWidth = 120,
    this.overlayHeight = 120,
    this.overlayBottomOffset = 120,
    this.overlayRightOffset = 16,
    this.roomImage,
    this.showMicToggle = true,
    this.showLeaveButton = true,
    this.soundWaveColor,
    this.borderRadius = 16,
    this.enableOSPip = false,
    this.pipAspectWidth = 1,
    this.pipAspectHeight = 1,
  });
}
