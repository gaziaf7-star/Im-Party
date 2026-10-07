import '../models/ludo_path.dart';
import '../models/token.dart';

/// Special squares placed on the shared track when "Magic" is on.
enum MagicItem { rocket, dice, crown, battery, ice }

/// Fixed item layout (indexes into [LudoPath.track]); none of them sit on a
/// start or star-safe square. Identical on every client, so effects stay in
/// sync without any extra network traffic.
class LudoMagic {
  LudoMagic._();

  static const Map<int, MagicItem> cells = {
    3: MagicItem.rocket,
    29: MagicItem.rocket,
    42: MagicItem.rocket,
    10: MagicItem.dice,
    23: MagicItem.dice,
    36: MagicItem.dice,
    16: MagicItem.crown,
    49: MagicItem.crown,
    6: MagicItem.battery,
    32: MagicItem.battery,
    19: MagicItem.ice,
    45: MagicItem.ice,
  };

  /// Steps a token jumps forward on rocket / battery squares.
  static const int rocketSteps = 3;
  static const int batterySteps = 2;

  static MagicItem? itemAt(LudoToken t) {
    if (!t.isOnSharedTrack) return null;
    final idx =
        (LudoPath.startIndex[t.color]! + t.relativeStep) % LudoPath.track.length;
    return cells[idx];
  }

  static String emoji(MagicItem i) {
    switch (i) {
      case MagicItem.rocket:
        return '🚀';
      case MagicItem.dice:
        return '🎲';
      case MagicItem.crown:
        return '👑';
      case MagicItem.battery:
        return '🔋';
      case MagicItem.ice:
        return '🧊';
    }
  }
}
