import 'package:flutter/material.dart';

import '../models/ludo_path.dart';
import '../models/player_color.dart';
import 'game_state.dart';

/// Helper painter for drawing 4 base home slots and winner badges on Ludo board.
class LudoBoardSlotsPainter {
  static void drawBaseSlots(
    Canvas canvas,
    double cellSize,
    (int, int) Function(PlayerColor) quadrantOrigin,
    Offset Function(int, int) cellCenter,
    LudoGameState? gameState,
  ) {
    for (final color in PlayerColor.values) {
      final origin = quadrantOrigin(color);
      final slots = LudoPath.baseSlots[color]!;
      final c0 = cellCenter(slots.first.row, slots.first.col);
      final c1 = cellCenter(slots.last.row, slots.last.col);
      final panel = Rect.fromLTRB(
        c0.dx - cellSize * 0.95,
        c0.dy - cellSize * 0.7,
        c1.dx + cellSize * 0.95,
        c1.dy + cellSize * 0.7,
      );
      // Darker tone of the quadrant colour, with darker "holes" for the tokens.
      final hsl = HSLColor.fromColor(color.baseColor);
      final panelColor = hsl
          .withLightness((hsl.lightness - 0.10).clamp(0.0, 1.0))
          .toColor();
      final holeColor = hsl
          .withLightness((hsl.lightness - 0.22).clamp(0.0, 1.0))
          .toColor();
      canvas.drawRRect(
        RRect.fromRectAndRadius(panel, Radius.circular(cellSize * 0.7)),
        Paint()..color = panelColor,
      );

      for (final slot in LudoPath.baseSlots[color]!) {
        final center = cellCenter(slot.row, slot.col);
        canvas.drawCircle(center, cellSize * 0.42, Paint()..color = holeColor);
      }

      if (gameState != null && gameState.finishedOrder.contains(color)) {
        final rankIdx = gameState.finishedOrder.indexOf(color);
        final rankLabel = rankIdx == 0
            ? '1st 🥇'
            : (rankIdx == 1 ? '2nd 🥈' : '3rd 🥉');
        final centerQuad = Offset(
          (origin.$2 + 3) * cellSize,
          (origin.$1 + 3) * cellSize,
        );

        canvas.drawCircle(
          centerQuad,
          cellSize * 1.5,
          Paint()..color = const Color(0xFF10B981),
        );
        canvas.drawCircle(
          centerQuad,
          cellSize * 1.35,
          Paint()..color = const Color(0xFFFFD700),
        );
        canvas.drawCircle(
          centerQuad,
          cellSize * 1.15,
          Paint()..color = const Color(0xFF04120F),
        );

        final textPainter = TextPainter(
          text: TextSpan(
            text: rankLabel,
            style: TextStyle(
              color: const Color(0xFFFFD700),
              fontSize: cellSize * 0.70,
              fontWeight: FontWeight.w900,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            centerQuad.dx - textPainter.width / 2,
            centerQuad.dy - textPainter.height / 2,
          ),
        );
      }
    }
  }
}
