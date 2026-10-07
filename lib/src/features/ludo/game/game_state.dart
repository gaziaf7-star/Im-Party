import 'dart:math';

import 'package:flutter/material.dart';

import '../models/game_mode.dart';
import '../models/player_color.dart';
import '../models/token.dart';
import '../services/sound_service.dart';
import 'ludo_movement_engine.dart';
import 'ludo_state_serializer.dart';

enum TurnPhase {
  waitingForPlayers, // Less than 2 players seated (game locked in party mode)
  waitingForRoll, // Player must tap the dice
  waitingForTokenChoice, // Player must tap a movable token
  animating, // A token is mid-move, input locked
  gameOver,
}

/// Central rules engine for a 4-player Ludo game.
class LudoGameState extends ChangeNotifier {
  static LudoGameState? activeState;

  LudoGameState({Random? random, this.mode = GameMode.classic})
    : _random = random ?? Random() {
    for (final color in PlayerColor.values) {
      tokens[color] = List.generate(4, (i) => LudoToken(color: color, slot: i));
    }
    if (mode == GameMode.classic) {
      // By default 2 players: Green and Blue
      activePlayers.addAll([PlayerColor.green, PlayerColor.blue]);
      phase = TurnPhase.waitingForRoll;
    }
  }

  final Random _random;
  final GameMode mode;

  /// Tokens a player must bring home to win (4 = Classic, 2 = Simple).
  int tokensToWin = 4;

  /// Magic on: a capture or a token reaching home grants a bonus roll.
  /// Off: only a six does.
  bool magic = true;

  /// Colours whose next turn is skipped (set by ice squares).
  final Set<PlayerColor> skipNext = {};

  final Map<PlayerColor, List<LudoToken>> tokens = {};

  /// Currently seated active players.
  final Set<PlayerColor> activePlayers = {PlayerColor.green};

  /// Set of players controlled by Computer AI.
  final Set<PlayerColor> aiPlayers = {};

  PlayerColor currentPlayer = PlayerColor.green;
  int? lastDiceValue;
  int consecutiveSixes = 0;
  TurnPhase phase = TurnPhase.waitingForPlayers;
  PlayerColor? winner;
  final List<PlayerColor> finishedOrder = [];

  /// Set of locked empty seats managed by Host
  final Set<PlayerColor> lockedSeats = {};

  /// Map of seat mic mute statuses managed in real-time
  final Map<PlayerColor, bool> mutedSeats = {};

  /// Map storing seated user profiles {PlayerColor.yellow: {'name': 'Tanvir', 'avatar': 'https://...'}}
  final Map<PlayerColor, Map<String, String>> playerProfiles = {};

  bool isPlayerSeated(PlayerColor color) => activePlayers.contains(color);
  bool isSeatLocked(PlayerColor color) => lockedSeats.contains(color);
  bool isSeatMuted(PlayerColor color) => mutedSeats[color] ?? false;
  bool isAiPlayer(PlayerColor color) => aiPlayers.contains(color);

  void configurePlayers({
    required List<PlayerColor> players,
    List<PlayerColor> aiList = const [],
    Map<PlayerColor, String>? names,
  }) {
    activePlayers.clear();
    aiPlayers.clear();
    activePlayers.addAll(players);
    aiPlayers.addAll(aiList);

    if (names != null) {
      names.forEach((color, name) {
        playerProfiles[color] = {'name': name, 'avatar': ''};
      });
    }

    currentPlayer = players.isNotEmpty ? players.first : PlayerColor.green;
    phase = activePlayers.length >= 2
        ? TurnPhase.waitingForRoll
        : TurnPhase.waitingForPlayers;
    notifyListeners();
  }

  void setSeatMuted(PlayerColor color, bool isMuted) {
    mutedSeats[color] = isMuted;
    notifyListeners();
  }

  void toggleSeatMuted(PlayerColor color) {
    mutedSeats[color] = !(mutedSeats[color] ?? false);
    notifyListeners();
  }

  void toggleLockSeat(PlayerColor color) {
    if (color == PlayerColor.green) return;
    if (lockedSeats.contains(color)) {
      lockedSeats.remove(color);
    } else {
      if (!activePlayers.contains(color)) {
        lockedSeats.add(color);
      }
    }
    notifyListeners();
  }

  void joinSeat(
    PlayerColor color, {
    bool isHost = false,
    String? name,
    String? avatar,
    bool asAi = false,
  }) {
    if (lockedSeats.contains(color)) return;
    activePlayers.add(color);
    if (asAi) {
      aiPlayers.add(color);
    } else {
      aiPlayers.remove(color);
    }
    if (name != null) {
      playerProfiles[color] = {'name': name, 'avatar': avatar ?? ''};
    }
    if (activePlayers.length >= 2 && phase == TurnPhase.waitingForPlayers) {
      phase = TurnPhase.waitingForRoll;
    }
    notifyListeners();
  }

  PlayerColor? joinNextAvailableSeat({
    String? name,
    String? avatar,
    bool asAi = false,
  }) {
    final candidateSeats = [
      PlayerColor.yellow,
      PlayerColor.blue,
      PlayerColor.red,
    ];
    for (final color in candidateSeats) {
      if (!activePlayers.contains(color) && !lockedSeats.contains(color)) {
        joinSeat(color, isHost: false, name: name, avatar: avatar, asAi: asAi);
        return color;
      }
    }
    return null;
  }

  void leaveSeat(PlayerColor color) {
    if (color == PlayerColor.green) return; // Host cannot leave
    activePlayers.remove(color);
    aiPlayers.remove(color);
    playerProfiles.remove(color);
    mutedSeats.remove(color);
    if (activePlayers.length < 2) {
      phase = TurnPhase.waitingForPlayers;
    }
    notifyListeners();
  }

  List<LudoToken> get currentPlayerTokens => tokens[currentPlayer] ?? const [];

  /// Tokens belonging to the current player that can legally move with the last rolled dice value.
  List<LudoToken> get movableTokens {
    if (lastDiceValue == null) return const [];
    return currentPlayerTokens.where((t) => t.canMove(lastDiceValue!)).toList();
  }

  /// Rolls a random value for the current player and applies it.
  int rollDice() {
    if (phase != TurnPhase.waitingForRoll) {
      throw StateError('Cannot roll right now: phase=$phase');
    }
    return applyRoll(_random.nextInt(6) + 1);
  }

  /// Applies an already-rolled [value]. Every client in a room applies the
  /// same value (chosen by the rolling player), so state never diverges.
  int applyRoll(int value) {
    if (phase != TurnPhase.waitingForRoll) return value;
    SoundService.instance.playDiceRoll();
    lastDiceValue = value;

    if (value == 6) {
      consecutiveSixes++;
    } else {
      consecutiveSixes = 0;
    }

    // Three sixes in a row: forfeit the turn entirely per authentic Ludo rules.
    if (consecutiveSixes >= 3) {
      consecutiveSixes = 0;
      LudoMovementEngine.endTurn(this, extraTurn: false);
      notifyListeners();
      return value;
    }

    if (movableTokens.isEmpty) {
      if (value == 6) {
        phase = TurnPhase.waitingForRoll;
      } else {
        phase = TurnPhase.waitingForTokenChoice;
      }
    } else {
      phase = TurnPhase.waitingForTokenChoice;
    }

    notifyListeners();
    return value;
  }

  /// Passes turn when player has no legal moves with the rolled dice value.
  void passTurnNoMoves() {
    LudoMovementEngine.endTurn(this, extraTurn: false);
    notifyListeners();
  }

  Future<void> moveToken(LudoToken token) async =>
      await LudoMovementEngine.moveToken(this, token);

  /// Public wrapper so the room controller can repaint after server updates.
  void refresh() => notifyListeners();

  void restart() => LudoMovementEngine.restart(this);

  /// Serializes game state into a Map.
  Map<String, dynamic> toSyncMap() => LudoStateSerializer.toSyncMap(this);

  /// Deserializes incoming sync Map.
  void fromSyncMap(Map<String, dynamic> map) =>
      LudoStateSerializer.fromSyncMap(this, map);
}
