import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ParticleItem {
  Vector2 position;
  Vector2 velocity;
  double life;
  double maxLife;
  double size;
  Color color;

  ParticleItem({
    required this.position,
    required this.velocity,
    required this.maxLife,
    required this.size,
    required this.color,
  }) : life = maxLife;
}

class ParticleManagerComponent extends Component {
  final List<ParticleItem> _particles = [];
  final Random _rand = Random();
  final Paint _paint = Paint()..isAntiAlias = true;

  void spawnCollisionSparks(Vector2 pos, double intensity) {
    if (_particles.length >= 25) return;
    final count = (intensity * 6).round().clamp(2, 5);
    for (int i = 0; i < count; i++) {
      final angle = _rand.nextDouble() * 2 * pi;
      final speed = 40.0 + _rand.nextDouble() * 120.0 * intensity;
      _particles.add(
        ParticleItem(
          position: pos.clone(),
          velocity: Vector2(cos(angle) * speed, sin(angle) * speed),
          maxLife: 0.16 + _rand.nextDouble() * 0.14,
          size: 1.5 + _rand.nextDouble() * 2.0,
          color: Colors.amberAccent.withValues(alpha: 0.9),
        ),
      );
    }
  }

  void spawnPocketPuff(Vector2 pos) {
    if (_particles.length >= 30) return;
    for (int i = 0; i < 8; i++) {
      final angle = _rand.nextDouble() * 2 * pi;
      final speed = 20.0 + _rand.nextDouble() * 45.0;
      _particles.add(
        ParticleItem(
          position: pos.clone(),
          velocity: Vector2(cos(angle) * speed, sin(angle) * speed),
          maxLife: 0.30 + _rand.nextDouble() * 0.20,
          size: 2.0 + _rand.nextDouble() * 3.0,
          color: Colors.white70,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_particles.isEmpty) return;

    for (int i = _particles.length - 1; i >= 0; i--) {
      final p = _particles[i];
      p.life -= dt;
      if (p.life <= 0) {
        _particles.removeAt(i);
        continue;
      }
      p.position.addScaled(p.velocity, dt);
      p.velocity.scale(0.92); // Drag
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_particles.isEmpty) return;

    for (final p in _particles) {
      final progress = (p.life / p.maxLife).clamp(0.0, 1.0);
      _paint.color = p.color.withValues(alpha: progress * p.color.a);
      canvas.drawCircle(
        Offset(p.position.x, p.position.y),
        p.size * progress,
        _paint,
      );
    }
  }
}
