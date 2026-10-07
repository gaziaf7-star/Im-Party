import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../models/player_color.dart';
import '../models/ludo_path.dart';
import 'game_state.dart';
import 'ludo_magic.dart';
import 'ludo_board_slots_painter.dart';
import 'ludo_board_star_painter.dart';

/// Renders the static 15x15 Ludo board: colored home quadrants, the four
/// base slots (with 4 dot circles each), the cross-shaped track, the
/// colored home-stretch lanes, the center finish triangle, and the star
/// safe-cells — matching the layout in the reference screenshot.
class BoardComponent extends PositionComponent {
  static const int gridSize = 15;

  final LudoGameState? gameState;

  BoardComponent({this.gameState});

  late double cellSize;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final boardSide = size.x < size.y ? size.x : size.y;
    this.size = Vector2.all(boardSide);
    position = Vector2((size.x - boardSide) / 2, (size.y - boardSide) / 2);
    cellSize = boardSide / gridSize;
  }

  Rect cellRect(int row, int col) =>
      Rect.fromLTWH(col * cellSize, row * cellSize, cellSize, cellSize);

  Offset cellCenter(int row, int col) =>
      Offset(col * cellSize + cellSize / 2, row * cellSize + cellSize / 2);

  @override
  void render(Canvas canvas) {
    final cornerRadius = cellSize * 0.35;
    final boardRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Radius.circular(cornerRadius),
    );

    canvas.save();
    canvas.clipRRect(boardRRect);

    final bg = Paint()..color = Colors.white;
    canvas.drawRRect(boardRRect, bg);

    _drawBaseQuadrants(canvas);

    _drawTrackCells(canvas);
    _drawHomeStretches(canvas);
    _drawGridLines(canvas);
    _drawMagicItems(canvas);
    _drawCenterTriangles(canvas);
    _drawBaseSlots(canvas);

    canvas.restore();
  }

  void _drawBaseQuadrants(Canvas canvas) {
    for (final color in PlayerColor.values) {
      final origin = _quadrantOrigin(color);
      final rect = Rect.fromLTWH(
        origin.$2 * cellSize,
        origin.$1 * cellSize,
        6 * cellSize,
        6 * cellSize,
      );
      canvas.drawRect(rect, Paint()..color = color.baseColor);
    }
  }

  void _drawBaseSlots(Canvas canvas) {
    LudoBoardSlotsPainter.drawBaseSlots(
      canvas,
      cellSize,
      _quadrantOrigin,
      cellCenter,
      gameState,
    );
  }

  (int, int) _quadrantOrigin(PlayerColor color) {
    switch (color) {
      case PlayerColor.green:
        return (0, 0);
      case PlayerColor.yellow:
        return (0, 9);
      case PlayerColor.blue:
        return (9, 9);
      case PlayerColor.red:
        return (9, 0);
    }
  }

  void _drawTrackCells(Canvas canvas) {
    for (var i = 0; i < LudoPath.track.length; i++) {
      final cell = LudoPath.track[i];
      final rect = cellRect(cell.row, cell.col);

      Color bg = Colors.white;
      Color? starColor;

      if (i == LudoPath.startIndex[PlayerColor.green]) {
        bg = PlayerColor.green.baseColor;
        starColor = Colors.white;
      } else if (i == LudoPath.startIndex[PlayerColor.yellow]) {
        bg = PlayerColor.yellow.baseColor;
        starColor = Colors.white;
      } else if (i == LudoPath.startIndex[PlayerColor.blue]) {
        bg = PlayerColor.blue.baseColor;
        starColor = Colors.white;
      } else if (i == LudoPath.startIndex[PlayerColor.red]) {
        bg = PlayerColor.red.baseColor;
        starColor = Colors.white;
      } else if (LudoPath.safeTrackIndices.contains(i)) {
        bg = const Color(0xFFD6D6D6);
        starColor = Colors.grey.shade600;
      }

      canvas.drawRect(rect, Paint()..color = bg);

      if (starColor != null) {
        _drawStar(
          canvas,
          cellCenter(cell.row, cell.col),
          cellSize * 0.28,
          starColor,
        );
      }
    }
  }

  void _drawHomeStretches(Canvas canvas) {
    for (final color in PlayerColor.values) {
      for (final cell in LudoPath.homeStretch[color]!) {
        canvas.drawRect(
          cellRect(cell.row, cell.col),
          Paint()..color = color.baseColor,
        );
      }
    }
  }

  void _drawCenterTriangles(Canvas canvas) {
    // Center 3x3 block (rows 6-8, cols 6-8) split into 4 triangles pointing
    // inward, colored per side, like the home-finish pinwheel in the image.
    final left = 6 * cellSize;
    final top = 6 * cellSize;
    final size3 = 3 * cellSize;
    final cx = left + size3 / 2;
    final cy = top + size3 / 2;

    final topLeft = Offset(left, top);
    final topRight = Offset(left + size3, top);
    final bottomLeft = Offset(left, top + size3);
    final bottomRight = Offset(left + size3, top + size3);
    final centerPt = Offset(cx, cy);

    void tri(Offset a, Offset b, Offset c, Color color) {
      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy)
        ..lineTo(c.dx, c.dy)
        ..close();
      canvas.drawPath(path, Paint()..color = color);
    }

    tri(topLeft, topRight, centerPt, PlayerColor.yellow.baseColor); // top
    tri(topRight, bottomRight, centerPt, PlayerColor.blue.baseColor); // right
    tri(bottomRight, bottomLeft, centerPt, PlayerColor.red.baseColor); // bottom
    tri(bottomLeft, topLeft, centerPt, PlayerColor.green.baseColor); // left
  }

  void _drawStar(
    Canvas canvas,
    Offset center,
    double radius, [
    Color starColor = const Color(0xFFFFD700),
  ]) {
    LudoBoardStarPainter.drawStar(canvas, center, radius, starColor);
  }

  /// Faint outlines only around playable cells (track + home lanes), so the
  /// coloured home areas stay clean.
  void _drawGridLines(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0x33000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (final cell in LudoPath.track) {
      canvas.drawRect(cellRect(cell.row, cell.col), paint);
    }
    for (final lane in LudoPath.homeStretch.values) {
      for (final cell in lane) {
        canvas.drawRect(cellRect(cell.row, cell.col), paint);
      }
    }
  }

  final Map<String, TextPainter> _emojiCache = {};

  TextPainter _emoji(String e) => _emojiCache.putIfAbsent('$e$cellSize', () {
        return TextPainter(
          text: TextSpan(text: e, style: TextStyle(fontSize: cellSize * 0.72)),
          textDirection: TextDirection.ltr,
        )..layout();
      });

  void _drawMagicItems(Canvas canvas) {
    if (gameState?.magic != true) return;
    LudoMagic.cells.forEach((index, item) {
      final cell = LudoPath.track[index];
      final c = cellCenter(cell.row, cell.col);
      final tp = _emoji(LudoMagic.emoji(item));
      tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy - tp.height / 2));
    });
  }
}
