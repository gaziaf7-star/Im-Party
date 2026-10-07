import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/ludo_path.dart';
import '../models/player_color.dart';
import '../models/token.dart';
import '../services/sound_service.dart';
import 'board_component.dart';
import 'game_state.dart';

/// A 3D Premium Pawn/Token component on the Ludo board.
/// Moves box-by-box with slow 0.8s parabolic arc bounces and 0.5s box stay pauses.
class TokenComponent extends PositionComponent with TapCallbacks {
  TokenComponent({
    required this.token,
    required this.board,
    required this.gameState,
    required this.onTap,
    required this.baseSlotCell,
  }) : super(anchor: Anchor.center);

  final LudoToken token;
  final BoardComponent board;
  final LudoGameState gameState;
  final void Function(LudoToken token) onTap;
  final Cell baseSlotCell;

  bool highlighted = false;
  int _lastStep = -1;
  double _bounceTime = 0;

  @override
  void onMount() {
    super.onMount();
    anchor = Anchor.center;
    _updateSizeAndPosition(token.relativeStep);
    _lastStep = token.relativeStep;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    anchor = Anchor.center;
    _updateSizeAndPosition(token.relativeStep);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _bounceTime = highlighted ? (_bounceTime + dt) : 0.0;
  }

  List<LudoToken> _getTokensOnCell(Cell cell) {
    final result = <LudoToken>[];
    for (final color in PlayerColor.values) {
      final list = gameState.tokens[color];
      if (list == null) continue;
      for (final t in list) {
        if (!t.isInBase && !t.isFinished && t.cell == cell) {
          result.add(t);
        }
      }
    }
    return result;
  }

  void _updateSize(int step) {
    if (step < 0) {
      size = Vector2.all(board.cellSize * 0.95);
      return;
    }
    if (step == LudoPath.stepsToFinish) {
      size = Vector2.all(board.cellSize * 0.55);
      return;
    }
    final cell = LudoPath.cellForStep(token.color, step);
    final count = _getTokensOnCell(cell).length;
    size = Vector2.all(board.cellSize * (count > 1 ? 0.62 : 0.95));
  }

  void _updateSizeAndPosition(int step) {
    _updateSize(step);
    position = _targetOffsetForStep(step);
  }

  Vector2 _targetOffsetForStep(int step, {bool isFinalDestination = true}) {
    if (step < 0) {
      final c = board.cellCenter(baseSlotCell.row, baseSlotCell.col);
      return Vector2(c.dx, c.dy);
    }
    final cell = LudoPath.cellForStep(token.color, step);
    final c = board.cellCenter(cell.row, cell.col);

    if (step == LudoPath.stepsToFinish) {
      // Winning token position: Placed inside the 6th colored box of its home stretch lane
      final double slotOffsetX =
          (token.slot % 2 - 0.5) * (board.cellSize * 0.24);
      final double slotOffsetY =
          (token.slot ~/ 2 - 0.5) * (board.cellSize * 0.24);
      return Vector2(c.dx + slotOffsetX, c.dy + slotOffsetY);
    }

    if (!isFinalDestination) {
      return Vector2(c.dx, c.dy);
    }

    final tokensOnCell = _getTokensOnCell(cell);
    final count = tokensOnCell.length;
    if (count <= 1) return Vector2(c.dx, c.dy);

    int indexOnCell = tokensOnCell.indexOf(token);
    if (indexOnCell < 0) indexOnCell = 0;

    final double colOffset = (indexOnCell % 2 == 0) ? -0.23 : 0.23;
    final double rowOffset = (indexOnCell ~/ 2 % 2 == 0) ? -0.23 : 0.23;

    final double dx = colOffset * board.cellSize;
    final double dy = rowOffset * board.cellSize;
    return Vector2(c.dx + dx, c.dy + dy);
  }

  /// game_u.md §5, §7, §864-886: Animates token box-by-box with:
  ///  - Parabolic arc per cell (jump height 12–24px)
  ///  - Per-cell step sound via rotating pool of 4 sound players
  ///  - Special sounds: spawn (§7), safe zone, home, capture (§10)
  ///  - Scale squash-stretch hop (game_u.md §5: 1.0→1.08→1.0)
  void syncToState({bool animate = true}) {
    removeAll(children.whereType<MoveToEffect>());
    removeAll(children.whereType<MoveByEffect>());
    removeAll(children.whereType<SequenceEffect>());
    removeAll(children.whereType<ScaleEffect>());

    final targetStep = token.relativeStep;
    final startStep = _lastStep;

    if (!animate || startStep == targetStep) {
      _updateSizeAndPosition(targetStep);
      _lastStep = targetStep;
      return;
    }

    _updateSize(targetStep);

    final List<Effect> moveEffects = [];
    if (startStep < 0 && targetStep >= 0) {
      // ─── Spawn: Exiting base → Start Square (game_u.md §7) ───
      // scale 0 → 1.2 → 0.9 → 1.0 pop-in + parabolic arc + spawn.wav
      final cBase = board.cellCenter(baseSlotCell.row, baseSlotCell.col);
      final cStart = _targetOffsetForStep(0);
      final midPeak = Vector2(
        (cBase.dx + cStart.x) / 2,
        (cBase.dy + cStart.y) / 2 - 32,
      );
      moveEffects.add(
        MoveToEffect(
          midPeak,
          EffectController(duration: 0.13, curve: Curves.easeOutQuad),
        ),
      );
      moveEffects.add(
        MoveToEffect(
          cStart,
          EffectController(duration: 0.13, curve: Curves.easeInQuad),
        ),
      );
      // Pop-in scale: 0 → 1.2 → 0.9 → 1.0  (game_u.md §7)
      add(
        SequenceEffect([
          ScaleEffect.to(Vector2.all(0.0), EffectController(duration: 0.01)),
          ScaleEffect.to(
            Vector2.all(1.2),
            EffectController(duration: 0.12, curve: Curves.easeOutQuad),
          ),
          ScaleEffect.to(
            Vector2.all(0.9),
            EffectController(duration: 0.07, curve: Curves.easeInQuad),
          ),
          ScaleEffect.to(
            Vector2.all(1.0),
            EffectController(duration: 0.08, curve: Curves.easeOutQuad),
          ),
        ]),
      );
      // Spawn sound (game_u.md §7)
      SoundService.instance.playTokenSpawn();
    } else if (startStep >= 0 && targetStep > startStep) {
      // ─── Cell-by-cell movement (game_u.md §5, §6, §864) ───
      // Each step: jump 60ms rise + 70ms move + 30ms land bounce = ~140ms
      // Per-cell sound: token_step rotating pool (game_u.md §866-886)
      Vector2 prevPos = _targetOffsetForStep(
        startStep,
        isFinalDestination: false,
      );
      final stepsCount = targetStep - startStep;
      final stepDuration = stepsCount > 1 ? 0.065 : 0.085;

      for (int step = startStep + 1; step <= targetStep; step++) {
        final isLast = step == targetStep;
        final nextPos = _targetOffsetForStep(step, isFinalDestination: isLast);
        final midPeak = Vector2(
          (prevPos.x + nextPos.x) / 2,
          // game_u.md §959: jumpHeight 12–24
          (prevPos.y + nextPos.y) / 2 - (stepsCount > 3 ? 12.0 : 24.0),
        );

        // 1. Rise arc
        moveEffects.add(
          MoveToEffect(
            midPeak,
            EffectController(duration: stepDuration, curve: Curves.easeOutQuad),
          ),
        );
        // 2. Landing
        moveEffects.add(
          MoveToEffect(
            nextPos,
            EffectController(duration: stepDuration, curve: Curves.easeInQuad),
          ),
        );
        prevPos = nextPos;

        // ─── Per-cell step sound (game_u.md §864, §879-886) ───
        // Delay sound to match when token lands at that cell
        final landDelayMs = ((step - startStep) * stepDuration * 2 * 1000)
            .round();
        Future.delayed(Duration(milliseconds: landDelayMs), () {
          if (isLast && targetStep == LudoPath.stepsToFinish) {
            // Final home cell — chime (game_u.md §944-948)
            SoundService.instance.playTokenHome();
          } else if (isLast && _isSafeStep(step)) {
            // Safe star cell — special sound (game_u.md §926-929)
            SoundService.instance.playSafeZone();
          } else {
            // Normal step — rotating pool (game_u.md §866-886)
            SoundService.instance.playTokenStep();
          }
        });
      }

      // Squash-stretch scale: 1.0 → 1.08 → 1.0 (game_u.md §5)
      add(
        SequenceEffect([
          ScaleEffect.to(
            Vector2.all(1.08),
            EffectController(duration: stepDuration, curve: Curves.easeOutQuad),
          ),
          ScaleEffect.to(
            Vector2.all(1.0),
            EffectController(duration: stepDuration, curve: Curves.easeInQuad),
          ),
        ]),
      );
    } else if (startStep >= 0 && targetStep < 0) {
      // ─── Captured: High parabolic fly-back to base (game_u.md §10) ───
      // 300ms total (0→midpeak 0.17s, midpeak→base 0.17s)
      final cCurrent = _targetOffsetForStep(startStep);
      final cBase = board.cellCenter(baseSlotCell.row, baseSlotCell.col);
      final midPeak = Vector2(
        (cCurrent.x + cBase.dx) / 2,
        (cCurrent.y + cBase.dy) / 2 - 55,
      );
      moveEffects.add(
        MoveToEffect(
          midPeak,
          EffectController(duration: 0.17, curve: Curves.easeOutQuad),
        ),
      );
      moveEffects.add(
        MoveToEffect(
          Vector2(cBase.dx, cBase.dy),
          EffectController(duration: 0.17, curve: Curves.easeInQuad),
        ),
      );
      // Capture sound (game_u.md §374-379)
      SoundService.instance.playCapture();
    } else {
      moveEffects.add(
        MoveToEffect(
          _targetOffsetForStep(targetStep),
          EffectController(duration: 0.20, curve: Curves.easeInOutQuad),
        ),
      );
    }

    _lastStep = targetStep;
    if (moveEffects.isNotEmpty) {
      add(SequenceEffect(moveEffects));
    } else {
      position = _targetOffsetForStep(targetStep);
    }
  }

  /// True if [step] is a safe star cell on the board (game_u.md §12, §399).
  bool _isSafeStep(int step) {
    return LudoPath.isSafeStep(token.color, step);
  }

  @override
  void render(Canvas canvas) {
    final double bounceY = highlighted
        ? math.sin(_bounceTime * 6.5).abs() * -10.0
        : 0.0;

    // Token fits in [0, size.x] × [0, size.y] bounding box.
    // We treat the bounding box as a square of side `s`.
    final double s = size.x;

    // ── Geometry constants (proportions match Ludo King pawn) ──────────────
    //  HEAD: circle centred at (cx, headCY) with radius headR
    //  NECK: narrows from headR*0.45 to headR*0.45 over headR*0.55 height
    //  BODY: symmetric arc that widens from neck to bodyW at bodyMidY
    //  BASE: rounded rectangle at bottom
    final double cx = s / 2;
    final double headR = s * 0.265; // head radius
    final double headCY = headR + s * 0.02 + bounceY; // head center Y

    final double neckHalfW = headR * 0.38; // half-width of neck
    final double neckTop = headCY + headR * 0.72; // where neck starts
    final double neckBot = neckTop + headR * 0.52; // where body flare begins

    final double bodyHalfW = s * 0.45; // widest point of body shoulders
    final double bodyMidY = neckBot + headR * 0.60; // y of widest shoulder
    final double bodyBotY = s * 0.80 + bounceY; // where body meets base
    final double bodyBotHalfW = s * 0.38;

    final double baseTop = bodyBotY - s * 0.02;
    final double baseBot = s * 0.97 + bounceY;
    final double baseHalfW = s * 0.44;
    final double baseR = (baseBot - baseTop) * 0.55; // corner radius of base

    // ── 1. Ground shadow ellipse ───────────────────────────────────────────
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, s * 0.985),
        width: s * 0.78,
        height: s * 0.11,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.30)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // ── 2. Highlighted: pulsing gold aura ring around whole pawn ──────────
    if (highlighted) {
      final auraOpacity = 0.55 + math.sin(_bounceTime * 5.5) * 0.35;
      // Draw aura by stroking the pawn path with a fat translucent stroke
      final auraPath = _buildPawnPath(
        cx: cx,
        headR: headR + 4,
        headCY: headCY,
        neckHalfW: neckHalfW + 3,
        neckTop: neckTop,
        neckBot: neckBot,
        bodyHalfW: bodyHalfW + 4,
        bodyMidY: bodyMidY,
        bodyBotY: bodyBotY,
        bodyBotHalfW: bodyBotHalfW + 4,
        baseTop: baseTop,
        baseBot: baseBot + 2,
        baseHalfW: baseHalfW + 4,
        baseR: baseR,
      );
      canvas.drawPath(
        auraPath,
        Paint()
          ..color = Colors.amberAccent.withValues(alpha: auraOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5.5
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }

    // ── 3. Build main pawn path ────────────────────────────────────────────
    final pawnPath = _buildPawnPath(
      cx: cx,
      headR: headR,
      headCY: headCY,
      neckHalfW: neckHalfW,
      neckTop: neckTop,
      neckBot: neckBot,
      bodyHalfW: bodyHalfW,
      bodyMidY: bodyMidY,
      bodyBotY: bodyBotY,
      bodyBotHalfW: bodyBotHalfW,
      baseTop: baseTop,
      baseBot: baseBot,
      baseHalfW: baseHalfW,
      baseR: baseR,
    );

    // ── 4. Dark outline (matches Ludo King dark border) ───────────────────
    final darkColor = Color.lerp(token.color.baseColor, Colors.black, 0.55)!;
    canvas.drawPath(
      pawnPath,
      Paint()
        ..color = darkColor
        ..style = PaintingStyle.fill,
    );

    // ── 5. Main body: vertical linear gradient (light top → dark bottom) ──
    final bodyGrad = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          token.color.lightColor,
          token.color.baseColor,
          Color.lerp(token.color.baseColor, Colors.black, 0.35)!,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, s, s));

    // Inset path slightly so the dark outline shows
    final innerPath = _buildPawnPath(
      cx: cx,
      headR: headR - 1.2,
      headCY: headCY,
      neckHalfW: neckHalfW - 0.8,
      neckTop: neckTop,
      neckBot: neckBot,
      bodyHalfW: bodyHalfW - 1.2,
      bodyMidY: bodyMidY,
      bodyBotY: bodyBotY,
      bodyBotHalfW: bodyBotHalfW - 1.2,
      baseTop: baseTop,
      baseBot: baseBot - 0.8,
      baseHalfW: baseHalfW - 1.2,
      baseR: baseR,
    );
    canvas.drawPath(innerPath, bodyGrad);

    // ── 6. Head: extra radial 3D shading (sphere illusion) ────────────────
    final headRect = Rect.fromCircle(
      center: Offset(cx, headCY),
      radius: headR - 1.2,
    );
    final headGrad = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.30, -0.40),
        radius: 0.90,
        colors: [
          Colors.white.withValues(alpha: 0.45),
          Colors.transparent,
        ],
      ).createShader(headRect);
    canvas.drawCircle(Offset(cx, headCY), headR - 1.2, headGrad);

    // ── 7. Specular gloss arc on head (top-left white arc) ────────────────
    final glossPath = Path()
      ..addArc(
        Rect.fromCircle(
          center: Offset(cx - headR * 0.18, headCY - headR * 0.20),
          radius: headR * 0.58,
        ),
        -math.pi * 0.85,
        math.pi * 0.55,
      );
    canvas.drawPath(
      glossPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.60)
        ..style = PaintingStyle.stroke
        ..strokeWidth = headR * 0.22
        ..strokeCap = StrokeCap.round,
    );

    // ── 8. Gold crown dot on top of head (Ludo King signature) ────────────
    canvas.drawCircle(
      Offset(cx, headCY - headR * 0.52),
      headR * 0.16,
      Paint()..color = Colors.white.withValues(alpha: 0.92),
    );
    canvas.drawCircle(
      Offset(cx, headCY - headR * 0.52),
      headR * 0.09,
      Paint()..color = const Color(0xFFFFD700),
    );

    // ── 9. Shoulder highlight streak ──────────────────────────────────────
    final shoulderGloss = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = headR * 0.28
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx - bodyHalfW * 0.55, bodyMidY - headR * 0.05),
      Offset(cx + bodyHalfW * 0.55, bodyMidY - headR * 0.05),
      shoulderGloss,
    );
  }

  /// Builds the Ludo King pawn silhouette as a single Path:
  ///   circle head → narrowing neck → widening body shoulders → flat base
  Path _buildPawnPath({
    required double cx,
    required double headR,
    required double headCY,
    required double neckHalfW,
    required double neckTop,
    required double neckBot,
    required double bodyHalfW,
    required double bodyMidY,
    required double bodyBotY,
    required double bodyBotHalfW,
    required double baseTop,
    required double baseBot,
    required double baseHalfW,
    required double baseR,
  }) {
    final path = Path();

    // Head circle
    path.addOval(
      Rect.fromCircle(center: Offset(cx, headCY), radius: headR),
    );

    // Body + neck (drawn as a single closed polygon with bezier curves)
    final body = Path();
    // Start at left neck top
    body.moveTo(cx - neckHalfW, neckTop);
    // Left side: neck → shoulder flare → body taper
    body.cubicTo(
      cx - neckHalfW, neckBot, // left neck bottom control
      cx - bodyHalfW, bodyMidY - headR * 0.20, // flare control
      cx - bodyBotHalfW, bodyBotY, // body bottom left
    );
    // Base bottom-left arc
    body.lineTo(cx - baseHalfW + baseR, baseTop);
    body.arcToPoint(
      Offset(cx - baseHalfW, baseTop + baseR),
      radius: Radius.circular(baseR),
      clockwise: false,
    );
    body.lineTo(cx - baseHalfW, baseBot - baseR);
    body.arcToPoint(
      Offset(cx - baseHalfW + baseR, baseBot),
      radius: Radius.circular(baseR),
      clockwise: false,
    );
    body.lineTo(cx + baseHalfW - baseR, baseBot);
    body.arcToPoint(
      Offset(cx + baseHalfW, baseBot - baseR),
      radius: Radius.circular(baseR),
      clockwise: false,
    );
    body.lineTo(cx + baseHalfW, baseTop + baseR);
    body.arcToPoint(
      Offset(cx + baseHalfW - baseR, baseTop),
      radius: Radius.circular(baseR),
      clockwise: false,
    );
    body.lineTo(cx + bodyBotHalfW, bodyBotY);
    // Right side mirror
    body.cubicTo(
      cx + bodyHalfW, bodyMidY - headR * 0.20,
      cx + neckHalfW, neckBot,
      cx + neckHalfW, neckTop,
    );
    body.close();
    path.addPath(body, Offset.zero);

    return path;
  }

  @override
  void onTapDown(TapDownEvent event) {
    HapticFeedback.selectionClick();
    onTap(token);
  }
}

