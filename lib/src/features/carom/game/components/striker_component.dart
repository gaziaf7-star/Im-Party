import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../domain/models/game_models.dart';
import '../../domain/physics/carom_physics.dart';
import '../../domain/physics/trajectory_predictor.dart';

class StrikerComponent extends Component {
  final PhysicsBody body;
  bool isPositioning = false;
  bool isValidPosition = true;
  bool isAiming = false;
  Vector2? aimVector; // Direction of shot
  double strikePower = 0.0; // 0.0 to 1.0
  TrajectoryPath? trajectory;

  static ui.Picture? _cachedStrikerPicture;

  // Cached reusable paints for aiming visuals
  static final Paint _dashedGuidePaint = Paint()
    ..color = Colors.white.withValues(alpha: 0.22)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4;

  static final Paint _aimArrowGlowPaint = Paint()
    ..color = const Color(0x44D946EF)
    ..strokeWidth = 8.0
    ..strokeCap = StrokeCap.round;

  static final Paint _aimArrowHeadPaint = Paint()
    ..color = const Color(0xFFC026D3)
    ..strokeWidth = 3.5
    ..strokeCap = StrokeCap.round;

  static final Paint _ghostRingPaint = Paint()
    ..color = const Color(0xFFC026D3).withValues(alpha: 0.7)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  static final Paint _pieceArrowPaint = Paint()
    ..color = const Color(0xFFFBBF24)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.0;

  static ui.Picture? _cachedGuideWheelPicture;

  static final Paint _aimArrowBodyPaint = Paint()
    ..color = const Color(0xFFC026D3)
    ..strokeWidth = 4.0
    ..strokeCap = StrokeCap.round;

  static final Paint _trajectoryBatchPaint = Paint()
    ..color = Colors.white.withValues(alpha: 0.9)
    ..strokeWidth = 3.6
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  static final Paint _targetPieceTrajectoryPaint = Paint()
    ..color = const Color(0xFFFBBF24)
    ..strokeWidth = 3.2
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  static final Paint _powerTrackPaint = Paint()
    ..color = Colors.white.withValues(alpha: 0.16)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.2;

  static final Paint _powerArcPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 3.8;

  static final Paint _powerArcGlowPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 7.0
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

  static final Paint _slingshotTetherPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.2;

  static final Paint _slingshotNodePaint = Paint()
    ..style = PaintingStyle.fill;

  static final Paint _slingshotNodeBorderPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.6;

  static Color _getPowerColor(double p) {
    if (p <= 0.45) {
      return Color.lerp(
        const Color(0xFF38BDF8), // Electric Cyan
        const Color(0xFFFBBF24), // Vibrant Gold
        p / 0.45,
      )!;
    } else {
      return Color.lerp(
        const Color(0xFFFBBF24), // Vibrant Gold
        const Color(0xFFEF4444), // Intense Crimson Red
        (p - 0.45) / 0.55,
      )!;
    }
  }

  StrikerComponent({required this.body});

  static void _ensureInitialized() {
    _cachedStrikerPicture ??= _buildStrikerPicture();
    _cachedGuideWheelPicture ??= _buildGuideWheelPicture();
  }

  static ui.Picture _buildGuideWheelPicture() {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(-95, -95, 190, 190));
    const guideRadius = 90.0;
    const totalDashes = 36;
    for (int i = 0; i < totalDashes; i += 2) {
      final startAngle = i * (2 * pi / totalDashes);
      const sweep = (2 * pi / totalDashes) * 0.7;
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: guideRadius),
        startAngle,
        sweep,
        false,
        _dashedGuidePaint,
      );
    }
    return recorder.endRecording();
  }


  static ui.Picture _buildStrikerPicture() {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(-40, -40, 80, 80));
    const r = BoardConfig.strikerRadius;
    const center = Offset.zero;
    const scale = 1.0;
    const opacity = 1.0;

    final rect = Rect.fromCircle(center: center, radius: r);

    // 1. Dual-Layer 3D Drop Shadow (Sharp Contact Occlusion + Soft Ambient Floor Shadow)
    final ambientShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.42 * opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.5);
    canvas.drawCircle(
      center.translate(3.0 * scale, 4.5 * scale),
      r + 0.8 * scale,
      ambientShadowPaint,
    );

    final contactShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.60 * opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.8);
    canvas.drawCircle(
      center.translate(1.4 * scale, 2.0 * scale),
      r - 0.4 * scale,
      contactShadowPaint,
    );

    // 2. 3D Cylindrical Side Edge / Thickness (simulating ~8mm heavy acrylic tournament striker)
    final edgeRect = Rect.fromCircle(
      center: center.translate(1.2 * scale, 1.8 * scale),
      radius: r,
    );
    final edgePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.30 * opacity),
          Colors.transparent,
          Colors.black.withValues(alpha: 0.70 * opacity),
        ],
        stops: const [0.0, 0.35, 1.0],
      ).createShader(edgeRect)
      ..isAntiAlias = true;
    canvas.drawCircle(center.translate(1.2 * scale, 1.8 * scale), r, edgePaint);

    // 3. Base Ivory / Cream Disc Body (3D Convex Radial Gradient)
    final ivoryShader = RadialGradient(
      center: const Alignment(-0.35, -0.35),
      radius: 0.98,
      colors: [
        const Color(0xFFFFFFFF)
            .withValues(alpha: opacity), // Bright top-left specular crest
        const Color(0xFFFAF6EB).withValues(alpha: opacity),
        const Color(0xFFEEE3CA).withValues(alpha: opacity),
        const Color(0xFFD6C29E).withValues(alpha: opacity),
        const Color(0xFFB59E78)
            .withValues(alpha: opacity), // Undercut shadow edge
      ],
      stops: const [0.0, 0.25, 0.55, 0.85, 1.0],
    ).createShader(rect);

    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = ivoryShader
        ..isAntiAlias = true,
    );

    // 4. 3D Beveled Outer Chamfer Rim with Sweep Light Reflection
    final rimBevelPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.white.withValues(alpha: 0.55 * opacity),
          const Color(0xFF333333).withValues(alpha: 0.85 * opacity),
          Colors.black.withValues(alpha: 0.90 * opacity),
          const Color(0xFF444444).withValues(alpha: 0.85 * opacity),
          Colors.white.withValues(alpha: 0.55 * opacity),
        ],
        stops: const [0.0, 0.35, 0.65, 0.85, 1.0],
        transform: const GradientRotation(-pi / 4),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4 * scale
      ..isAntiAlias = true;
    canvas.drawCircle(center, r - 0.7 * scale, rimBevelPaint);

    // Subtle ivory bevel shoulder groove
    final bevelPaint = Paint()
      ..color = const Color(0x66B09B7A).withValues(alpha: 0.7 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9 * scale;
    canvas.drawCircle(center, r * 0.86, bevelPaint);

    // Concentric dark engraved ring with 3D light edge
    final grooveRingPaint = Paint()
      ..color = const Color(0xFF1F1F1F).withValues(alpha: 0.88 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3 * scale
      ..isAntiAlias = true;
    canvas.drawCircle(center, r * 0.72, grooveRingPaint);

    // 5. Iconic 8-Pointed Engraved Black Compass Star (Signature 3D Carrom Striker Design)
    final blackFacetPaint = Paint()
      ..color = const Color(0xFF0F0F0F).withValues(alpha: opacity)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final lightFacetPaint = Paint()
      ..color = const Color(0xFF424242).withValues(alpha: 0.95 * opacity)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final starLinePaint = Paint()
      ..color = const Color(0xFF0F0F0F).withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8 * scale
      ..isAntiAlias = true;

    // Outer enclosing circle for star
    canvas.drawCircle(center, r * 0.60, starLinePaint);

    final rMajor = r * 0.58; // 4 Cardinal points (N, E, S, W)
    final rMinor = r * 0.40; // 4 Diagonal points (NE, SE, SW, NW)
    final baseW = 3.6 * scale;

    void drawStarPoint(double angle, double length) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);

      // Dark facet
      final pDark = Path()
        ..moveTo(0, -length)
        ..lineTo(-baseW, 0)
        ..lineTo(0, 0)
        ..close();
      canvas.drawPath(pDark, blackFacetPaint);

      // Light/shaded facet with subtle 3D highlight
      final pLight = Path()
        ..moveTo(0, -length)
        ..lineTo(baseW, 0)
        ..lineTo(0, 0)
        ..close();
      canvas.drawPath(pLight, lightFacetPaint);

      // Crisp outline ridgeline
      final pBorder = Path()
        ..moveTo(-baseW, 0)
        ..lineTo(0, -length)
        ..lineTo(baseW, 0);
      canvas.drawPath(pBorder, starLinePaint);

      canvas.restore();
    }

    // 4 Cardinal points
    drawStarPoint(0, rMajor);
    drawStarPoint(pi / 2, rMajor);
    drawStarPoint(pi, rMajor);
    drawStarPoint(3 * pi / 2, rMajor);

    // 4 Diagonal points
    drawStarPoint(pi / 4, rMinor);
    drawStarPoint(3 * pi / 4, rMinor);
    drawStarPoint(5 * pi / 4, rMinor);
    drawStarPoint(7 * pi / 4, rMinor);

    // 6. 3D Raised Central Gemstone / Metallic Dome Button
    final domeRect = Rect.fromCircle(center: center, radius: r * 0.17);
    final domePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.35),
        radius: 0.8,
        colors: [
          Colors.white.withValues(alpha: opacity),
          const Color(0xFFFACC15)
              .withValues(alpha: opacity), // Gold rim reflection
          const Color(0xFF854D0E).withValues(alpha: opacity),
          const Color(0xFF1E1E1E).withValues(alpha: opacity),
        ],
        stops: const [0.0, 0.35, 0.7, 1.0],
      ).createShader(domeRect);
    canvas.drawCircle(center, r * 0.16, domePaint);
    canvas.drawCircle(center, r * 0.16, starLinePaint);

    // Specular pinpoint glint on center dome
    canvas.drawCircle(
      center.translate(-r * 0.05, -r * 0.05),
      r * 0.035,
      Paint()..color = Colors.white.withValues(alpha: 0.9 * opacity),
    );

    // 7. Lacquered 3D Specular Gloss Arc (Tournament Sheen)
    final specularArc = Path()
      ..addArc(
        Rect.fromCircle(
          center: center.translate(-r * 0.25, -r * 0.25),
          radius: r * 0.55,
        ),
        pi * 0.9,
        pi * 0.7,
      );
    canvas.drawPath(
      specularArc,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.45 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 * scale
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
    );

    return recorder.endRecording();
  }

  static void renderStrikerVisual(
    Canvas canvas,
    Offset center,
    double r, {
    double opacity = 1.0,
    double scale = 1.0,
  }) {
    if (r <= 0.5) return;
    _ensureInitialized();

    canvas.save();
    canvas.translate(center.dx, center.dy);
    final effectiveScale = scale * (r / BoardConfig.strikerRadius);
    if (effectiveScale != 1.0) {
      canvas.scale(effectiveScale);
    }

    if (opacity < 1.0) {
      canvas.saveLayer(
        const Rect.fromLTWH(-35, -35, 70, 70),
        Paint()..color = Color.fromRGBO(255, 255, 255, opacity),
      );
      canvas.drawPicture(_cachedStrikerPicture!);
      canvas.restore();
    } else {
      canvas.drawPicture(_cachedStrikerPicture!);
    }

    canvas.restore();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (body.isPocketed) return;

    final center = Offset(body.position.x, body.position.y);
    final r = body.radius * body.scale;
    if (r <= 0.5) return;

    canvas.save();

    // 1. Aiming Trajectory Preview (when aiming)
    if (isAiming && !body.isSinking) {
      _renderAimingVisuals(canvas, center);
    }

    // 2. Baseline Positioning Indicator & Validation Glow
    if (isPositioning && !body.isSinking) {
      _renderPositioningGlow(canvas, center, r);
    }

    // 4. Render Striker with physical rotational spin
    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (body.angle != 0.0) {
      canvas.rotate(body.angle);
    }
    renderStrikerVisual(
      canvas,
      Offset.zero,
      r,
      opacity: body.opacity,
      scale: body.scale,
    );
    canvas.restore();

    canvas.restore();
  }

  void _renderPositioningGlow(Canvas canvas, Offset center, double r) {
    final glowColor = isValidPosition
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);
    final glowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, r + 5.0, glowPaint);

    final borderPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, r + 2.5, borderPaint);
  }

  void _renderAimingVisuals(Canvas canvas, Offset center) {
    if (aimVector == null) return;
    final dir = aimVector!.normalized();

    final p = strikePower.clamp(0.0, 1.0);
    final powerColor = _getPowerColor(p);

    _ensureInitialized();

    // A. Dashed circular guide wheel around striker (Cached Picture - 1 draw call instead of 18)
    if (_cachedGuideWheelPicture != null) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.drawPicture(_cachedGuideWheelPicture!);
      canvas.restore();
    }

    // B. Power Gauge Arc around the Striker
    final gaugeRadius = body.radius + 5.5;
    final gaugeRect = Rect.fromCircle(center: center, radius: gaugeRadius);
    // Background track
    canvas.drawCircle(center, gaugeRadius, _powerTrackPaint);
    // Active power arc (sweeps with power)
    if (p > 0.02) {
      final sweepAngle = 2 * pi * p;
      _powerArcGlowPaint.color = powerColor.withValues(alpha: 0.45);
      canvas.drawArc(gaugeRect, -pi / 2, sweepAngle, false, _powerArcGlowPaint);
      _powerArcPaint.color = powerColor;
      canvas.drawArc(gaugeRect, -pi / 2, sweepAngle, false, _powerArcPaint);
    }

    // C. Slingshot Pull-Back Tension Line & Grip Node (Opposite of aim direction)
    if (p > 0.05) {
      final pullDir = Offset(-dir.x, -dir.y);
      final pullDist = body.radius + 8.0 + p * 36.0;
      final pullStart = Offset(
        center.dx + pullDir.dx * (body.radius + 2.0),
        center.dy + pullDir.dy * (body.radius + 2.0),
      );
      final pullEnd = Offset(
        center.dx + pullDir.dx * pullDist,
        center.dy + pullDir.dy * pullDist,
      );

      _slingshotTetherPaint.color = powerColor.withValues(alpha: 0.65);
      canvas.drawLine(pullStart, pullEnd, _slingshotTetherPaint);

      final nodeRadius = 4.0 + p * 2.0;
      _slingshotNodePaint.color = powerColor;
      canvas.drawCircle(pullEnd, nodeRadius, _slingshotNodePaint);
      canvas.drawCircle(pullEnd, nodeRadius, _slingshotNodeBorderPaint);
    }

    // D. Forward Aim Direction Arrow (Scales dynamically with power)
    final arrowLength = 36.0 + p * 64.0;
    final arrowStart = Offset(
      center.dx + dir.x * (body.radius + 2.0),
      center.dy + dir.y * (body.radius + 2.0),
    );
    final arrowEnd = Offset(
      arrowStart.dx + dir.x * arrowLength,
      arrowStart.dy + dir.y * arrowLength,
    );

    // Glow
    _aimArrowGlowPaint.color = powerColor.withValues(alpha: 0.35 + p * 0.20);
    _aimArrowGlowPaint.strokeWidth = 6.0 + p * 3.0;
    canvas.drawLine(arrowStart, arrowEnd, _aimArrowGlowPaint);

    // Body
    _aimArrowBodyPaint.color = powerColor;
    _aimArrowBodyPaint.strokeWidth = 3.6 + p * 1.4;
    canvas.drawLine(arrowStart, arrowEnd, _aimArrowBodyPaint);

    // Arrowhead
    final angle = atan2(dir.y, dir.x);
    final headSize = 13.0 + p * 4.0;
    final h1 = Offset(
      arrowEnd.dx - cos(angle - 0.4) * headSize,
      arrowEnd.dy - sin(angle - 0.4) * headSize,
    );
    final h2 = Offset(
      arrowEnd.dx - cos(angle + 0.4) * headSize,
      arrowEnd.dy - sin(angle + 0.4) * headSize,
    );
    _aimArrowHeadPaint.color = powerColor;
    _aimArrowHeadPaint.strokeWidth = 3.2 + p * 1.2;
    canvas.drawLine(arrowEnd, h1, _aimArrowHeadPaint);
    canvas.drawLine(arrowEnd, h2, _aimArrowHeadPaint);

    // D. White Dotted Trajectory Ray to Target Coin (Batched points - 1 GPU call!)
    if (trajectory != null && trajectory!.points.length >= 2) {
      final points = trajectory!.points;
      final dotOffsets = <Offset>[];

      double accumulatedDist = 0.0;
      var cur = Vector2(arrowEnd.dx, arrowEnd.dy);

      for (int i = 1; i < points.length; i++) {
        final targetPt = points[i];
        final segmentVec = targetPt - cur;
        final segmentLen = segmentVec.length;
        if (segmentLen <= 0) continue;
        final segDir = segmentVec / segmentLen;

        for (double d = 6.0; d < segmentLen; d += 9.0) {
          final dotP = cur + segDir * d;
          dotOffsets.add(Offset(dotP.x, dotP.y));
          accumulatedDist += 9.0;
          if (accumulatedDist > 880.0) break;
        }
        cur = targetPt;
        if (accumulatedDist > 880.0) break;
      }

      if (dotOffsets.isNotEmpty) {
        canvas.drawPoints(
          ui.PointMode.points,
          dotOffsets,
          _trajectoryBatchPaint,
        );
      }

      // E. Target Piece Impact & Deflection Preview with Extended Guidance
      final hit = trajectory!.hit;
      if (hit != null) {
        final ghostCenter = Offset(
          hit.ghostStrikerPos.x,
          hit.ghostStrikerPos.y,
        );

        // Ghost Striker ring at target
        canvas.drawCircle(ghostCenter, body.radius, _ghostRingPaint);

        // Predicted Target Piece Direction Arrow
        final piecePos = Offset(
          hit.targetPiece.position.x,
          hit.targetPiece.position.y,
        );
        final pDir = hit.pieceDirection;
        const pArrowLen = 45.0;
        final pArrowEnd = Offset(
          piecePos.dx + pDir.x * pArrowLen,
          piecePos.dy + pDir.y * pArrowLen,
        );

        canvas.drawLine(piecePos, pArrowEnd, _pieceArrowPaint);

        // Target piece arrowhead
        final pAngle = atan2(pDir.y, pDir.x);
        final ph1 = Offset(
          pArrowEnd.dx - cos(pAngle - 0.4) * 12,
          pArrowEnd.dy - sin(pAngle - 0.4) * 12,
        );
        final ph2 = Offset(
          pArrowEnd.dx - cos(pAngle + 0.4) * 12,
          pArrowEnd.dy - sin(pAngle + 0.4) * 12,
        );
        canvas.drawLine(pArrowEnd, ph1, _pieceArrowPaint);
        canvas.drawLine(pArrowEnd, ph2, _pieceArrowPaint);

        // Extended coin trajectory dots (up to 200px) so player sees exact cut-shot direction
        final pieceDots = <Offset>[];
        for (double pd = pArrowLen + 8.0; pd < 200.0; pd += 10.0) {
          pieceDots.add(
            Offset(piecePos.dx + pDir.x * pd, piecePos.dy + pDir.y * pd),
          );
        }
        if (pieceDots.isNotEmpty) {
          canvas.drawPoints(
            ui.PointMode.points,
            pieceDots,
            _targetPieceTrajectoryPaint,
          );
        }
      }
    }
  }
}
