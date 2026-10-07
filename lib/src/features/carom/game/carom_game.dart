import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../services/carom_audio_service.dart';
import '../domain/models/game_models.dart';
import '../data/carom_models.dart';
import '../domain/physics/carom_physics.dart';
import '../domain/physics/trajectory_predictor.dart';
import 'components/board_rendering.dart';
import 'components/particle_effect.dart';
import 'components/piece_component.dart';
import 'components/striker_component.dart';

class CaromGame extends FlameGame {
  final Function(ShotResult) onTurnCompleted;

  final CaromPhysicsEngine physicsEngine = CaromPhysicsEngine();
  final BoardRenderingComponent boardComponent = BoardRenderingComponent();
  final ParticleManagerComponent particleManager = ParticleManagerComponent();
  late final PiecesLayerComponent piecesLayer;
  late StrikerComponent strikerComponent;
  late PhysicsBody strikerBody;
  bool _matchInitialized = false;

  final List<PieceComponent> pieceComponents = [];
  final List<PhysicsBody> allBodies = [];

  TurnPhase currentPhase = TurnPhase.positioningStriker;
  PlayerId activePlayer = PlayerId.player1;
  bool is4PlayerMode = false;

  // Turn tracking
  final List<PieceType> _turnPocketedPieces = [];
  bool _strikerPocketedThisTurn = false;
  bool _queenPocketedThisTurn = false;

  CaromGame({required this.onTurnCompleted}) {
    piecesLayer = PiecesLayerComponent(
      bodies: allBodies,
      isMovingProvider: () => currentPhase == TurnPhase.piecesMoving,
    );
    initializeMatch();
  }

  @override
  Color backgroundColor() => const Color(0xFF380811);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    if (!boardComponent.isMounted) add(boardComponent);
    if (!piecesLayer.isMounted) add(piecesLayer);
    if (!strikerComponent.isMounted) add(strikerComponent);
    if (!particleManager.isMounted) add(particleManager);
  }

  void initializeMatch() {
    if (_matchInitialized) {
      if (strikerComponent.isMounted) {
        strikerComponent.removeFromParent();
      }
    }
    pieceComponents.clear();
    allBodies.clear();
    _turnPocketedPieces.clear();
    _strikerPocketedThisTurn = false;
    _queenPocketedThisTurn = false;

    // Center of 740x740 board is (370, 370)
    final center = Vector2(
      BoardConfig.boardSize / 2,
      BoardConfig.boardSize / 2,
    );
    int nextId = 1;

    // 1. Red Queen at exact center
    final queenBody = PhysicsBody(
      id: nextId++,
      type: PieceType.queen,
      position: center.clone(),
      radius: BoardConfig.pieceRadius,
      mass: 1.0,
    );
    allBodies.add(queenBody);
    final queenComp = PieceComponent(body: queenBody);
    pieceComponents.add(queenComp);

    // 2. Inner Ring of 6 pieces around Queen (alternating Black and White)
    // Distance between centers in close packing is 2.01 * pieceRadius
    final rInner = BoardConfig.pieceRadius * 2.02;
    for (int i = 0; i < 6; i++) {
      // Start from top (-pi / 2) as in reference image
      final angle = -pi / 2 + i * (pi / 3);
      final pos = center + Vector2(cos(angle) * rInner, sin(angle) * rInner);
      final type = (i % 2 == 0) ? PieceType.black : PieceType.white;

      final body = PhysicsBody(
        id: nextId++,
        type: type,
        position: pos,
        radius: BoardConfig.pieceRadius,
        mass: 1.0,
      );
      allBodies.add(body);
      final comp = PieceComponent(body: body);
      pieceComponents.add(comp);
    }

    // 3. Outer Ring of 12 pieces in authentic Hexagonal Close Packing (alternating White and Black)
    // 6 corner pieces at distance 4.02 * R, 6 edge-midpoint pieces at distance 2 * sqrt(3) * 1.01 * R
    final rCorner = BoardConfig.pieceRadius * 4.03;
    final rMidpoint = BoardConfig.pieceRadius * 3.49;

    for (int i = 0; i < 12; i++) {
      final angle = -pi / 2 + i * (pi / 6);
      final dist = (i % 2 == 0) ? rCorner : rMidpoint;
      final pos = center + Vector2(cos(angle) * dist, sin(angle) * dist);
      // Alternates White and Black around the 12 perimeter slots
      final type = (i % 2 == 0) ? PieceType.white : PieceType.black;

      final body = PhysicsBody(
        id: nextId++,
        type: type,
        position: pos,
        radius: BoardConfig.pieceRadius,
        mass: 1.0,
      );
      allBodies.add(body);
      final comp = PieceComponent(body: body);
      pieceComponents.add(comp);
    }

    // 4. Create Striker
    final initialStrikerY = (activePlayer == PlayerId.player1)
        ? BoardConfig.baselineYPlayer1
        : BoardConfig.baselineYPlayer2;

    strikerBody = PhysicsBody(
      id: 999,
      type: PieceType.striker,
      position: Vector2(BoardConfig.boardSize / 2, initialStrikerY),
      radius: BoardConfig.strikerRadius,
      mass: 2.8,
    );
    allBodies.add(strikerBody);

    strikerComponent = StrikerComponent(body: strikerBody);
    if (isMounted) add(strikerComponent);

    _matchInitialized = true;
    piecesLayer.markDirty();
    resetStrikerForTurn(activePlayer);
  }

  void resetStrikerForTurn(PlayerId player) {
    activePlayer = player;
    _turnPocketedPieces.clear();
    _strikerPocketedThisTurn = false;
    _queenPocketedThisTurn = false;

    final baseline = BoardConfig.getBaselineConfig(
      player,
      is4PlayerMode: is4PlayerMode,
    );
    final centerCoord = (baseline.minSlider + baseline.maxSlider) / 2;
    // Automatically find clear position if center of baseline is occupied by a piece
    final safeSlider = findNearestValidSlider(centerCoord, baseline);

    if (baseline.isVertical) {
      strikerBody.position = Vector2(baseline.fixedCoordinate, safeSlider);
    } else {
      strikerBody.position = Vector2(safeSlider, baseline.fixedCoordinate);
    }

    strikerBody.velocity.setZero();
    strikerBody.scale = 1.0;
    strikerBody.opacity = 1.0;
    strikerBody.isPocketed = false;
    strikerBody.isSinking = false;
    strikerBody.sinkProgress = 0.0;
    strikerBody.targetedPocket = null;

    strikerComponent.isPositioning = true;
    strikerComponent.isAiming = false;
    strikerComponent.aimVector = null;
    strikerComponent.strikePower = 0.0;
    strikerComponent.trajectory = null;
    strikerComponent.isValidPosition = validateStrikerPosition(safeSlider);

    currentPhase = TurnPhase.positioningStriker;
  }

  double findNearestValidSlider(
    double preferredSlider,
    PlayerBaselineConfig baseline,
  ) {
    if (validateStrikerPosition(preferredSlider)) {
      return preferredSlider;
    }

    const step = 4.0;
    final maxDist = baseline.maxSlider - baseline.minSlider;

    for (double offset = step; offset <= maxDist; offset += step) {
      final right = preferredSlider + offset;
      if (right <= baseline.maxSlider && validateStrikerPosition(right)) {
        return right;
      }
      final left = preferredSlider - offset;
      if (left >= baseline.minSlider && validateStrikerPosition(left)) {
        return left;
      }
    }

    for (double s = baseline.minSlider; s <= baseline.maxSlider; s += 8.0) {
      if (validateStrikerPosition(s)) {
        return s;
      }
    }

    return preferredSlider.clamp(baseline.minSlider, baseline.maxSlider);
  }

  bool validateStrikerPosition(double sliderVal) {
    final baseline = BoardConfig.getBaselineConfig(
      activePlayer,
      is4PlayerMode: is4PlayerMode,
    );
    if (sliderVal < baseline.minSlider || sliderVal > baseline.maxSlider) {
      return false;
    }

    final testPos = baseline.isVertical
        ? Vector2(baseline.fixedCoordinate, sliderVal)
        : Vector2(sliderVal, baseline.fixedCoordinate);

    const minClearance = BoardConfig.strikerRadius + BoardConfig.pieceRadius;

    for (final b in allBodies) {
      if (b == strikerBody || b.isPocketed) continue;
      if (testPos.distanceTo(b.position) < minClearance) {
        return false; // Overlaps an active piece
      }
    }
    return true;
  }

  void updateStrikerPlacement(double sliderVal) {
    if (currentPhase != TurnPhase.positioningStriker &&
        currentPhase != TurnPhase.aiming) {
      return;
    }

    final baseline = BoardConfig.getBaselineConfig(
      activePlayer,
      is4PlayerMode: is4PlayerMode,
    );
    final clamped = sliderVal.clamp(baseline.minSlider, baseline.maxSlider);

    if (baseline.isVertical) {
      strikerBody.position.x = baseline.fixedCoordinate;
      strikerBody.position.y = clamped;
    } else {
      strikerBody.position.x = clamped;
      strikerBody.position.y = baseline.fixedCoordinate;
    }

    strikerComponent.isValidPosition = validateStrikerPosition(clamped);

    if (strikerComponent.isAiming && strikerComponent.aimVector != null) {
      updateAim(strikerComponent.aimVector!, strikerComponent.strikePower);
    }
  }

  void startAiming() {
    if (!strikerComponent.isValidPosition) {
      final baseline = BoardConfig.getBaselineConfig(
        activePlayer,
        is4PlayerMode: is4PlayerMode,
      );
      final currentSlider = baseline.isVertical
          ? strikerBody.position.y
          : strikerBody.position.x;
      final safeSlider = findNearestValidSlider(currentSlider, baseline);
      updateStrikerPlacement(safeSlider);
    }
    if (!strikerComponent.isValidPosition) return;
    currentPhase = TurnPhase.aiming;
    strikerComponent.isPositioning = false;
    strikerComponent.isAiming = true;
  }

  void updateAim(Vector2 direction, double power) {
    if (currentPhase != TurnPhase.aiming) return;

    strikerComponent.aimVector = direction.normalized();
    strikerComponent.strikePower = power.clamp(0.0, 1.0);

    strikerComponent.trajectory = TrajectoryPredictor.calculate(
      origin: strikerBody.position,
      aimDirection: strikerComponent.aimVector!,
      strikerRadius: strikerBody.radius,
      pieces: allBodies.where((b) => b != strikerBody).toList(),
    );
  }

  void cancelAiming() {
    if (currentPhase != TurnPhase.aiming) return;
    currentPhase = TurnPhase.positioningStriker;
    strikerComponent.isPositioning = true;
    strikerComponent.isAiming = false;
    strikerComponent.trajectory = null;
  }

  void fireStriker([Vector2? explicitDir, double? explicitPower]) {
    if (explicitDir != null && explicitPower != null) {
      strikerComponent.aimVector = explicitDir.normalized();
      strikerComponent.strikePower = explicitPower.clamp(0.0, 1.0);
    }
    if (currentPhase != TurnPhase.aiming ||
        strikerComponent.aimVector == null) {
      return;
    }
    if (strikerComponent.strikePower <= 0.05) {
      cancelAiming();
      return;
    }

    final dir = strikerComponent.aimVector!;
    final power = strikerComponent.strikePower;

    // Realistic impulse speed from 500 px/s to 2400 px/s
    const minSpeed = 500.0;
    const maxSpeed = 2400.0;
    final impulseSpeed = minSpeed + (maxSpeed - minSpeed) * power;

    strikerBody.velocity = dir * impulseSpeed;

    CaromAudio.instance.playStrike(power: power);

    strikerComponent.isAiming = false;
    strikerComponent.isPositioning = false;
    strikerComponent.trajectory = null;
    currentPhase = TurnPhase.piecesMoving;
  }

  /// Plays a shot another player fired: striker at [position], aimed at
  /// [angle] (radians) with [power] 0..1. Call [resetStrikerForTurn] for the
  /// shooter first so the baseline and flags are right.
  void fireRemote({
    required Vector2 position,
    required double angle,
    required double power,
  }) {
    strikerBody.position = position.clone();
    strikerBody.velocity.setZero();
    currentPhase = TurnPhase.aiming;
    strikerComponent.isValidPosition = true;
    fireStriker(Vector2(cos(angle), sin(angle)), power);
  }

  /// True while pieces are rolling (a shot is being simulated).
  bool get isSimulating => currentPhase == TurnPhase.piecesMoving;

  void returnPieceToCenter(PieceType type) {
    final center = Vector2(
      BoardConfig.boardSize / 2,
      BoardConfig.boardSize / 2,
    );

    // Find first available spot around center
    Vector2 targetPos = center.clone();
    double offset = 0;
    while (true) {
      bool spotFree = true;
      for (final b in allBodies) {
        if (!b.isPocketed &&
            targetPos.distanceTo(b.position) < BoardConfig.pieceRadius * 2.0) {
          spotFree = false;
          break;
        }
      }
      if (spotFree) break;
      offset += 15.0;
      targetPos = center + Vector2(0, offset);
    }

    final piece = allBodies.firstWhere(
      (b) => b.type == type && b.isPocketed,
      orElse: () => allBodies.first,
    );

    piece.position = targetPos;
    piece.velocity.setZero();
    piece.scale = 1.0;
    piece.opacity = 1.0;
    piece.isPocketed = false;
    piece.isSinking = false;
    piece.sinkProgress = 0.0;
    piece.targetedPocket = null;
    piecesLayer.markDirty();
  }

  /// Synchronizes piece positions and pocketed statuses from authoritative network packet
  void syncPiecePositions(List<CaromPieceState> pieceStates) {
    for (final state in pieceStates) {
      for (final body in allBodies) {
        if (body.id == state.id) {
          body.position.setValues(state.x, state.y);
          body.velocity.setZero();
          body.angularVelocity = 0.0;
          body.isPocketed = state.isPocketed;
          body.isSinking = false;
          body.sinkProgress = 0.0;
          body.scale = 1.0;
          body.opacity = 1.0;
          body.targetedPocket = null;
          break;
        }
      }
    }
    strikerBody.velocity.setZero();
    strikerBody.angularVelocity = 0.0;
    strikerBody.isPocketed = false;
    currentPhase = TurnPhase.evaluatingTurn;
    piecesLayer.markDirty();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (currentPhase != TurnPhase.piecesMoving) return;

    physicsEngine.update(allBodies, dt);

    // Visual feedback for collisions
    for (final col in physicsEngine.pendingCollisions) {
      particleManager.spawnCollisionSparks(col.position, col.intensity);
    }

    // Process pocketed pieces
    for (final p in physicsEngine.newlyPocketed) {
      particleManager.spawnPocketPuff(p.position);

      if (p.type == PieceType.striker) {
        _strikerPocketedThisTurn = true;
        CaromAudio.instance.playFoul();
      } else if (p.type == PieceType.queen) {
        _queenPocketedThisTurn = true;
        _turnPocketedPieces.add(p.type);
        CaromAudio.instance.playCheer();
      } else {
        _turnPocketedPieces.add(p.type);
      }
    }

    // Check if motion has stopped completely
    if (physicsEngine.areAllStationary(allBodies)) {
      piecesLayer.markDirty();
      currentPhase = TurnPhase.evaluatingTurn;

      final result = ShotResult(
        pocketedPieces: List.from(_turnPocketedPieces),
        strikerPocketed: _strikerPocketedThisTurn,
        queenPocketed: _queenPocketedThisTurn,
      );

      onTurnCompleted(result);
    }
  }

  void setTheme(BoardTheme theme) {
    switch (theme) {
      case BoardTheme.tournamentRed:
        boardComponent.updateTheme(ThemeStyling.tournamentRed);
        break;
      case BoardTheme.classicBirch:
        boardComponent.updateTheme(ThemeStyling.classicBirch);
        break;
      case BoardTheme.darkMahogany:
        boardComponent.updateTheme(ThemeStyling.darkMahogany);
        break;
      case BoardTheme.tournamentIvory:
        boardComponent.updateTheme(ThemeStyling.tournamentIvory);
        break;
    }
  }
}
