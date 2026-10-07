import 'package:flutter/material.dart';

/// Color tokens for the package's built-in default UI (seats, controls bar,
/// action sheets, dialogs, chat bubbles…).
///
/// Every field has a sensible dark-room default, so `const UTDRoomTheme()` is a
/// complete, usable theme out of the box. The default [background] is a dark
/// tone on purpose: the default seat/chat/header content is rendered in white,
/// so a light scaffold would make it invisible. Override individual tokens via
/// [copyWith] to rebrand without replacing whole widgets.
@immutable
class UTDRoomTheme {
  /// Full-screen room background (used when no custom `backgroundWidget` and
  /// the host video fills the screen as the base layer).
  final Color background;

  /// Surface behind grouped content (sheets header strip, badges background…).
  final Color surface;

  /// Primary foreground color for text/icons drawn over [background]/[surface].
  final Color onSurface;

  /// Accent / call-to-action color (primary buttons, links, sender name).
  final Color primary;

  /// Destructive color (leave, kick, ban, mute-on indicator).
  final Color danger;

  /// Ring drawn around a tile whose occupant is actively speaking.
  final Color seatRingSpeaking;

  /// Badge color for the host role.
  final Color badgeHost;

  /// Badge color for the admin role.
  final Color badgeAdmin;

  /// Background of the pending-requests count badge.
  final Color pendingBadge;

  /// Background of modal bottom sheets.
  final Color sheetBackground;

  /// Drag-handle color at the top of bottom sheets.
  final Color sheetHandle;

  /// Background of a chat message bubble.
  final Color bubbleBackground;

  /// Color of the sender name in a chat bubble.
  final Color bubbleSenderColor;

  /// Background of the circular icon buttons in the controls bar.
  final Color iconButtonBackground;

  const UTDRoomTheme({
    this.background = const Color(0xFF14121C),
    this.surface = const Color(0xFF1C1C28),
    this.onSurface = Colors.white,
    this.primary = const Color(0xFF6C5CE7),
    this.danger = const Color(0xFFE74C3C),
    this.seatRingSpeaking = const Color(0xFF2ECC71),
    this.badgeHost = const Color(0xFFFFA726),
    this.badgeAdmin = const Color(0xFF448AFF),
    this.pendingBadge = const Color(0xFFE74C3C),
    this.sheetBackground = const Color(0xFF1C1C1E),
    this.sheetHandle = const Color(0x4DFFFFFF),
    this.bubbleBackground = const Color(0x4D000000),
    this.bubbleSenderColor = const Color(0xFF6C5CE7),
    this.iconButtonBackground = const Color(0x66000000),
  });

  /// A ready-made dark theme (identical to the default constructor).
  static const UTDRoomTheme dark = UTDRoomTheme();

  UTDRoomTheme copyWith({
    Color? background,
    Color? surface,
    Color? onSurface,
    Color? primary,
    Color? danger,
    Color? seatRingSpeaking,
    Color? badgeHost,
    Color? badgeAdmin,
    Color? pendingBadge,
    Color? sheetBackground,
    Color? sheetHandle,
    Color? bubbleBackground,
    Color? bubbleSenderColor,
    Color? iconButtonBackground,
  }) {
    return UTDRoomTheme(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      primary: primary ?? this.primary,
      danger: danger ?? this.danger,
      seatRingSpeaking: seatRingSpeaking ?? this.seatRingSpeaking,
      badgeHost: badgeHost ?? this.badgeHost,
      badgeAdmin: badgeAdmin ?? this.badgeAdmin,
      pendingBadge: pendingBadge ?? this.pendingBadge,
      sheetBackground: sheetBackground ?? this.sheetBackground,
      sheetHandle: sheetHandle ?? this.sheetHandle,
      bubbleBackground: bubbleBackground ?? this.bubbleBackground,
      bubbleSenderColor: bubbleSenderColor ?? this.bubbleSenderColor,
      iconButtonBackground: iconButtonBackground ?? this.iconButtonBackground,
    );
  }
}
