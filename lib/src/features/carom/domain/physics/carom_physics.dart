import 'dart:math';

import 'package:flame/game.dart';

import '../../services/carom_audio_service.dart';
import '../models/game_models.dart';

class PocketLocation {
  final Vector2 center;
  final double radius;
  final double captureRadius;

  const PocketLocation({
    required this.center,
    this.radius = BoardConfig.pocketFunnelRadius,
    this.captureRadius = BoardConfig.pocketHoleRadius,
  });
}

class PhysicsBody {
  final int id;
  final PieceType type;
  Vector2 position;
  Vector2 velocity;
  double radius;
  double mass;
  double scale;
  double opacity;
  double angle;
  double angularVelocity;
  bool isPocketed;
  bool isSinking;
  double sinkProgress;
  PocketLocation? targetedPocket;

  PhysicsBody({
    required this.id,
    required this.type,
    required this.position,
    Vector2? velocity,
    required this.radius,
    required this.mass,
    this.scale = 1.0,
    this.opacity = 1.0,
    this.angle = 0.0,
    this.angularVelocity = 0.0,
    this.isPocketed = false,
    this.isSinking = false,
    this.sinkProgress = 0.0,
    this.targetedPocket,
  }) : velocity = velocity ?? Vector2.zero();

  double get momentOfInertia => 0.5 * mass * radius * radius;

  bool get isStationary =>
      velocity.length2 < 1.0 && angularVelocity.abs() < 0.1 && !isSinking;
}

class CollisionEvent {
  final Vector2 position;
  final double intensity;

  CollisionEvent({required this.position, required this.intensity});
}

class CaromPhysicsEngine {
  static const double fieldMin = 34.0;
  static const double fieldMax = 706.0;
  static const double cushionRestitution = 0.88;
  static const double pieceRestitution = 0.94;

  // Board surface friction parameters (realistic boric powder glide)
  double dynamicFriction = 0.988; // Viscous drag per frame
  double linearDecel = 65.0; // Coulomb sliding friction (px/s^2)

  final List<PocketLocation> pockets = [
    PocketLocation(center: Vector2(50.0, 50.0)),
    PocketLocation(center: Vector2(690.0, 50.0)),
    PocketLocation(center: Vector2(50.0, 690.0)),
    PocketLocation(center: Vector2(690.0, 690.0)),
  ];

  // 8 Rounded Pocket Jaws at the cushion termination points
  static final List<Vector2> _pocketJaws = [
    Vector2(76.0, 43.0),
    Vector2(43.0, 76.0),
    Vector2(664.0, 43.0),
    Vector2(697.0, 76.0),
    Vector2(76.0, 697.0),
    Vector2(43.0, 664.0),
    Vector2(664.0, 697.0),
    Vector2(697.0, 664.0),
  ];

  final List<CollisionEvent> pendingCollisions = [];
  final List<PhysicsBody> newlyPocketed = [];

  void setFrictionMode(String mode) {
    if (mode == 'slick') {
      dynamicFriction = 0.993;
      linearDecel = 45.0;
    } else if (mode == 'rough') {
      dynamicFriction = 0.982;
      linearDecel = 90.0;
    } else {
      dynamicFriction = 0.988;
      linearDecel = 65.0;
    }
  }

  double _frameMaxHitIntensity = 0.0;
  double _frameMaxCushionIntensity = 0.0;
  int _lastHitSoundTime = 0;
  int _lastCushionSoundTime = 0;

  void update(List<PhysicsBody> bodies, double dt) {
    if (dt <= 0) return;
    pendingCollisions.clear();
    newlyPocketed.clear();
    _frameMaxHitIntensity = 0.0;
    _frameMaxCushionIntensity = 0.0;

    // Fast check: if all active pieces are at rest, skip simulation entirely
    bool anyActive = false;
    for (int i = 0; i < bodies.length; i++) {
      final b = bodies[i];
      if (b.isPocketed) continue;
      if (b.isSinking ||
          b.velocity.x != 0 ||
          b.velocity.y != 0 ||
          b.angularVelocity != 0) {
        anyActive = true;
        break;
      }
      // Check if placed in pocket capture zone (e.g. initial test setup)
      for (final p in pockets) {
        if (b.position.distanceToSquared(p.center) <
            p.captureRadius * p.captureRadius) {
          anyActive = true;
          break;
        }
      }
      if (anyActive) break;
    }
    if (!anyActive) return;

    // Clamp dt to prevent frame lag explosion
    final effectiveDt = dt.clamp(0.001, 0.033);
    const int substeps = 5;
    final subDt = effectiveDt / substeps;

    for (int step = 0; step < substeps; step++) {
      _substep(bodies, subDt);
    }

    // Play at most ONE throttled hit and cushion sound per frame
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_frameMaxHitIntensity > 0.08 && now - _lastHitSoundTime > 45) {
      CaromAudio.instance.playHit(intensity: _frameMaxHitIntensity);
      _lastHitSoundTime = now;
    }
    if (_frameMaxCushionIntensity > 0.08 && now - _lastCushionSoundTime > 60) {
      CaromAudio.instance.playCushion(intensity: _frameMaxCushionIntensity);
      _lastCushionSoundTime = now;
    }
  }

  void _substep(List<PhysicsBody> bodies, double dt) {
    // 1. Position update, angular spin, and board friction
    for (final body in bodies) {
      if (body.isPocketed) continue;

      if (body.isSinking) {
        _updateSinking(body, dt);
        continue;
      }

      final isMoving =
          body.velocity.x != 0 ||
          body.velocity.y != 0 ||
          body.angularVelocity != 0;

      if (isMoving) {
        // Linear friction (Coulomb sliding friction + viscous powder drag)
        final speed = body.velocity.length;
        if (speed > 0) {
          final decel = linearDecel * dt;
          final newSpeed =
              max(0.0, speed - decel) * pow(dynamicFriction, dt * 60.0);
          if (newSpeed < 1.8) {
            body.velocity.setZero();
          } else {
            body.velocity.scale(newSpeed / speed);
          }
        }

        // Angular rotational spin decay (boric powder friction against disc face)
        if (body.angularVelocity.abs() > 0) {
          body.angularVelocity *= pow(0.962, dt * 60.0);
          if (body.angularVelocity.abs() < 0.04) {
            body.angularVelocity = 0.0;
          }
          body.angle += body.angularVelocity * dt;
        }

        body.position.addScaled(body.velocity, dt);

        // Cushion boundaries & rounded jaw deflections
        _handleCushionCollisions(body);
      }

      // Check pocket capture & gravitational funnel
      _checkPockets(body, dt);
    }

    // 2. Inter-piece collisions with rotational torque & tangential friction
    for (int i = 0; i < bodies.length; i++) {
      final a = bodies[i];
      if (a.isPocketed || a.isSinking) continue;

      for (int j = i + 1; j < bodies.length; j++) {
        final b = bodies[j];
        if (b.isPocketed || b.isSinking) continue;

        // Fast rejection: if both are at rest, they cannot collide
        if (a.velocity.x == 0 &&
            a.velocity.y == 0 &&
            b.velocity.x == 0 &&
            b.velocity.y == 0) {
          continue;
        }

        _resolvePieceCollision(a, b);
      }
    }
  }

  void _checkPockets(PhysicsBody body, double dt) {
    for (final pocket in pockets) {
      final distSq = body.position.distanceToSquared(pocket.center);
      final pocketRadSq = pocket.radius * pocket.radius;

      // Fast rejection: outside pocket radius
      if (distSq >= pocketRadSq) continue;

      final dist = sqrt(distSq);

      // 1. Outer Sloped Pocket Lip Funnel: natural subtle inward gravitational pull
      if (dist < pocket.radius && dist >= pocket.captureRadius) {
        final toCenter = (pocket.center - body.position).normalized();
        final pullStrength =
            ((pocket.radius - dist) / (pocket.radius - pocket.captureRadius))
                .clamp(0.0, 1.0);
        // Realistic subtle downward funnel acceleration towards pocket center (tighter, competitive)
        body.velocity.addScaled(toCenter, 200.0 * pullStrength * dt);

        // Subtle tangential dampening so shots require clean aiming precision
        final dotVal = body.velocity.dot(toCenter);
        final tangentVel = body.velocity - toCenter * dotVal;
        body.velocity -= tangentVel * (0.07 * pullStrength);
      }

      // 2. Deep Pocket Capture Zone
      if (dist < pocket.captureRadius) {
        // High-speed misaligned edge rattle: if moving fast right at the outer rim, rattle out
        final speed = body.velocity.length;
        if (speed > 920.0 && dist > pocket.captureRadius * 0.78) {
          final normal = (body.position - pocket.center).normalized();
          body.velocity += normal * 130.0;
        } else {
          body.isSinking = true;
          body.targetedPocket = pocket;
          CaromAudio.instance.playPocket();
          break;
        }
      }
    }
  }

  void _updateSinking(PhysicsBody body, double dt) {
    final pocket = body.targetedPocket;
    if (pocket == null) {
      body.isPocketed = true;
      return;
    }

    body.sinkProgress += dt * 4.2;

    // Pull toward pocket center
    final toCenter = pocket.center - body.position;
    body.position.addScaled(toCenter, dt * 9.0);
    body.velocity.scale(0.82);

    // Rotational spiral spin into net
    body.angularVelocity += 14.0 * dt;
    body.angle += body.angularVelocity * dt;

    body.scale = max(0.15, 1.0 - body.sinkProgress * 0.75);
    body.opacity = max(0.0, 1.0 - body.sinkProgress * 0.90);

    if (body.sinkProgress >= 1.0 ||
        body.position.distanceTo(pocket.center) < 7.0) {
      body.isPocketed = true;
      body.isSinking = false;
      body.velocity.setZero();
      body.angularVelocity = 0.0;
      newlyPocketed.add(body);
    }
  }

  void _handleCushionCollisions(PhysicsBody body) {
    if (body.isSinking) return;
    if (body.velocity.x == 0 && body.velocity.y == 0) return;
    const cornerCutout = 76.0;

    // 1. Flat Cushion Faces with Angular Spin
    // Left cushion
    if (body.position.x - body.radius < fieldMin) {
      if (body.position.y > cornerCutout &&
          body.position.y < (BoardConfig.boardSize - cornerCutout)) {
        body.position.x = fieldMin + body.radius;
        if (body.velocity.x < 0) {
          final intensity = (body.velocity.x.abs() / 900.0).clamp(0.1, 1.0);
          _frameMaxCushionIntensity = max(_frameMaxCushionIntensity, intensity);
          body.velocity.x = -body.velocity.x * cushionRestitution;
          body.velocity.y *= 0.98;
          body.angularVelocity += (body.velocity.y / body.radius) * 0.28;
        }
      }
    }

    // Right cushion
    if (body.position.x + body.radius > fieldMax) {
      if (body.position.y > cornerCutout &&
          body.position.y < (BoardConfig.boardSize - cornerCutout)) {
        body.position.x = fieldMax - body.radius;
        if (body.velocity.x > 0) {
          final intensity = (body.velocity.x.abs() / 900.0).clamp(0.1, 1.0);
          _frameMaxCushionIntensity = max(_frameMaxCushionIntensity, intensity);
          body.velocity.x = -body.velocity.x * cushionRestitution;
          body.velocity.y *= 0.98;
          body.angularVelocity -= (body.velocity.y / body.radius) * 0.28;
        }
      }
    }

    // Top cushion
    if (body.position.y - body.radius < fieldMin) {
      if (body.position.x > cornerCutout &&
          body.position.x < (BoardConfig.boardSize - cornerCutout)) {
        body.position.y = fieldMin + body.radius;
        if (body.velocity.y < 0) {
          final intensity = (body.velocity.y.abs() / 900.0).clamp(0.1, 1.0);
          _frameMaxCushionIntensity = max(_frameMaxCushionIntensity, intensity);
          body.velocity.y = -body.velocity.y * cushionRestitution;
          body.velocity.x *= 0.98;
          body.angularVelocity -= (body.velocity.x / body.radius) * 0.28;
        }
      }
    }

    // Bottom cushion
    if (body.position.y + body.radius > fieldMax) {
      if (body.position.x > cornerCutout &&
          body.position.x < (BoardConfig.boardSize - cornerCutout)) {
        body.position.y = fieldMax - body.radius;
        if (body.velocity.y > 0) {
          final intensity = (body.velocity.y.abs() / 900.0).clamp(0.1, 1.0);
          _frameMaxCushionIntensity = max(_frameMaxCushionIntensity, intensity);
          body.velocity.y = -body.velocity.y * cushionRestitution;
          body.velocity.x *= 0.98;
          body.angularVelocity += (body.velocity.x / body.radius) * 0.28;
        }
      }
    }

    // 2. Rounded Pocket Jaws (Corner Jaw Deflection with Tournament Bevel Funneling)
    const jawRadius = 5.0;
    for (int i = 0; i < _pocketJaws.length; i++) {
      final jaw = _pocketJaws[i];
      final toBody = body.position - jaw;
      final dist = toBody.length;
      final minDist = body.radius + jawRadius;

      if (dist < minDist && dist > 0.0001) {
        final pocket = pockets[i ~/ 2];
        final toPocket = (pocket.center - body.position).normalized();
        final movingTowardsPocket = body.velocity.dot(toPocket) > 0;

        final normal = toBody / dist;
        final velAlongNormal = body.velocity.dot(normal);

        if (velAlongNormal < 0) {
          if (movingTowardsPocket) {
            // Cut shots & side shots: pocket jaw bevel gently guides the coin into the net without over-assisting
            body.velocity -= normal * (velAlongNormal * 0.65);
            body.velocity.addScaled(toPocket, 35.0);
            body.position = jaw + normal * (minDist + 0.05);
          } else {
            // Soft pocket jaw bounce (leather/soft wood rim absorbs rebound)
            body.velocity -=
                normal * ((1 + cushionRestitution * 0.35) * velAlongNormal);
            body.position = jaw + normal * (minDist + 0.1);

            final intensity = (-velAlongNormal / 800.0).clamp(0.1, 1.0);
            _frameMaxCushionIntensity = max(
              _frameMaxCushionIntensity,
              intensity,
            );
          }
        }
      }
    }
  }

  void _resolvePieceCollision(PhysicsBody a, PhysicsBody b) {
    final dx = b.position.x - a.position.x;
    final dy = b.position.y - a.position.y;
    final minDist = a.radius + b.radius;

    // Fast bounding-box rejection
    if (dx.abs() >= minDist || dy.abs() >= minDist) return;

    final distSq = dx * dx + dy * dy;
    if (distSq >= minDist * minDist || distSq <= 0.0001) return;

    final relVel = b.velocity - a.velocity;

    // Continuous Collision Detection (CCD):
    // Backtrack along relative velocity to evaluate the exact surface contact normal at the true moment of impact.
    // This perfectly matches the trajectory ray prediction and eliminates angular drift caused by discrete time-step penetration.
    Vector2 normal;
    final relSpeed = relVel.length;
    if (relSpeed > 5.0) {
      final v = -relVel / relSpeed; // Direction of a approaching b
      final d = a.position - b.position;
      final dotVal = d.dot(v);
      final disc = dotVal * dotVal + minDist * minDist - distSq;
      final s = dotVal + sqrt(max(0.0, disc));
      final contactA = a.position - v * s;
      normal = (b.position - contactA).normalized();
    } else {
      final dist = sqrt(distSq);
      normal = Vector2(dx / dist, dy / dist);
    }

    final tangent = Vector2(-normal.y, normal.x);
    final velAlongNormal = relVel.dot(normal);

    // Objects are moving apart
    if (velAlongNormal > 0) return;

    // 1. Normal restitution impulse
    final impulseNormal =
        -(1 + pieceRestitution) * velAlongNormal / (1 / a.mass + 1 / b.mass);
    final impulseVecNormal = normal * impulseNormal;

    // 2. Tangential friction & spin transfer
    final vRelTangent =
        relVel.dot(tangent) -
        (a.angularVelocity * a.radius + b.angularVelocity * b.radius);
    const frictionCoeff =
        0.16; // Authentic polished lacquered wood-on-wood friction
    final maxFriction = frictionCoeff * impulseNormal;

    final effectiveTangentialMass =
        1.0 /
        ((1.0 / a.mass) +
            (1.0 / b.mass) +
            (a.radius * a.radius / a.momentOfInertia) +
            (b.radius * b.radius / b.momentOfInertia));
    final rawFrictionImpulse = -vRelTangent * effectiveTangentialMass;
    final impulseTangent = rawFrictionImpulse.clamp(-maxFriction, maxFriction);
    final impulseVecTangent = tangent * impulseTangent;

    // Striker (a) deflects with normal rebound and tangential drag
    final totalImpulseA = impulseVecNormal - impulseVecTangent;
    a.velocity.sub(totalImpulseA / a.mass);

    // Target piece (b) launches purely along the collision normal (line of centers),
    // matching the trajectory aim prediction with 100% precision
    b.velocity.add(impulseVecNormal / b.mass);

    // Apply torque / rotational spin to both bodies
    a.angularVelocity -= (impulseTangent * a.radius) / a.momentOfInertia;
    b.angularVelocity -= (impulseTangent * b.radius) / b.momentOfInertia;

    // Positional separation with a 0.25px safety buffer to eliminate parasitic multi-substep double hits
    final currentDist = sqrt(distSq);
    final overlap = (minDist - currentDist) + 0.25;
    final totalMass = a.mass + b.mass;
    a.position.sub(normal * (overlap * (b.mass / totalMass)));
    b.position.add(normal * (overlap * (a.mass / totalMass)));

    // Collision sound & particle fx (throttled)
    final impactIntensity = (-velAlongNormal / 800.0).clamp(0.1, 1.0);
    _frameMaxHitIntensity = max(_frameMaxHitIntensity, impactIntensity);

    if (pendingCollisions.length < 12) {
      final midPos = (a.position + b.position) * 0.5;
      pendingCollisions.add(
        CollisionEvent(position: midPos, intensity: impactIntensity),
      );
    }
  }

  bool areAllStationary(List<PhysicsBody> bodies) {
    for (final b in bodies) {
      if (!b.isStationary && !b.isPocketed) return false;
    }
    return true;
  }
}
