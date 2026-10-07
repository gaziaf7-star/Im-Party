import 'player_color.dart';
import 'ludo_path.dart';

/// A single pawn belonging to a player.
class LudoToken {
  final PlayerColor color;
  final int slot; // 0..3, which of the 4 tokens this is

  /// -1 = sitting in base (not yet on the board).
  /// 0..50 = relative step on the shared track.
  /// 51..56 = on this color's home stretch.
  /// 57 = finished (reached center).
  int relativeStep;

  LudoToken({required this.color, required this.slot, this.relativeStep = -1});

  bool get isInBase => relativeStep == -1;
  bool get isFinished => relativeStep == LudoPath.stepsToFinish;
  bool get isOnHomeStretch => relativeStep >= 51 && relativeStep <= 56;
  bool get isOnSharedTrack => relativeStep >= 0 && relativeStep <= 50;

  /// The board cell this token currently occupies (only valid if not in base).
  Cell get cell => LudoPath.cellForStep(color, relativeStep);

  /// Whether this token currently sits on a safe square.
  bool get isSafe {
    if (isInBase || isFinished) return true;
    if (isOnHomeStretch) return true;
    return LudoPath.isSafeStep(color, relativeStep);
  }

  /// Can this token legally move [diceValue] steps right now?
  bool canMove(int diceValue) {
    if (isFinished) return false;
    if (isInBase) return diceValue == 6;
    return relativeStep + diceValue <= LudoPath.stepsToFinish;
  }
}
