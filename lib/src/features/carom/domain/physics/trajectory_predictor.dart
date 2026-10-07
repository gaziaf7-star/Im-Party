import 'dart:math';

import 'package:flame/game.dart';

import 'carom_physics.dart';

class TrajectoryHit {
  final Vector2 ghostStrikerPos;
  final PhysicsBody targetPiece;
  final Vector2 pieceDirection;
  final Vector2 strikerDeflectedDirection;

  TrajectoryHit({
    required this.ghostStrikerPos,
    required this.targetPiece,
    required this.pieceDirection,
    required this.strikerDeflectedDirection,
  });
}

class TrajectoryPath {
  final List<Vector2> points;
  final TrajectoryHit? hit;

  TrajectoryPath({required this.points, this.hit});
}

class TrajectoryPredictor {
  static const double fieldMin = CaromPhysicsEngine.fieldMin;
  static const double fieldMax = CaromPhysicsEngine.fieldMax;
  static const double maxPredictDistance = 880.0;

  static TrajectoryPath calculate({
    required Vector2 origin,
    required Vector2 aimDirection,
    required double strikerRadius,
    required List<PhysicsBody> pieces,
  }) {
    if (aimDirection.length2 == 0) {
      return TrajectoryPath(points: [origin.clone()]);
    }

    final points = <Vector2>[origin.clone()];
    var currentOrigin = origin.clone();
    var currentDir = aimDirection.normalized();
    double remainingDistance = maxPredictDistance;

    TrajectoryHit? detectedHit;

    // Raycast loop (up to 1 cushion bounce)
    for (int bounce = 0; bounce <= 1; bounce++) {
      double minPieceDist = double.infinity;
      PhysicsBody? closestPiece;
      Vector2? ghostPos;

      // 1. Raycast against all active pieces
      for (final piece in pieces) {
        if (piece.isPocketed || piece.isSinking) continue;

        final toPiece = piece.position - currentOrigin;
        final proj = toPiece.dot(currentDir);

        if (proj <= 0) continue; // Behind ray
        if (proj > remainingDistance) continue; // Out of range

        final perpDist2 = toPiece.length2 - (proj * proj);
        final combinedRadius = strikerRadius + piece.radius;

        if (perpDist2 < combinedRadius * combinedRadius) {
          // Intersection with bounding circle
          final halfChord = sqrt(
            max(0.0, combinedRadius * combinedRadius - perpDist2),
          );
          final hitDist = proj - halfChord;

          if (hitDist > 0 && hitDist < minPieceDist) {
            minPieceDist = hitDist;
            closestPiece = piece;
            ghostPos = currentOrigin + (currentDir * hitDist);
          }
        }
      }

      // 2. Raycast against cushions
      double cushionDist = double.infinity;
      Vector2? cushionHit;
      Vector2? cushionNormal;

      // Vertical cushions
      if (currentDir.x > 0) {
        final d = (fieldMax - strikerRadius - currentOrigin.x) / currentDir.x;
        if (d > 0 && d < cushionDist) {
          cushionDist = d;
          cushionHit = currentOrigin + currentDir * d;
          cushionNormal = Vector2(-1, 0);
        }
      } else if (currentDir.x < 0) {
        final d = (fieldMin + strikerRadius - currentOrigin.x) / currentDir.x;
        if (d > 0 && d < cushionDist) {
          cushionDist = d;
          cushionHit = currentOrigin + currentDir * d;
          cushionNormal = Vector2(1, 0);
        }
      }

      // Horizontal cushions
      if (currentDir.y > 0) {
        final d = (fieldMax - strikerRadius - currentOrigin.y) / currentDir.y;
        if (d > 0 && d < cushionDist) {
          cushionDist = d;
          cushionHit = currentOrigin + currentDir * d;
          cushionNormal = Vector2(0, -1);
        }
      } else if (currentDir.y < 0) {
        final d = (fieldMin + strikerRadius - currentOrigin.y) / currentDir.y;
        if (d > 0 && d < cushionDist) {
          cushionDist = d;
          cushionHit = currentOrigin + currentDir * d;
          cushionNormal = Vector2(0, 1);
        }
      }

      // 3. Resolve which comes first: piece collision or cushion bounce
      if (closestPiece != null &&
          minPieceDist < cushionDist &&
          minPieceDist <= remainingDistance) {
        final contactPos = ghostPos!;
        points.add(contactPos);

        // Piece impact calculation
        final impactNormal = (closestPiece.position - contactPos).normalized();
        final velAlongNormal = currentDir.dot(impactNormal);
        final pieceDir = impactNormal * velAlongNormal;
        final strikerDeflect = currentDir - impactNormal * velAlongNormal;

        detectedHit = TrajectoryHit(
          ghostStrikerPos: contactPos,
          targetPiece: closestPiece,
          pieceDirection: pieceDir.length2 > 0
              ? pieceDir.normalized()
              : impactNormal,
          strikerDeflectedDirection: strikerDeflect.length2 > 0
              ? strikerDeflect.normalized()
              : currentDir,
        );
        break; // Hit a piece, stop raycast
      } else if (cushionHit != null && cushionDist <= remainingDistance) {
        points.add(cushionHit);
        remainingDistance -= cushionDist;
        currentOrigin = cushionHit;
        // Reflect off cushion
        currentDir =
            currentDir - cushionNormal! * (2 * currentDir.dot(cushionNormal));
      } else {
        // No collision within remaining distance
        points.add(currentOrigin + currentDir * remainingDistance);
        break;
      }
    }

    return TrajectoryPath(points: points, hit: detectedHit);
  }
}
