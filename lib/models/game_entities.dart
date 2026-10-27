import 'package:flutter/material.dart';

/// Categories of physical obstacles found across the abandoned city map.
enum ObstacleType {
  ruinedCar,
  concreteBarrier,
  dumpster,
  crate,
  brickWall,
}

/// A physical obstacle in the city that blocks character movement and attacks.
class CityObstacle {
  final Rect rect;
  final ObstacleType type;
  final Color baseColor;
  final String label;

  const CityObstacle({
    required this.rect,
    required this.type,
    required this.baseColor,
    required this.label,
  });

  bool get blocksProjectiles => true;
  bool get blocksExplosion => type == ObstacleType.brickWall || type == ObstacleType.concreteBarrier;
}

/// An active projectile in the arena (e.g., piercing arrow).
class Projectile {
  final String id;
  final String ownerId;
  double x;
  double y;
  final double vx;
  final double vy;
  final double angle;
  final double damage;
  double lifetime;

  Projectile({
    required this.id,
    required this.ownerId,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.angle,
    required this.damage,
    this.lifetime = 1.6,
  });
}

/// A deployed tactical bomb ticking down in the abandoned city.
class BombEntity {
  final String id;
  final String ownerId;
  double x;
  double y;
  double fuseTimer;
  final double maxFuseTimer;
  final double blastRadius;
  final double damage;

  BombEntity({
    required this.id,
    required this.ownerId,
    required this.x,
    required this.y,
    this.fuseTimer = 1.5,
    this.blastRadius = 90.0,
    this.damage = 75.0,
  }) : maxFuseTimer = fuseTimer;

  bool get hasDetonated => fuseTimer <= 0;
}

/// Visual shockwave explosion effect for detonated bombs.
class ExplosionEffect {
  final double x;
  final double y;
  final double maxRadius;
  double timer;
  final double duration;

  ExplosionEffect({
    required this.x,
    required this.y,
    required this.maxRadius,
    this.duration = 0.35,
  }) : timer = duration;

  bool get isFinished => timer <= 0;
  double get progress => (1.0 - (timer / duration)).clamp(0.0, 1.0);
}

/// Visual slash arc effect for sword attacks.
class SlashEffect {
  final double x;
  final double y;
  final double angle;
  final double radius;
  double timer;
  final double duration;

  SlashEffect({
    required this.x,
    required this.y,
    required this.angle,
    required this.radius,
    this.duration = 0.22,
  }) : timer = duration;

  bool get isFinished => timer <= 0;
  double get progress => (1.0 - (timer / duration)).clamp(0.0, 1.0);
}
