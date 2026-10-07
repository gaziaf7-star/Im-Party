import 'package:flame/game.dart';

import '../models/ludo_path.dart';
import '../models/player_color.dart';
import '../models/token.dart';
import 'board_component.dart';
import 'game_state.dart';
import 'token_component.dart';

/// The Flame [FlameGame] driving rendering. Game *rules* live in
/// [LudoGameState] (plain Dart, easy to unit test); this class is only
/// responsible for drawing the board/tokens and translating taps into
/// state-engine calls.
class LudoFlameGame extends FlameGame {
  LudoFlameGame({
    required this.gameState,
    this.canControl,
    this.onTokenChosen,
  });

  final LudoGameState gameState;

  /// Whether the local user may move tokens of the given colour. Null = anyone.
  final bool Function(PlayerColor color)? canControl;

  /// Routes a confirmed token tap to the room transport. When null the move is
  /// applied locally.
  final void Function(LudoToken token)? onTokenChosen;

  late final BoardComponent board;
  final Map<String, TokenComponent> _tokenComponents = {};

  String _key(LudoToken t) => '${t.color.name}_${t.slot}';

  @override
  Future<void> onLoad() async {
    board = BoardComponent(gameState: gameState);
    await add(board);
    // Ensure the board has computed cellSize before we place tokens on it,
    // regardless of exact resize-callback timing.
    board.onGameResize(size);

    for (final color in PlayerColor.values) {
      final baseSlots = LudoPath.baseSlots[color]!;
      for (final token in gameState.tokens[color]!) {
        final comp = TokenComponent(
          token: token,
          board: board,
          gameState: gameState,
          baseSlotCell: baseSlots[token.slot],
          onTap: _handleTokenTap,
        );
        _tokenComponents[_key(token)] = comp;
        await board.add(comp);
      }
    }

    gameState.addListener(_onStateChanged);
    _refreshHighlights();
  }

  void _handleTokenTap(LudoToken token) {
    if (token.color != gameState.currentPlayer) return;
    if (canControl != null && !canControl!(token.color)) return;
    if (gameState.phase != TurnPhase.waitingForTokenChoice) return;
    if (!gameState.movableTokens.contains(token)) return;
    if (onTokenChosen != null) {
      onTokenChosen!(token);
    } else {
      gameState.moveToken(token);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _refreshHighlights();
  }

  void _onStateChanged() {
    for (final entry in _tokenComponents.entries) {
      entry.value.syncToState();
    }
    _refreshHighlights();
  }

  void _refreshHighlights() {
    if (gameState.phase != TurnPhase.waitingForTokenChoice) {
      for (final comp in _tokenComponents.values) {
        comp.highlighted = false;
      }
      return;
    }

    final movable = gameState.movableTokens.toSet();
    for (final comp in _tokenComponents.values) {
      comp.highlighted = movable.contains(comp.token);
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      board.onGameResize(size);
      for (final comp in _tokenComponents.values) {
        comp.syncToState(animate: false);
      }
    }
  }

  @override
  void onRemove() {
    gameState.removeListener(_onStateChanged);
    super.onRemove();
  }
}
