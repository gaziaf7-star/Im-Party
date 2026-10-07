// ignore_for_file: invalid_use_of_protected_member

import 'dart:math';

import '../models/player_color.dart';
import 'game_state.dart';

/// Helper class for serializing and deserializing LudoGameState over LiveKit data channels.
class LudoStateSerializer {
  /// Serializes game state into a Map for broadcasting to late-joining participants.
  static Map<String, dynamic> toSyncMap(LudoGameState state) {
    final tokenMap = <String, List<int>>{};
    for (final entry in state.tokens.entries) {
      tokenMap[entry.key.name] = entry.value
          .map((t) => t.relativeStep)
          .toList();
    }

    final mutedMap = <String, bool>{};
    for (final entry in state.mutedSeats.entries) {
      mutedMap[entry.key.name] = entry.value;
    }

    final profilesMap = <String, Map<String, String>>{};
    for (final entry in state.playerProfiles.entries) {
      profilesMap[entry.key.name] = entry.value;
    }

    return {
      'activePlayers': state.activePlayers.map((p) => p.name).toList(),
      'lockedSeats': state.lockedSeats.map((p) => p.name).toList(),
      'mutedSeats': mutedMap,
      'playerProfiles': profilesMap,
      'currentPlayer': state.currentPlayer.name,
      'phase': state.phase.name,
      'lastDiceValue': state.lastDiceValue,
      'tokens': tokenMap,
      'skip': state.skipNext.map((c) => c.name).toList(),
    };
  }

  /// Deserializes incoming sync Map to update state for late joiners seamlessly.
  static void fromSyncMap(LudoGameState state, Map<String, dynamic> map) {
    if (map['activePlayers'] is List) {
      state.activePlayers.clear();
      for (final name in (map['activePlayers'] as List)) {
        final color = PlayerColor.values.firstWhere(
          (c) => c.name == name,
          orElse: () => PlayerColor.green,
        );
        state.activePlayers.add(color);
      }
    }

    if (map['lockedSeats'] is List) {
      state.lockedSeats.clear();
      for (final name in (map['lockedSeats'] as List)) {
        final color = PlayerColor.values.firstWhere(
          (c) => c.name == name,
          orElse: () => PlayerColor.yellow,
        );
        state.lockedSeats.add(color);
      }
    }

    if (map['mutedSeats'] is Map) {
      final mutedMap = map['mutedSeats'] as Map;
      for (final color in PlayerColor.values) {
        if (mutedMap.containsKey(color.name)) {
          state.mutedSeats[color] = mutedMap[color.name] == true;
        }
      }
    }

    if (map['playerProfiles'] is Map) {
      final pMap = map['playerProfiles'] as Map;
      for (final color in PlayerColor.values) {
        if (pMap.containsKey(color.name) && pMap[color.name] is Map) {
          final profileData = Map<String, String>.from(pMap[color.name] as Map);
          state.playerProfiles[color] = profileData;
        }
      }
    }

    if (map['currentPlayer'] is String) {
      state.currentPlayer = PlayerColor.values.firstWhere(
        (c) => c.name == map['currentPlayer'],
        orElse: () => PlayerColor.green,
      );
    }

    if (map['phase'] is String) {
      state.phase = TurnPhase.values.firstWhere(
        (p) => p.name == map['phase'],
        orElse: () => TurnPhase.waitingForRoll,
      );
    }

    if (map.containsKey('lastDiceValue')) {
      state.lastDiceValue = map['lastDiceValue'] as int?;
    }

    if (map['tokens'] is Map) {
      final tokenMap = map['tokens'] as Map;
      for (final color in PlayerColor.values) {
        if (tokenMap.containsKey(color.name) && tokenMap[color.name] is List) {
          final steps = List<int>.from(tokenMap[color.name] as List);
          for (int i = 0; i < min(4, steps.length); i++) {
            state.tokens[color]![i].relativeStep = steps[i];
          }
        }
      }
    }

    if (map['skip'] is List) {
      state.skipNext
        ..clear()
        ..addAll(
          (map['skip'] as List)
              .map((n) => PlayerColor.values.firstWhere((c) => c.name == n)),
        );
    }

    // ignore: invalid_use_of_visible_for_testing_member
    state.notifyListeners();
  }
}
