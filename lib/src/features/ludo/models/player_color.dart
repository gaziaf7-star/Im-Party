import 'package:flutter/material.dart';

/// The four Ludo players, ordered clockwise starting from Green (or Red).
enum PlayerColor { green, yellow, blue, red }

extension PlayerColorX on PlayerColor {
  /// Main board color matching the user design specification.
  Color get baseColor {
    switch (this) {
      case PlayerColor.red:
        return const Color(0xFFFF3B4D);
      case PlayerColor.green:
        return const Color(0xFF18C96E);
      case PlayerColor.yellow:
        return const Color(0xFFFFC928);
      case PlayerColor.blue:
        return const Color(0xFF287BFF);
    }
  }

  /// Lighter tint used for quadrant background square.
  Color get lightColor {
    switch (this) {
      case PlayerColor.red:
        return const Color(0xFFFF8B97);
      case PlayerColor.green:
        return const Color(0xFF81F0B4);
      case PlayerColor.yellow:
        return const Color(0xFFFFE682);
      case PlayerColor.blue:
        return const Color(0xFF90BEFF);
    }
  }

  String get label {
    switch (this) {
      case PlayerColor.red:
        return 'Red';
      case PlayerColor.green:
        return 'Green';
      case PlayerColor.yellow:
        return 'Yellow';
      case PlayerColor.blue:
        return 'Blue';
    }
  }

  /// Order of play, clockwise.
  PlayerColor get next => PlayerColor.values[(index + 1) % 4];
}
