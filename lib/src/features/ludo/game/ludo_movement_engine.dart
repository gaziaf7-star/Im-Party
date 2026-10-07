// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import '../models/player_color.dart';
import '../models/token.dart';
import '../services/sound_service.dart';
import 'game_state.dart';
import 'ludo_magic.dart';

/// Helper engine executing token movement, step-by-step hops, captures, win checks, and turn passes for Ludo.
class LudoMovementEngine {
  static Future<void> moveToken(LudoGameState state, LudoToken token) async {
    if (state.phase != TurnPhase.waitingForTokenChoice) return;
    if (state.lastDiceValue == null || !token.canMove(state.lastDiceValue!)) {
      return;
    }

    final dice = state.lastDiceValue!;
    state.phase = TurnPhase.animating;
    state.notifyListeners();

    if (token.isInBase && dice == 6) {
      // 1. Exiting base onto Start Square (Step 0)
      token.relativeStep = 0;
      SoundService.instance.playTokenStep();
      state.notifyListeners();
      await Future.delayed(const Duration(milliseconds: 300));
    } else {
      // 2. Stepping box-by-box / hop-by-hop along the track
      for (int i = 0; i < dice; i++) {
        token.relativeStep += 1;
        SoundService.instance.playTokenStep();
        state.notifyListeners();
        // Wait for hop animation to land before taking next step
        await Future.delayed(const Duration(milliseconds: 210));
      }
    }

    // 3. Check if landed on a safe star zone
    if (token.isSafe && !token.isFinished && !token.isInBase) {
      SoundService.instance.playSafeZone();
    }

    // 4. Check for opponent token capture
    final capturedOpponent = resolveCaptures(state, token);
    if (capturedOpponent) {
      SoundService.instance.playCapture();
      state.notifyListeners();
      // Allow time for captured token to fly back to base
      await Future.delayed(const Duration(milliseconds: 360));
    }

    // 4b. Magic squares (only when Magic is on).
    var itemBonusRoll = false;
    if (state.magic && token.isOnSharedTrack) {
      final item = LudoMagic.itemAt(token);
      if (item != null) {
        switch (item) {
          case MagicItem.dice:
            itemBonusRoll = true;
            SoundService.instance.playExtraTurn();
            break;
          case MagicItem.rocket:
          case MagicItem.battery:
            final n = item == MagicItem.rocket
                ? LudoMagic.rocketSteps
                : LudoMagic.batterySteps;
            for (var i = 0; i < n && token.relativeStep < 50; i++) {
              token.relativeStep += 1;
              SoundService.instance.playTokenStep();
              state.notifyListeners();
              await Future.delayed(const Duration(milliseconds: 210));
            }
            if (resolveCaptures(state, token)) {
              SoundService.instance.playCapture();
              state.notifyListeners();
              await Future.delayed(const Duration(milliseconds: 360));
            }
            break;
          case MagicItem.ice:
            final target = _nextPlain(state, token.color);
            if (target != token.color) state.skipNext.add(target);
            SoundService.instance.playSafeZone();
            break;
          case MagicItem.crown:
            SoundService.instance.playSafeZone();
            break;
        }
      }
    }

    // 5. Check if token reached the winning home center
    final reachedHome = token.isFinished;
    if (reachedHome) {
      SoundService.instance.playTokenHome();
      checkForWin(state);
      await Future.delayed(const Duration(milliseconds: 300));
    }

    // 6. Check game over victory fanfare
    if (state.phase == TurnPhase.gameOver) {
      SoundService.instance.playWin();
    }

    final bonusExtraTurn = dice == 6 ||
        itemBonusRoll ||
        (state.magic && (capturedOpponent || reachedHome));

    endTurn(
      state,
      extraTurn: bonusExtraTurn && state.phase != TurnPhase.gameOver,
    );
    state.notifyListeners();
  }

  static bool resolveCaptures(LudoGameState state, LudoToken mover) {
    if (!mover.isOnSharedTrack) return false;
    if (mover.isSafe) return false;

    final landingCell = mover.cell;
    bool captured = false;

    for (final color in PlayerColor.values) {
      if (color == mover.color) continue;
      for (final other in state.tokens[color]!) {
        if (other.isOnSharedTrack && other.cell == landingCell) {
          other.relativeStep = -1;
          captured = true;
        }
      }
    }
    return captured;
  }

  static void checkForWin(LudoGameState state) {
    final homeCount =
        state.tokens[state.currentPlayer]!.where((t) => t.isFinished).length;
    final allHome = homeCount >= state.tokensToWin;
    if (allHome && !state.finishedOrder.contains(state.currentPlayer)) {
      state.finishedOrder.add(state.currentPlayer);
      if (state.finishedOrder.length == 1) {
        state.winner = state.currentPlayer;
        state.phase = TurnPhase.gameOver;
      }
    }
  }

  static void endTurn(LudoGameState state, {required bool extraTurn}) {
    if (state.phase == TurnPhase.gameOver) return;
    state.lastDiceValue = null;
    if (extraTurn) {
      state.phase = TurnPhase.waitingForRoll;
    } else {
      state.consecutiveSixes = 0;
      state.currentPlayer = nextActivePlayer(state, state.currentPlayer);
      state.phase = TurnPhase.waitingForRoll;
    }
  }

  /// Next seated, unfinished player after [from], ignoring ice skips.
  static PlayerColor _nextPlain(LudoGameState state, PlayerColor from) {
    var next = from.next;
    var guard = 0;
    while ((!state.activePlayers.contains(next) ||
            state.finishedOrder.contains(next)) &&
        guard < 4) {
      next = next.next;
      guard++;
    }
    return next;
  }

  /// Like [_nextPlain] but consumes ice skips: a frozen player loses one turn.
  static PlayerColor nextActivePlayer(LudoGameState state, PlayerColor from) {
    var next = _nextPlain(state, from);
    var guard = 0;
    while (state.skipNext.remove(next) && guard < 4) {
      next = _nextPlain(state, next);
      guard++;
    }
    return next;
  }

  static void restart(LudoGameState state) {
    for (final color in PlayerColor.values) {
      for (final t in state.tokens[color]!) {
        t.relativeStep = -1;
      }
    }
    state.currentPlayer = PlayerColor.green;
    state.lastDiceValue = null;
    state.consecutiveSixes = 0;
    state.phase = TurnPhase.waitingForRoll;
    state.winner = null;
    state.finishedOrder.clear();
    state.skipNext.clear();
    state.notifyListeners();
  }
}
