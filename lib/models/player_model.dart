import 'avatar_model.dart';

/// Available weapons in the brawler with tailored tactical stats.
enum WeaponType {
  sword,
  bow,
  bomb;

  String get displayName {
    switch (this) {
      case WeaponType.sword:
        return 'Sword';
      case WeaponType.bow:
        return 'Bow';
      case WeaponType.bomb:
        return 'Bomb';
    }
  }

  String get description {
    switch (this) {
      case WeaponType.sword:
        return 'Agile melee slash • High damage & fast mobility';
      case WeaponType.bow:
        return 'Precision ranged arrows • Long distance piercing';
      case WeaponType.bomb:
        return 'Tactical demolition • Heavy armor & massive AoE';
    }
  }

  /// Character movement speed in pixels/second.
  double get moveSpeed {
    switch (this) {
      case WeaponType.sword:
        return 175.0; // Agile lightweight brawler
      case WeaponType.bow:
        return 145.0; // Balanced archer
      case WeaponType.bomb:
        return 120.0; // Heavy armored demolitionist
    }
  }

  /// Base damage dealt per attack.
  double get baseDamage {
    switch (this) {
      case WeaponType.sword:
        return 48.0;
      case WeaponType.bow:
        return 34.0;
      case WeaponType.bomb:
        return 75.0;
    }
  }

  /// Attack cooldown delay in seconds.
  double get attackCooldown {
    switch (this) {
      case WeaponType.sword:
        return 0.38;
      case WeaponType.bow:
        return 0.55;
      case WeaponType.bomb:
        return 1.30;
    }
  }

  /// Effective attack range in pixels.
  double get attackRange {
    switch (this) {
      case WeaponType.sword:
        return 68.0;
      case WeaponType.bow:
        return 420.0;
      case WeaponType.bomb:
        return 160.0;
    }
  }

  /// Bonus health added to the character's base 100 HP.
  double get bonusHealth {
    switch (this) {
      case WeaponType.sword:
        return 0.0;
      case WeaponType.bow:
        return 0.0;
      case WeaponType.bomb:
        return 30.0; // 130 max HP for Bomb wielder
    }
  }
}

/// Model representing a player or AI bot entity in the arena.
class PlayerModel {
  final String id;
  final String name;
  double health;
  final double maxHealth;
  double x;
  double y;
  double angle; // Facing angle in radians
  double walkCycle; // Walk animation phase for hands and feet
  double attackAnimTimer; // Active attack animation timer
  double hitFlashTimer; // Red/white flash when taking damage
  double attackCooldownTimer;
  final bool isBot;
  final WeaponType weapon;
  final AvatarModel? avatar;
  int kills;

  PlayerModel({
    required this.id,
    required this.name,
    this.health = 100.0,
    double? maxHealth,
    this.x = 0.0,
    this.y = 0.0,
    this.angle = 0.0,
    this.walkCycle = 0.0,
    this.attackAnimTimer = 0.0,
    this.hitFlashTimer = 0.0,
    this.attackCooldownTimer = 0.0,
    this.isBot = false,
    this.weapon = WeaponType.sword,
    this.avatar,
    this.kills = 0,
  }) : maxHealth = maxHealth ?? (100.0 + weapon.bonusHealth);

  bool get isAlive => health > 0;

  PlayerModel copyWith({
    String? id,
    String? name,
    double? health,
    double? maxHealth,
    double? x,
    double? y,
    double? angle,
    double? walkCycle,
    double? attackAnimTimer,
    double? hitFlashTimer,
    double? attackCooldownTimer,
    bool? isBot,
    WeaponType? weapon,
    AvatarModel? avatar,
    int? kills,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      health: health ?? this.health,
      maxHealth: maxHealth ?? this.maxHealth,
      x: x ?? this.x,
      y: y ?? this.y,
      angle: angle ?? this.angle,
      walkCycle: walkCycle ?? this.walkCycle,
      attackAnimTimer: attackAnimTimer ?? this.attackAnimTimer,
      hitFlashTimer: hitFlashTimer ?? this.hitFlashTimer,
      attackCooldownTimer: attackCooldownTimer ?? this.attackCooldownTimer,
      isBot: isBot ?? this.isBot,
      weapon: weapon ?? this.weapon,
      avatar: avatar ?? this.avatar,
      kills: kills ?? this.kills,
    );
  }
}
