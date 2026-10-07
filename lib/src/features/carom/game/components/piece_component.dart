import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../domain/models/game_models.dart';
import '../../domain/physics/carom_physics.dart';

class PieceComponent extends Component {
  final PhysicsBody body;

  static ui.Picture? _cachedWhite;
  static ui.Picture? _cachedBlack;
  static ui.Picture? _cachedQueen;

  PieceComponent({required this.body});

  static void _ensureInitialized() {
    _cachedWhite ??= _buildPiecePicture(PieceType.white);
    _cachedBlack ??= _buildPiecePicture(PieceType.black);
    _cachedQueen ??= _buildPiecePicture(PieceType.queen);
  }

  static ui.Picture _buildPiecePicture(PieceType type) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(-35, -35, 70, 70));
    const r = BoardConfig.pieceRadius;
    const center = Offset.zero;

    // 1. Dual-Layer 3D Drop Shadow (Contact Occlusion + Soft Ambient Floor Shadow)
    final ambientShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.38)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawCircle(const Offset(2.2, 3.2), r + 0.4, ambientShadowPaint);

    final contactShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.4);
    canvas.drawCircle(const Offset(1.0, 1.5), r - 0.2, contactShadowPaint);

    // 2. 3D Cylindrical Side Edge / Thickness (simulating ~6mm wooden coin puck profile)
    final edgeRect = Rect.fromCircle(center: const Offset(0.9, 1.3), radius: r);
    final edgePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.25),
          Colors.transparent,
          Colors.black.withValues(alpha: 0.65),
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(edgeRect)
      ..isAntiAlias = true;
    canvas.drawCircle(const Offset(0.9, 1.3), r, edgePaint);

    // 3. Base Disc with Authentic Material 3D Convex Radial Gradient
    final rect = Rect.fromCircle(center: center, radius: r);
    final discPaint = Paint()..isAntiAlias = true;

    Color grooveShadowColor;
    Color grooveHighlightColor;

    switch (type) {
      case PieceType.white:
        discPaint.shader = const RadialGradient(
          center: Alignment(-0.35, -0.35),
          radius: 0.95,
          colors: [
            Color(0xFFFFFFFF), // Pure top specular highlight
            Color(0xFFFFF8EC),
            Color(0xFFF3E7D3),
            Color(0xFFE2CEB1),
            Color(0xFFC7B191), // Deep shadow edge
          ],
          stops: [0.0, 0.25, 0.55, 0.85, 1.0],
        ).createShader(rect);
        grooveShadowColor = const Color(0x80785E3D);
        grooveHighlightColor = const Color(0xCCFFFFFF);
        break;

      case PieceType.black:
        discPaint.shader = const RadialGradient(
          center: Alignment(-0.35, -0.35),
          radius: 0.95,
          colors: [
            Color(0xFF4A4A4F), // Top metallic specular sheen
            Color(0xFF323236),
            Color(0xFF202022),
            Color(0xFF131314),
            Color(0xFF080809), // Midnight ebony undercut
          ],
          stops: [0.0, 0.2, 0.5, 0.8, 1.0],
        ).createShader(rect);
        grooveShadowColor = const Color(0xB3000000);
        grooveHighlightColor = const Color(0x5594A3B8);
        break;

      case PieceType.queen:
        discPaint.shader = const RadialGradient(
          center: Alignment(-0.35, -0.35),
          radius: 0.95,
          colors: [
            Color(0xFFFF6B6B), // Brilliant ruby specular crest
            Color(0xFFE61E1E),
            Color(0xFFC21010),
            Color(0xFF990000),
            Color(0xFF6B0000), // Rich crimson shadow rim
          ],
          stops: [0.0, 0.2, 0.5, 0.8, 1.0],
        ).createShader(rect);
        grooveShadowColor = const Color(0x994D0000);
        grooveHighlightColor = const Color(0x80FFD1D1);
        break;

      case PieceType.striker:
        return recorder.endRecording();
    }

    canvas.drawCircle(center, r, discPaint);

    // 4. Authentic 3D Carved Lathe Concentric Grooves (Directional Top-Left Highlight & Bottom-Right Shadow)
    void drawCarvedRing(double radius, double strokeW) {
      final ringRect = Rect.fromCircle(center: center, radius: radius);

      // Deep recess shadow groove
      canvas.drawCircle(
        center.translate(0.3, 0.4),
        radius,
        Paint()
          ..color = grooveShadowColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..isAntiAlias = true,
      );

      // Sharp light-facing highlight arc (facing top-left -135°)
      canvas.drawArc(
        ringRect,
        pi * 0.85,
        pi * 0.95,
        false,
        Paint()
          ..color = grooveHighlightColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW * 0.65
          ..isAntiAlias = true,
      );
    }

    // Outer rim groove
    drawCarvedRing(r * 0.76, 1.4);
    // Middle concentric ring
    drawCarvedRing(r * 0.50, 1.2);
    // Inner recessed ring
    drawCarvedRing(r * 0.26, 1.0);

    // 5. 3D Center Button / Jewel Core
    if (type == PieceType.queen) {
      // Queen's Royal 3D Gold Rosette Crown Center
      final rosetteRect = Rect.fromCircle(center: center, radius: r * 0.24);
      final goldShader = const RadialGradient(
        center: Alignment(-0.3, -0.3),
        radius: 0.8,
        colors: [
          Color(0xFFFFF2A3),
          Color(0xFFFACC15),
          Color(0xFFCA8A04),
          Color(0xFF78350F),
        ],
      ).createShader(rosetteRect);

      canvas.drawCircle(center, r * 0.22, Paint()..shader = goldShader);
      canvas.drawCircle(
        center,
        r * 0.22,
        Paint()
          ..color = const Color(0x8078350F)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
      // Center ruby pip
      canvas.drawCircle(
        center.translate(-0.3, -0.3),
        r * 0.08,
        Paint()..color = const Color(0xFFFF4D4D),
      );
    } else {
      // White & Black: 3D Spherical Central Dome Depression
      final centerCorePaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          radius: 0.75,
          colors: [
            grooveHighlightColor.withValues(alpha: 0.6),
            grooveShadowColor.withValues(alpha: 0.4),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: r * 0.18));
      canvas.drawCircle(center, r * 0.16, centerCorePaint);
    }

    // 6. 3D Chamfered Outer Rim Highlight (light catch on top-left edge)
    final rimHighlightPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.white.withValues(alpha: 0.45),
          Colors.transparent,
          Colors.black.withValues(alpha: 0.35),
          Colors.transparent,
          Colors.white.withValues(alpha: 0.45),
        ],
        stops: const [0.0, 0.35, 0.65, 0.85, 1.0],
        transform: GradientRotation(-pi / 4),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, r - 0.5, rimHighlightPaint);

    // 7. Lacquered 3D Specular Sheen (fine curved glass reflection in upper-left quadrant)
    final specularArc = Path()
      ..addArc(
        Rect.fromCircle(
          center: center.translate(-r * 0.22, -r * 0.22),
          radius: r * 0.52,
        ),
        pi * 0.9,
        pi * 0.7,
      );
    canvas.drawPath(
      specularArc,
      Paint()
        ..color = Colors.white.withValues(
          alpha: type == PieceType.black ? 0.22 : 0.42,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0),
    );

    return recorder.endRecording();
  }

  static void ensureInitialized() {
    _ensureInitialized();
  }

  static void renderPiece(Canvas canvas, PhysicsBody body) {
    if (body.isPocketed) return;

    final r = body.radius * body.scale;
    if (r <= 0.5) return;

    _ensureInitialized();

    ui.Picture? pic;
    switch (body.type) {
      case PieceType.white:
        pic = _cachedWhite;
        break;
      case PieceType.black:
        pic = _cachedBlack;
        break;
      case PieceType.queen:
        pic = _cachedQueen;
        break;
      case PieceType.striker:
        return;
    }

    if (pic == null) return;

    canvas.save();
    canvas.translate(body.position.x, body.position.y);
    if (body.angle != 0.0) {
      canvas.rotate(body.angle);
    }

    if (body.isSinking) {
      canvas.scale(body.scale);
      if (body.opacity < 0.98) {
        final alpha = (body.opacity.clamp(0.0, 1.0) * 255).round();
        canvas.saveLayer(
          const Rect.fromLTWH(-30, -30, 60, 60),
          Paint()..color = Color.fromARGB(alpha, 255, 255, 255),
        );
        canvas.drawPicture(pic);
        canvas.restore();
        canvas.restore();
        return;
      }
    }

    canvas.drawPicture(pic);
    canvas.restore();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    renderPiece(canvas, body);
  }
}

/// Batched high-performance layer that renders all stationary carom pieces
/// in a SINGLE cached ui.Picture draw pass, reducing CPU/GPU overhead by ~95%
/// during aiming, positioning, and waiting phases.
class PiecesLayerComponent extends Component {
  final List<PhysicsBody> bodies;
  final bool Function()? isMovingProvider;

  ui.Picture? _cachedStationaryPicture;
  bool _isStationaryDirty = true;

  PiecesLayerComponent({required this.bodies, this.isMovingProvider});

  void markDirty() {
    _isStationaryDirty = true;
  }

  void _rebuildStationaryCache() {
    _cachedStationaryPicture?.dispose();
    _cachedStationaryPicture = null;

    final recorder = ui.PictureRecorder();
    final cacheCanvas = Canvas(
      recorder,
      const Rect.fromLTWH(0, 0, BoardConfig.boardSize, BoardConfig.boardSize),
    );

    PieceComponent.ensureInitialized();

    for (int i = 0; i < bodies.length; i++) {
      final b = bodies[i];
      if (b.type == PieceType.striker || b.isPocketed) continue;
      PieceComponent.renderPiece(cacheCanvas, b);
    }

    _cachedStationaryPicture = recorder.endRecording();
    _isStationaryDirty = false;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final isMoving = isMovingProvider?.call() ?? false;

    // Fast path: all pieces at rest → draw from pre-baked picture
    if (!isMoving) {
      if (_cachedStationaryPicture == null || _isStationaryDirty) {
        _rebuildStationaryCache();
      }
      if (_cachedStationaryPicture != null) {
        canvas.drawPicture(_cachedStationaryPicture!);
        return;
      }
    }

    // Active path: pieces in motion → render dynamically
    _isStationaryDirty = true;
    for (int i = 0; i < bodies.length; i++) {
      final b = bodies[i];
      if (b.type == PieceType.striker || b.isPocketed) continue;
      PieceComponent.renderPiece(canvas, b);
    }
  }

  @override
  void onRemove() {
    _cachedStationaryPicture?.dispose();
    _cachedStationaryPicture = null;
    super.onRemove();
  }
}
