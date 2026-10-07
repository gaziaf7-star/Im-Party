import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../domain/models/game_models.dart';

class BoardRenderingComponent extends Component {
  ThemeStyling theme = ThemeStyling.tournamentRed;
  ui.Picture? _cachedPicture;
  ThemeStyling? _cachedTheme;

  void updateTheme(ThemeStyling newTheme) {
    if (theme != newTheme) {
      theme = newTheme;
      _cachedPicture?.dispose();
      _cachedPicture = null;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (_cachedPicture == null || _cachedTheme != theme) {
      _rebuildCache();
    }
    canvas.drawPicture(_cachedPicture!);
  }

  void _rebuildCache() {
    final recorder = ui.PictureRecorder();
    final cacheCanvas = Canvas(
      recorder,
      const Rect.fromLTWH(0, 0, BoardConfig.boardSize, BoardConfig.boardSize),
    );
    const size = BoardConfig.boardSize;
    const center = Offset(size / 2, size / 2);

    // 1. Outer wooden frame border (Dark Walnut / Rosewood with smooth rounded corners)
    _renderOuterFrame(cacheCanvas, size);

    // 2. Playing surface (Light birch/maple plywood with subtle grain)
    _renderPlayingSurface(cacheCanvas, size, center);

    // 3. Wooden Cushions (drawn before markings and pockets, stopping cleanly outside pocket radius)
    _renderCushions(cacheCanvas, size);

    // 4. Official Tournament Markings, Baselines & Foul Arcs (strictly clipped outside pockets)
    _renderBoardMarkings(cacheCanvas, size, center);

    // 5. Corner Pockets (drawn ON TOP: completely round 360° metallic rim, 100% pure black empty interior)
    _renderPockets(cacheCanvas, size);

    _cachedPicture?.dispose();
    _cachedPicture = recorder.endRecording();
    _cachedTheme = theme;
  }

  @override
  void onRemove() {
    _cachedPicture?.dispose();
    _cachedPicture = null;
    super.onRemove();
  }

  void _renderOuterFrame(Canvas canvas, double size) {
    final frameRect = Rect.fromLTWH(0, 0, size, size);
    final outerRRect = RRect.fromRectAndRadius(
      frameRect,
      const Radius.circular(28.0),
    );

    // 1. Base Rich Polished Dark Walnut Hardwood Gradient
    final framePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.frameWoodLight,
          theme.frameWoodDark,
          theme.frameWoodLight.withValues(alpha: 0.96),
          theme.frameWoodDark,
        ],
        stops: const [0.0, 0.35, 0.7, 1.0],
      ).createShader(frameRect);

    canvas.drawRRect(outerRRect, framePaint);

    // 2. Realistic Fine Wood Grain Streaks along borders
    const frameW = BoardConfig.frameWidth; // 45.0
    final grainLight = Paint()
      ..color = const Color(0xFFD4A373).withValues(alpha: 0.08)
      ..strokeWidth = 1.0;
    final grainDark = Paint()
      ..color = Colors.black.withValues(alpha: 0.16)
      ..strokeWidth = 1.0;

    // Top border wood grain
    for (double y = 8.0; y < frameW; y += 4.5) {
      final paint = (y.round() % 2 == 0) ? grainLight : grainDark;
      canvas.drawLine(Offset(frameW, y), Offset(size - frameW, y), paint);
    }
    // Bottom border wood grain
    for (double y = size - frameW; y < size - 8.0; y += 4.5) {
      final paint = (y.round() % 2 == 0) ? grainLight : grainDark;
      canvas.drawLine(Offset(frameW, y), Offset(size - frameW, y), paint);
    }
    // Left border wood grain
    for (double x = 8.0; x < frameW; x += 4.5) {
      final paint = (x.round() % 2 == 0) ? grainLight : grainDark;
      canvas.drawLine(Offset(x, frameW), Offset(x, size - frameW), paint);
    }
    // Right border wood grain
    for (double x = size - frameW; x < size - 8.0; x += 4.5) {
      final paint = (x.round() % 2 == 0) ? grainLight : grainDark;
      canvas.drawLine(Offset(x, frameW), Offset(x, size - frameW), paint);
    }

    // 3. 45-degree miter corner joints
    final miterPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..strokeWidth = 1.2;
    canvas.drawLine(
      const Offset(0, 0),
      const Offset(frameW, frameW),
      miterPaint,
    );
    canvas.drawLine(Offset(size, 0), Offset(size - frameW, frameW), miterPaint);
    canvas.drawLine(Offset(0, size), Offset(frameW, size - frameW), miterPaint);
    canvas.drawLine(
      Offset(size, size),
      Offset(size - frameW, size - frameW),
      miterPaint,
    );

    // 4. Subtle inner bevel
    final innerBevel = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(outerRRect.deflate(1.2), innerBevel);

    // 5. 3D Rail Chamfer Lighting (Light from Top-Left -45°)
    final railHighlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    // Top highlight edge
    canvas.drawLine(
      const Offset(28, 1.2),
      Offset(size - 28, 1.2),
      railHighlightPaint,
    );
    // Left highlight edge
    canvas.drawLine(
      const Offset(1.2, 28),
      Offset(1.2, size - 28),
      railHighlightPaint,
    );

    final railShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    // Bottom shadow undercut
    canvas.drawLine(
      Offset(28, size - 1.2),
      Offset(size - 28, size - 1.2),
      railShadowPaint,
    );
    // Right shadow undercut
    canvas.drawLine(
      Offset(size - 1.2, 28),
      Offset(size - 1.2, size - 28),
      railShadowPaint,
    );

    // 6. 3D Polished Brass Corner Brackets & Screws (Tournament Hardware)
    void draw3DCornerBracket(Offset corner, double angle) {
      canvas.save();
      canvas.translate(corner.dx, corner.dy);
      canvas.rotate(angle);

      // L-bracket Path
      final bracketPath = Path()
        ..moveTo(2, 2)
        ..lineTo(38, 2)
        ..lineTo(38, 11)
        ..lineTo(11, 11)
        ..lineTo(11, 38)
        ..lineTo(2, 38)
        ..close();

      // Rich metallic brass gradient
      final brassShader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFF9C4),
          Color(0xFFFDE047),
          Color(0xFFCA8A04),
          Color(0xFF78350F),
        ],
        stops: [0.0, 0.35, 0.75, 1.0],
      ).createShader(const Rect.fromLTWH(0, 0, 38, 38));

      canvas.drawPath(bracketPath, Paint()..shader = brassShader);
      canvas.drawPath(
        bracketPath,
        Paint()
          ..color = const Color(0x66000000)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );

      // 3D Brass Screws / Rivets
      void drawScrew(Offset pos) {
        // Drop shadow
        canvas.drawCircle(
          pos.translate(0.5, 0.5),
          2.2,
          Paint()..color = const Color(0x66000000),
        );
        // Screw head
        canvas.drawCircle(
          pos,
          2.0,
          Paint()
            ..shader = const RadialGradient(
              center: Alignment(-0.3, -0.3),
              colors: [Color(0xFFFFFBEB), Color(0xFFD97706)],
            ).createShader(Rect.fromCircle(center: pos, radius: 2.0)),
        );
        // Screw slot
        canvas.drawLine(
          pos.translate(-1.0, -0.5),
          pos.translate(1.0, 0.5),
          Paint()
            ..color = const Color(0xFF78350F)
            ..strokeWidth = 0.6,
        );
      }

      drawScrew(const Offset(26, 6.5));
      drawScrew(const Offset(6.5, 26));

      canvas.restore();
    }

    draw3DCornerBracket(const Offset(0, 0), 0);
    draw3DCornerBracket(Offset(size, 0), pi / 2);
    draw3DCornerBracket(Offset(size, size), pi);
    draw3DCornerBracket(Offset(0, size), 3 * pi / 2);
  }

  void _renderPlayingSurface(Canvas canvas, double size, Offset center) {
    const margin = BoardConfig.cushionWidth + 14.0;
    final surfaceRect = Rect.fromLTWH(
      margin,
      margin,
      size - margin * 2,
      size - margin * 2,
    );

    // 1. Warm natural birch / maple playing surface
    final surfacePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.85,
        colors: [
          theme.surfaceColor,
          theme.surfaceSubtle,
          theme.surfaceSubtle.withValues(alpha: 0.94),
        ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(surfaceRect);

    canvas.drawRect(surfaceRect, surfacePaint);

    // 2. Fine wood grain streaks on playing board
    final grainPaint = Paint()
      ..color = Colors.brown.withValues(alpha: 0.035)
      ..strokeWidth = 1.0;

    for (double y = margin + 12; y < size - margin; y += 16.0) {
      canvas.drawLine(Offset(margin, y), Offset(size - margin, y), grainPaint);
    }

    // 3. 3D Overhead Arena Spotlight Illumination (Vignette & Real Light Atmosphere)
    final spotlightPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.72,
        colors: [
          Colors.white.withValues(alpha: 0.14),
          Colors.white.withValues(alpha: 0.04),
          Colors.transparent,
          Colors.black.withValues(alpha: 0.18),
        ],
        stops: const [0.0, 0.40, 0.70, 1.0],
      ).createShader(surfaceRect);

    canvas.drawRect(surfaceRect, spotlightPaint);
  }

  void _renderBoardMarkings(Canvas canvas, double size, Offset center) {
    final pocketCenters = [
      const Offset(50.0, 50.0),
      Offset(size - 50.0, 50.0),
      Offset(50.0, size - 50.0),
      Offset(size - 50.0, size - 50.0),
    ];

    // Absolute Safety: Clip out the 4 corner pockets completely so NO lines or arcs can ever enter the pockets
    canvas.save();
    final clipPath = Path()..addRect(Rect.fromLTWH(0, 0, size, size));
    for (final pc in pocketCenters) {
      clipPath.addOval(
        Rect.fromCircle(
          center: pc,
          radius: BoardConfig.cornerPocketRadius + 2.0,
        ),
      );
    }
    clipPath.fillType = PathFillType.evenOdd;
    canvas.clipPath(clipPath);

    // Crisp dark black lines as in reference photo
    final linePaint = Paint()
      ..color = const Color(0xE6141414)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..isAntiAlias = true;

    final circleFillPaint = Paint()
      ..color = theme.cornerCircleColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final circleInnerRingPaint = Paint()
      ..color = const Color(0x99141414)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..isAntiAlias = true;

    // A. Center Rosette & Circle enclosing 19 pieces
    _renderCenterRosetteAndRing(canvas, center);

    // B. Baselanes (4 sides) - with exact Corner circles as in photo
    const baselineInset = 105.0;
    const circleRadius = 14.0;
    const startX = BoardConfig.baselineMinX;
    const endX = BoardConfig.baselineMaxX;

    void drawHorizontalBaseline(double centerY) {
      final yTop = centerY - circleRadius;
      final yBottom = centerY + circleRadius;
      // Parallel lines between corner circles
      canvas.drawLine(Offset(startX, yTop), Offset(endX, yTop), linePaint);
      canvas.drawLine(
        Offset(startX, yBottom),
        Offset(endX, yBottom),
        linePaint,
      );
      // Tournament Gold / Warm Amber Corner Circles with concentric target details
      final c1 = Offset(startX, centerY);
      final c2 = Offset(endX, centerY);
      canvas.drawCircle(c1, circleRadius, circleFillPaint);
      canvas.drawCircle(c1, circleRadius, linePaint);
      canvas.drawCircle(c1, circleRadius * 0.45, circleInnerRingPaint);
      canvas.drawCircle(c1, 1.8, linePaint);

      canvas.drawCircle(c2, circleRadius, circleFillPaint);
      canvas.drawCircle(c2, circleRadius, linePaint);
      canvas.drawCircle(c2, circleRadius * 0.45, circleInnerRingPaint);
      canvas.drawCircle(c2, 1.8, linePaint);
    }

    void drawVerticalBaseline(double centerX) {
      final xLeft = centerX - circleRadius;
      final xRight = centerX + circleRadius;
      // Parallel lines between corner circles
      canvas.drawLine(Offset(xLeft, startX), Offset(xLeft, endX), linePaint);
      canvas.drawLine(Offset(xRight, startX), Offset(xRight, endX), linePaint);
      // Tournament Gold / Warm Amber Corner Circles with concentric target details
      final c1 = Offset(centerX, startX);
      final c2 = Offset(centerX, endX);
      canvas.drawCircle(c1, circleRadius, circleFillPaint);
      canvas.drawCircle(c1, circleRadius, linePaint);
      canvas.drawCircle(c1, circleRadius * 0.45, circleInnerRingPaint);
      canvas.drawCircle(c1, 1.8, linePaint);

      canvas.drawCircle(c2, circleRadius, circleFillPaint);
      canvas.drawCircle(c2, circleRadius, linePaint);
      canvas.drawCircle(c2, circleRadius * 0.45, circleInnerRingPaint);
      canvas.drawCircle(c2, 1.8, linePaint);
    }

    // Bottom baseline (Player 1)
    drawHorizontalBaseline(size - baselineInset);
    // Top baseline (Player 2)
    drawHorizontalBaseline(baselineInset);
    // Left baseline
    drawVerticalBaseline(baselineInset);
    // Right baseline
    drawVerticalBaseline(size - baselineInset);

    // C. 4 Corner Foul Lines with Pocket Arrows and Foul Arcs (strictly outside pockets)
    void drawCornerFoulGraphics(Offset cornerOrigin, double rotation) {
      canvas.save();
      canvas.translate(cornerOrigin.dx, cornerOrigin.dy);
      canvas.rotate(rotation);

      // 1. Unique Tournament Spear Pointer towards pocket
      // Line base extended further inside the board at (240, 240)
      const pStart = Offset(240.0, 240.0);
      const pTip = Offset(88.0, 88.0); // Safely outside the circular pocket rim

      // Unit direction vectors along the 45-degree diagonal:
      // u: points forward towards the pocket (-1, -1) / sqrt(2)
      // v: points perpendicular to diagonal (-1, 1) / sqrt(2)
      const invSqrt2 = 0.70710678;
      const u = Offset(-invSqrt2, -invSqrt2);
      const v = Offset(-invSqrt2, invSqrt2);

      // A. Large Half-Circle Arc at the end of the arrow (enlarged radius 48.0)
      // Apex of the half-circle meets the arrow base at pStart (240, 240)
      const arcRadius = 48.0;
      final arcCenter = pStart + u * arcRadius; // Offset(206.06, 206.06)
      final arcRect = Rect.fromCircle(center: arcCenter, radius: arcRadius);

      const startAngle = -pi / 4;
      const sweepAngle = pi; // Full 180° Half Circle
      canvas.drawArc(arcRect, startAngle, sweepAngle, false, linePaint);

      // Arrowhead 1 at tip 1 of large half-circle
      final a1x = arcCenter.dx + cos(startAngle) * arcRadius;
      final a1y = arcCenter.dy + sin(startAngle) * arcRadius;
      final t1 = startAngle - pi / 2;
      final arrow1 = Path()
        ..moveTo(a1x, a1y)
        ..lineTo(a1x + 8.5 * cos(t1 - 0.45), a1y + 8.5 * sin(t1 - 0.45))
        ..moveTo(a1x, a1y)
        ..lineTo(a1x + 8.5 * cos(t1 + 0.45), a1y + 8.5 * sin(t1 + 0.45));
      canvas.drawPath(arrow1, linePaint);

      // Arrowhead 2 at tip 2 of large half-circle
      final endAngle = startAngle + sweepAngle;
      final a2x = arcCenter.dx + cos(endAngle) * arcRadius;
      final a2y = arcCenter.dy + sin(endAngle) * arcRadius;
      final t2 = endAngle + pi / 2;
      final arrow2 = Path()
        ..moveTo(a2x, a2y)
        ..lineTo(a2x + 8.5 * cos(t2 - 0.45), a2y + 8.5 * sin(t2 - 0.45))
        ..moveTo(a2x, a2y)
        ..lineTo(a2x + 8.5 * cos(t2 + 0.45), a2y + 8.5 * sin(t2 + 0.45));
      canvas.drawPath(arrow2, linePaint);

      // B. Center Base Finial: Ornamental Engraved Royal Diamond at arrow base & arc apex (240, 240)
      final diamondFillPaint = Paint()
        ..color = theme.cornerCircleColor
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;

      final diamondOutlinePaint = Paint()
        ..color = const Color(0xE6141414)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..isAntiAlias = true;

      final baseDiamond = Path()
        ..moveTo(pStart.dx + u.dx * 7.5, pStart.dy + u.dy * 7.5)
        ..lineTo(pStart.dx + v.dx * 4.5, pStart.dy + v.dy * 4.5)
        ..lineTo(pStart.dx - u.dx * 7.5, pStart.dy - u.dy * 7.5)
        ..lineTo(pStart.dx - v.dx * 4.5, pStart.dy - v.dy * 4.5)
        ..close();
      canvas.drawPath(baseDiamond, diamondFillPaint);
      canvas.drawPath(baseDiamond, diamondOutlinePaint);
      canvas.drawCircle(pStart, 1.8, diamondOutlinePaint);

      // C. Main Pointer Shaft (Double-layered fine laser needle)
      canvas.drawLine(pStart + u * 6.5, pTip - u * 13.5, linePaint);

      // Subtle twin parallel pinstripes along the shaft
      final pinstripePaint = Paint()
        ..color = const Color(0x66141414)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7;
      final shaftStart = pStart + u * 9.0;
      final shaftEnd = pTip - u * 20.0;
      canvas.drawLine(shaftStart + v * 1.8, shaftEnd + v * 1.8, pinstripePaint);
      canvas.drawLine(shaftStart - v * 1.8, shaftEnd - v * 1.8, pinstripePaint);

      // D. Unique Royal Arrowhead & Fletchings at pTip
      const headLen = 13.5;
      const headWingWidth = 6.8;
      final headBase = pTip - u * headLen;
      final headLeftWing = headBase - v * headWingWidth;
      final headRightWing = headBase + v * headWingWidth;
      final headInnerBarb = pTip - u * (headLen - 4.5);

      final leftHeadFacet = Path()
        ..moveTo(pTip.dx, pTip.dy)
        ..lineTo(headLeftWing.dx, headLeftWing.dy)
        ..lineTo(headInnerBarb.dx, headInnerBarb.dy)
        ..close();

      final rightHeadFacet = Path()
        ..moveTo(pTip.dx, pTip.dy)
        ..lineTo(headRightWing.dx, headRightWing.dy)
        ..lineTo(headInnerBarb.dx, headInnerBarb.dy)
        ..close();

      // Dual-tone 3D arrowhead facet shading (charcoal black & royal amber gold)
      canvas.drawPath(
        leftHeadFacet,
        Paint()
          ..color = const Color(0xE6141414)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(rightHeadFacet, diamondFillPaint);
      canvas.drawPath(leftHeadFacet, diamondOutlinePaint);
      canvas.drawPath(rightHeadFacet, diamondOutlinePaint);

      // Trailing Guide Fletchings (Chevrons)
      void drawChevron(double distFromTip, double wingSpan) {
        final cApex = pTip - u * distFromTip;
        final cLeft = cApex - u * 3.5 - v * wingSpan;
        final cRight = cApex - u * 3.5 + v * wingSpan;
        final cPath = Path()
          ..moveTo(cLeft.dx, cLeft.dy)
          ..lineTo(cApex.dx, cApex.dy)
          ..lineTo(cRight.dx, cRight.dy);
        canvas.drawPath(cPath, linePaint);
      }

      drawChevron(16.5, 4.8);
      drawChevron(22.0, 3.8);

      canvas.restore();
    }

    drawCornerFoulGraphics(const Offset(0, 0), 0);
    drawCornerFoulGraphics(Offset(size, 0), pi / 2);
    drawCornerFoulGraphics(Offset(size, size), pi);
    drawCornerFoulGraphics(Offset(0, size), 3 * pi / 2);

    canvas.restore(); // Restore clipPath
  }

  void _renderCenterRosetteAndRing(Canvas canvas, Offset center) {
    final ringPaint = Paint()
      ..color = const Color(0xE6141414)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..isAntiAlias = true;

    // 1. Outer Circle enclosing all 19 pieces (as clearly seen in reference photo)
    const piecesEnclosingRadius = 72.0;
    canvas.drawCircle(center, piecesEnclosingRadius, ringPaint);

    // 2. Subtle decorative compass star underneath coins
    const rStar = 66.0;
    const rMinor = 44.0;
    final starPaint = Paint()
      ..color = const Color(0x33141414)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i < 8; i++) {
      final angle = i * pi / 4;
      final len = (i % 2 == 0) ? rStar : rMinor;
      canvas.drawLine(
        center,
        Offset(center.dx + cos(angle) * len, center.dy + sin(angle) * len),
        starPaint,
      );
    }

    // Inner center circle (exact queen spot)
    canvas.drawCircle(center, 15.5, ringPaint);
    canvas.drawCircle(
      center,
      15.5,
      Paint()
        ..color = const Color(0x33C62828)
        ..style = PaintingStyle.fill,
    );
  }

  void _renderPockets(Canvas canvas, double size) {
    final pocketCenters = [
      const Offset(50.0, 50.0),
      Offset(size - 50.0, 50.0),
      Offset(50.0, size - 50.0),
      Offset(size - 50.0, size - 50.0),
    ];

    const pocketRadius = BoardConfig.cornerPocketRadius; // 38.0

    for (final pCenter in pocketCenters) {
      // 1. Soft outer drop shadow onto playing field
      canvas.drawCircle(
        pCenter,
        pocketRadius + 3.0,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0),
      );

      // 2. Completely solid, pristine deep black hole (NOTHING inside!)
      final holePaint = Paint()
        ..color = const Color(0xFF020202)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pCenter, pocketRadius, holePaint);

      // Subtle inner depth ring near the edge of the hole
      final innerShadowPaint = Paint()
        ..shader = RadialGradient(
          colors: const [
            Colors.transparent,
            Colors.transparent,
            Color(0x99000000),
          ],
          stops: const [0.0, 0.75, 1.0],
        ).createShader(Rect.fromCircle(center: pCenter, radius: pocketRadius));
      canvas.drawCircle(pCenter, pocketRadius, innerShadowPaint);

      // 3. Complete, circular, unbroken 3D metallic chrome rim
      final rimRect = Rect.fromCircle(center: pCenter, radius: pocketRadius);
      final metallicRimPaint = Paint()
        ..shader = const SweepGradient(
          colors: [
            Color(0xFFF3F4F6), // Bright specular glint
            Color(0xFF4B5563),
            Color(0xFF1F2937),
            Color(0xFF9CA3AF),
            Color(0xFF111827),
            Color(0xFFF3F4F6),
          ],
          stops: [0.0, 0.22, 0.48, 0.72, 0.88, 1.0],
          transform: GradientRotation(-pi / 4),
        ).createShader(rimRect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5;

      canvas.drawCircle(pCenter, pocketRadius - 0.5, metallicRimPaint);

      // Specular highlight line on metallic rim
      canvas.drawCircle(
        pCenter,
        pocketRadius - 1.8,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }
  }

  void _renderCushions(Canvas canvas, double size) {
    const pocketRadius = BoardConfig.cornerPocketRadius; // 28.0
    const cushionInner = 43.0;
    const cushionOuter = 28.0;

    final dx = sqrt(pocketRadius * pocketRadius - 49.0);
    final p1 = 50.0 + dx;
    final p2 = size - 50.0 - dx;

    final phi = atan2(7.0, dx);
    final sweep = -(pi / 2 + 2 * phi);

    final innerCushionPath = Path();
    // 1. Top cushion edge (left to right)
    innerCushionPath.moveTo(p1, cushionInner);
    innerCushionPath.lineTo(p2, cushionInner);

    // 2. Top-Right Corner Arc around (size - 50, 50)
    final trCenter = Offset(size - 50.0, 50.0);
    final trRect = Rect.fromCircle(center: trCenter, radius: pocketRadius);
    innerCushionPath.arcTo(trRect, pi + phi, sweep, false);

    // 3. Right cushion edge (top to bottom)
    innerCushionPath.lineTo(size - cushionInner, size - p1);

    // 4. Bottom-Right Corner Arc around (size - 50, size - 50)
    final brCenter = Offset(size - 50.0, size - 50.0);
    final brRect = Rect.fromCircle(center: brCenter, radius: pocketRadius);
    innerCushionPath.arcTo(brRect, -pi / 2 + phi, sweep, false);

    // 5. Bottom cushion edge (right to left)
    innerCushionPath.lineTo(p1, size - cushionInner);

    // 6. Bottom-Left Corner Arc around (50, size - 50)
    final blCenter = Offset(50.0, size - 50.0);
    final blRect = Rect.fromCircle(center: blCenter, radius: pocketRadius);
    innerCushionPath.arcTo(blRect, phi, sweep, false);

    // 7. Left cushion edge (bottom to top)
    innerCushionPath.lineTo(cushionInner, p1);

    // 8. Top-Left Corner Arc around (50, 50)
    final tlCenter = const Offset(50.0, 50.0);
    final tlRect = Rect.fromCircle(center: tlCenter, radius: pocketRadius);
    innerCushionPath.arcTo(tlRect, pi / 2 + phi, sweep, false);
    innerCushionPath.close();

    // Cushion Solid Frame (between outer frame and rounded inner perimeter)
    final outerCushionPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            cushionOuter,
            cushionOuter,
            size - cushionOuter * 2,
            size - cushionOuter * 2,
          ),
          const Radius.circular(16.0),
        ),
      );

    final cushionSolidPath = Path.combine(
      PathOperation.difference,
      outerCushionPath,
      innerCushionPath,
    );

    // Wood Shader for Cushions
    final cushionPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [theme.cushionColor, theme.frameWoodDark],
      ).createShader(Rect.fromLTWH(0, 0, size, size));

    canvas.drawPath(cushionSolidPath, cushionPaint);

    // 3D Inner Drop Shadow from Cushions onto Playing Field (Dual-Pass Depth)
    final cushionDeepShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.36)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.5);
    canvas.drawPath(innerCushionPath, cushionDeepShadow);

    final cushionContactShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.58)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
    canvas.drawPath(innerCushionPath, cushionContactShadow);

    // Cushion Bevel Highlight Line with directional light sheen
    final cushionBevelPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.white.withValues(alpha: 0.40),
          Colors.white.withValues(alpha: 0.08),
          Colors.black.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0.08),
          Colors.white.withValues(alpha: 0.40),
        ],
        stops: const [0.0, 0.35, 0.65, 0.85, 1.0],
        transform: const GradientRotation(-pi / 4),
      ).createShader(Rect.fromLTWH(0, 0, size, size))
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    canvas.drawPath(innerCushionPath, cushionBevelPaint);

    // Crisp Tournament Boundary Line (Runs along cushion and rounds seamlessly into pocket)
    final boundaryLinePaint = Paint()
      ..color = const Color(0xE6141414)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;
    canvas.drawPath(innerCushionPath, boundaryLinePaint);
  }
}
