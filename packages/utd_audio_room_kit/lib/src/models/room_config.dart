import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/utd_room_strings.dart';
import '../theme/utd_room_theme.dart';
import 'seat_layout.dart';
import 'seat_model.dart';

// Room configuration — the prebuilt live-audio-room config object
class UTDAudioRoomConfig {
  final bool showControlsBar;
  final bool showSeatNames;
  final bool enableMinimize;
  final bool turnOnMicrophoneWhenJoining;
  final bool useSpeakerWhenJoining;
  final int hostSeatIndex;

  /// Passed straight to the room's own internal Scaffold. Default (true)
  /// matches Flutter's own Scaffold default. Set false when the host app
  /// opens its comment/message composer as a SEPARATE overlay route with its
  /// own keyboard-avoiding Scaffold — otherwise both Scaffolds react to the
  /// keyboard inset at once, and the whole room (background, seats, side
  /// buttons) visibly shifts/resizes upward in addition to the composer.
  final bool resizeToAvoidBottomInset;

  /// Color tokens for the built-in default UI. Defaults to a dark theme so the
  /// (white) default content is visible without a custom background.
  final UTDRoomTheme theme;

  /// Strings for the built-in default UI. `null` => [UTDRoomStrings.en].
  final UTDRoomStrings? strings;

  /// When true (default) and no [backgroundWidget] is supplied, the room paints
  /// [theme]'s background color so default content is never white-on-white.
  final bool useDefaultBackground;

  /// When true (default), a host/admin joins with the microphone enabled even
  /// if [turnOnMicrophoneWhenJoining] is false. Set false to require an explicit
  /// [turnOnMicrophoneWhenJoining].
  final bool autoHostMic;

  /// When true (default), after connecting the host is auto-seated on
  /// [hostSeatIndex] if that seat is still empty (backend-seat fallback).
  final bool autoSeatHost;

  /// Dev-tunable seat sizing/spacing (avatar ratio, horizontal & vertical
  /// spacing, absolute seat scale). Defaults to the kit's original look. The
  /// mounted room publishes this to [UTDSeatLayout.active] so every seat-size
  /// consumer reads the same values. See [UTDSeatLayout].
  final UTDSeatLayout seatLayout;

  // Custom section widgets — null = default, custom = replaces default
  final Widget? headerWidget;
  final Widget? messagesWidget;
  final Widget? controlsBarWidget;
  final Widget? pkWidget;
  final Widget? backgroundWidget;
  final Widget? foregroundWidget;

  /// While [seatsOverrideActive] is true the seat grid is replaced by whatever
  /// [seatsOverrideBuilder] returns (used by the host app for in-room games).
  /// The builder receives the live seats, a creator for the kit's own seat
  /// widget at an index, and the seat size the current mode would use.
  final ValueListenable<bool>? seatsOverrideActive;
  final Widget Function(
    List<SeatState> seats,
    Widget Function(int seatIndex) seatCreator,
    double seatSize,
  )? seatsOverrideBuilder;

  // Custom builders for seats
  final Widget Function(SeatState seat, double size)? seatBuilder;
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

  // User attributes shared with other participants
  final Map<String, String> userInRoomAttributes;

  const UTDAudioRoomConfig({
    this.showControlsBar = true,
    this.showSeatNames = true,
    this.enableMinimize = true,
    this.turnOnMicrophoneWhenJoining = false,
    this.useSpeakerWhenJoining = true,
    this.hostSeatIndex = 0,
    this.resizeToAvoidBottomInset = true,
    this.theme = const UTDRoomTheme(),
    this.strings,
    this.useDefaultBackground = true,
    this.autoHostMic = true,
    this.autoSeatHost = true,
    this.seatLayout = UTDSeatLayout.defaults,
    this.headerWidget,
    this.messagesWidget,
    this.controlsBarWidget,
    this.pkWidget,
    this.backgroundWidget,
    this.foregroundWidget,
    this.seatsOverrideActive,
    this.seatsOverrideBuilder,
    this.seatBuilder,
    this.avatarBuilder,
    this.emptySeatBuilder,
    this.lockedSeatBuilder,
    this.userInRoomAttributes = const {},
  });

  factory UTDAudioRoomConfig.host() => const UTDAudioRoomConfig(
        turnOnMicrophoneWhenJoining: true,
      );

  factory UTDAudioRoomConfig.audience() => const UTDAudioRoomConfig(
        turnOnMicrophoneWhenJoining: false,
      );

  /// Resolves the effective strings — the supplied [strings] or English defaults.
  UTDRoomStrings resolveStrings() => strings ?? UTDRoomStrings.en();
}
