import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/avatar_model.dart';
import '../models/game_entities.dart';
import '../models/map_model.dart';
import '../models/player_model.dart';

/// Enum representing difficulty levels for AI bots in offline matches.
enum BotDifficulty {
  easy,
  normal,
  hard;

  String get displayName {
    switch (this) {
      case BotDifficulty.easy:
        return 'Easy';
      case BotDifficulty.normal:
        return 'Normal';
      case BotDifficulty.hard:
        return 'Hard';
    }
  }

  String get description {
    switch (this) {
      case BotDifficulty.easy:
        return 'Slower bot reaction time and reduced damage';
      case BotDifficulty.normal:
        return 'Standard competitive AI brawlers';
      case BotDifficulty.hard:
        return 'Aggressive bots with rapid dodging and attacks';
    }
  }
}

/// Controller managing offline match configuration, state, and combat simulations.
class GameController extends ChangeNotifier {
  // Map Dimensions
  static const double mapWidth = 1100.0;
  static const double mapHeight = 850.0;

  // Match Configuration State
  WeaponType _selectedWeapon = WeaponType.sword;
  BotDifficulty _botDifficulty = BotDifficulty.normal;
  MapModel _currentMap = MapModel.defaultMap;

  // Active Match Entities
  PlayerModel? _player;
  List<PlayerModel> _bots = [];
  List<CityObstacle> _obstacles = [];
  final List<Projectile> _projectiles = [];
  final List<BombEntity> _bombs = [];
  final List<ExplosionEffect> _explosions = [];
  final List<SlashEffect> _slashes = [];

  // Match Status
  bool _isMatchActive = false;
  bool _isGameOver = false;
  bool _isVictory = false;
  bool _isPaused = false;
  String _lastCombatAction = 'Match started in the Abandoned City!';

  // Movement input buffer
  Offset _movementInput = Offset.zero;

  // 60 FPS High-Precision Game Loop
  Timer? _gameLoopTimer;
  Stopwatch? _gameStopwatch;
  int _lastTickMicros = 0;

  /// High-frequency repaint notifier for CustomPainter (60 FPS without HUD rebuilds)
  final ValueNotifier<int> canvasTickNotifier = ValueNotifier<int>(0);

  // Getters
  WeaponType get selectedWeapon => _selectedWeapon;
  BotDifficulty get botDifficulty => _botDifficulty;
  MapModel get currentMap => _currentMap;
  PlayerModel? get player => _player;
  List<PlayerModel> get bots => _bots;
  List<CityObstacle> get obstacles => _obstacles;
  List<Projectile> get projectiles => _projectiles;
  List<BombEntity> get bombs => _bombs;
  List<ExplosionEffect> get explosions => _explosions;
  List<SlashEffect> get slashes => _slashes;
  bool get isMatchActive => _isMatchActive;
  bool get isGameOver => _isGameOver;
  bool get isVictory => _isVictory;
  bool get isPaused => _isPaused;
  String get lastCombatAction => _lastCombatAction;

  void setWeaponType(WeaponType weapon) {
    _selectedWeapon = weapon;
    notifyListeners();
  }

  void setBotDifficulty(BotDifficulty difficulty) {
    _botDifficulty = difficulty;
    notifyListeners();
  }

  /// Updates directional input from joystick or keyboard WASD.
  void setMovementInput(Offset input) {
    if (_isPaused) {
      _movementInput = Offset.zero;
      return;
    }
    _movementInput = input;
  }

  /// Pauses active match simulation, freezing AI, physics, projectiles, and timers.
  void pauseMatch() {
    if (!_isPaused && _isMatchActive && !_isGameOver) {
      _isPaused = true;
      _movementInput = Offset.zero;
      _gameStopwatch?.stop();
      notifyListeners();
    }
  }

  /// Resumes match simulation from exact frozen state without entity or position resets.
  void resumeMatch() {
    if (_isPaused) {
      _isPaused = false;
      _gameStopwatch?.start();
      _lastTickMicros = _gameStopwatch?.elapsedMicroseconds ?? 0;
      notifyListeners();
    }
  }

  /// Toggles pause state.
  void togglePause() {
    if (_isPaused) {
      resumeMatch();
    } else {
      pauseMatch();
    }
  }

  /// Restarts the current expedition with the exact same map, weapon, avatar, and difficulty.
  void restartCurrentMatch(String nickname) {
    _isPaused = false;
    startMatch(
      playerNickname: nickname,
      avatar: _player?.avatar,
      map: _currentMap,
    );
  }

  /// Builds the Abandoned City layout with roads, barriers, ruined cars, and dumpsters.
  void _initializeAbandonedCity() {
    _obstacles = [
      // 1. Central Concrete Roadblock (blocks direct line of sight)
      const CityObstacle(
        rect: Rect.fromLTWH(500, 390, 100, 26),
        type: ObstacleType.concreteBarrier,
        baseColor: Color(0xFF4A5568),
        label: 'JERSEY BARRIER',
      ),

      // 2. Ruined Abandoned Sedans & Police Cruiser
      const CityObstacle(
        rect: Rect.fromLTWH(260, 220, 80, 44),
        type: ObstacleType.ruinedCar,
        baseColor: Color(0xFF7B341E),
        label: 'RUSTY SEDAN',
      ),
      const CityObstacle(
        rect: Rect.fromLTWH(760, 240, 84, 46),
        type: ObstacleType.ruinedCar,
        baseColor: Color(0xFF1E3A8A),
        label: 'POLICE CRUISER',
      ),
      const CityObstacle(
        rect: Rect.fromLTWH(420, 580, 90, 48),
        type: ObstacleType.ruinedCar,
        baseColor: Color(0xFF4B5563),
        label: 'WRECKED VAN',
      ),

      // 3. Concrete Jersey Barriers across intersections
      const CityObstacle(
        rect: Rect.fromLTWH(180, 440, 90, 24),
        type: ObstacleType.concreteBarrier,
        baseColor: Color(0xFF4A5568),
        label: 'BARRIER',
      ),
      const CityObstacle(
        rect: Rect.fromLTWH(830, 460, 90, 24),
        type: ObstacleType.concreteBarrier,
        baseColor: Color(0xFF4A5568),
        label: 'BARRIER',
      ),

      // 4. Heavy Metal Dumpsters in side alleys
      const CityObstacle(
        rect: Rect.fromLTWH(150, 150, 48, 38),
        type: ObstacleType.dumpster,
        baseColor: Color(0xFF064E3B),
        label: 'DUMPSTER',
      ),
      const CityObstacle(
        rect: Rect.fromLTWH(910, 680, 50, 40),
        type: ObstacleType.dumpster,
        baseColor: Color(0xFF064E3B),
        label: 'DUMPSTER',
      ),

      // 5. Military Cargo Supply Crates
      const CityObstacle(
        rect: Rect.fromLTWH(680, 520, 38, 38),
        type: ObstacleType.crate,
        baseColor: Color(0xFF78350F),
        label: 'CRATE',
      ),
      const CityObstacle(
        rect: Rect.fromLTWH(360, 320, 36, 36),
        type: ObstacleType.crate,
        baseColor: Color(0xFF78350F),
        label: 'CRATE',
      ),

      // 6. Crumbling Brick Building Walls
      const CityObstacle(
        rect: Rect.fromLTWH(50, 280, 34, 180),
        type: ObstacleType.brickWall,
        baseColor: Color(0xFF881337),
        label: 'BRICK RUIN',
      ),
      const CityObstacle(
        rect: Rect.fromLTWH(1010, 340, 34, 180),
        type: ObstacleType.brickWall,
        baseColor: Color(0xFF881337),
        label: 'BRICK RUIN',
      ),
    ];
  }

  /// Initializes a match session in the chosen realm against AI companion mages.
  void startMatch({
    required String playerNickname,
    AvatarModel? avatar,
    MapModel? map,
  }) {
    _isMatchActive = true;
    _isGameOver = false;
    _isVictory = false;
    _isPaused = false;
    _currentMap = map ?? _currentMap;
    _lastCombatAction = 'Expedition begun in ${_currentMap.name}!';
    _movementInput = Offset.zero;

    _projectiles.clear();
    _bombs.clear();
    _explosions.clear();
    _slashes.clear();

    _initializeAbandonedCity();

    // Create player with selected weapon, avatar, and appropriate stats
    _player = PlayerModel(
      id: 'local_player',
      name: playerNickname.isEmpty ? 'Traveler' : playerNickname,
      health: 100.0 + _selectedWeapon.bonusHealth,
      maxHealth: 100.0 + _selectedWeapon.bonusHealth,
      x: mapWidth / 2,
      y: mapHeight / 2 + 80,
      angle: -math.pi / 2, // Facing North initially
      isBot: false,
      weapon: _selectedWeapon,
      avatar: avatar ?? AvatarModel.defaultAvatar,
    );

    // Spawn 3 AI companion bots in different tactical sectors
    _bots = [
      PlayerModel(
        id: 'bot_alpha',
        name: 'Ranger Faelor',
        health: 100.0,
        x: 240,
        y: 180,
        angle: math.pi / 4,
        isBot: true,
        weapon: WeaponType.sword,
        avatar: const AvatarModel(
          id: 'bot_avatar_1',
          name: 'Ranger Faelor',
          className: 'Forest Archer',
          robeColor: Color(0xFF6B4A3A),
          trimColor: Color(0xFFC9A86A),
          hairColor: Color(0xFFD4A373),
          hasCloak: true,
          headpiece: 'cowl',
          staffType: 'woodenStaff',
        ),
      ),
      PlayerModel(
        id: 'bot_bravo',
        name: 'Mage Kaelen',
        health: 100.0,
        x: 860,
        y: 190,
        angle: math.pi * 0.75,
        isBot: true,
        weapon: WeaponType.bow,
        avatar: const AvatarModel(
          id: 'bot_avatar_2',
          name: 'Mage Kaelen',
          className: 'Human Mage Apprentice',
          robeColor: Color(0xFF385E48),
          trimColor: Color(0xFF8FBFB5),
          hairColor: Color(0xFFE2E8F0),
          hasCloak: false,
          headpiece: 'circlet',
          staffType: 'crystalStaff',
        ),
      ),
      PlayerModel(
        id: 'bot_charlie',
        name: 'Alchemist Thuron',
        health: 130.0,
        x: 550,
        y: 720,
        angle: -math.pi / 2,
        isBot: true,
        weapon: WeaponType.bomb,
        avatar: const AvatarModel(
          id: 'bot_avatar_3',
          name: 'Alchemist Thuron',
          className: 'Wandering Scholar',
          robeColor: Color(0xFF485875),
          trimColor: Color(0xFFDFCA9B),
          hairColor: Color(0xFF33272A),
          hasCloak: true,
          headpiece: 'none',
          staffType: 'flowerStaff',
        ),
      ),
    ];

    // Start 60 FPS update loop with high-precision delta time
    _gameStopwatch?.stop();
    _gameStopwatch = Stopwatch()..start();
    _lastTickMicros = 0;

    _gameLoopTimer?.cancel();
    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final currentMicros = _gameStopwatch?.elapsedMicroseconds ?? 0;
      double dt = 0.016;
      if (_lastTickMicros > 0) {
        dt = (currentMicros - _lastTickMicros) / 1000000.0;
        dt = dt.clamp(0.008, 0.033);
      }
      _lastTickMicros = currentMicros;
      _tick(dt);
    });

    notifyListeners();
  }

  /// Main game physics and simulation tick (60 FPS).
  void _tick(double dt) {
    if (!_isMatchActive || _isGameOver || _isPaused) return;

    final player = _player;
    if (player == null || !player.isAlive) {
      if (!_isGameOver) {
        _isGameOver = true;
        _isVictory = false;
        _lastCombatAction = '💀 Defeated! You were eliminated in combat.';
        notifyListeners();
      }
      return;
    }

    final double prevHp = player.health;
    final int prevKills = player.kills;
    final String prevAction = _lastCombatAction;
    final bool prevGameOver = _isGameOver;
    final bool prevVictory = _isVictory;

    // 1. Update Player Physics & Movement
    _updatePlayerPhysics(dt, player);

    // 2. Update Bots AI & Combat
    _updateBotsAI(dt, player);

    // 3. Update Active Projectiles (Arrows)
    _updateProjectiles(dt);

    // 4. Update Deployed Bombs
    _updateBombs(dt);

    // 5. Update Visual Effects Timers
    _updateVisualEffects(dt);

    // 6. Check Win Condition
    final aliveBots = _bots.where((b) => b.isAlive).toList();
    if (aliveBots.isEmpty && !_isVictory) {
      _isVictory = true;
      _isGameOver = true;
      _lastCombatAction = '🏆 VICTORY! All enemy bots eliminated!';
    }

    // 60 FPS Fast Canvas tick: Repaints CustomPaint directly without HUD rebuild
    canvasTickNotifier.value++;

    // Slow HUD state: Rebuilds UI widgets only when health, kills, message, or outcome changes
    if (player.health != prevHp ||
        player.kills != prevKills ||
        _lastCombatAction != prevAction ||
        _isGameOver != prevGameOver ||
        _isVictory != prevVictory) {
      notifyListeners();
    }
  }

  /// Updates player position, collisions with city obstacles, and walk animations.
  void _updatePlayerPhysics(double dt, PlayerModel player) {
    // Cooldown timers
    if (player.attackCooldownTimer > 0) {
      player.attackCooldownTimer -= dt;
    }
    if (player.attackAnimTimer > 0) {
      player.attackAnimTimer -= dt;
    }
    if (player.hitFlashTimer > 0) {
      player.hitFlashTimer -= dt;
    }

    // Apply movement input
    if (_movementInput != Offset.zero) {
      final double speed = player.weapon.moveSpeed;
      final double moveX = _movementInput.dx * speed * dt;
      final double moveY = _movementInput.dy * speed * dt;

      // Update facing angle
      player.angle = math.atan2(_movementInput.dy, _movementInput.dx);

      // Advance walk cycle for animated hands and feet
      player.walkCycle += dt * 14.0;

      // Test horizontal movement with obstacle collision
      final double newX = (player.x + moveX).clamp(24.0, mapWidth - 24.0);
      if (!_isCollidingWithObstacle(newX, player.y, 18.0)) {
        player.x = newX;
      }

      // Test vertical movement with obstacle collision
      final double newY = (player.y + moveY).clamp(24.0, mapHeight - 24.0);
      if (!_isCollidingWithObstacle(player.x, newY, 18.0)) {
        player.y = newY;
      }
    }
  }

  /// Updates AI decision-making for bots based on chosen difficulty.
  void _updateBotsAI(double dt, PlayerModel player) {
    // Difficulty parameters
    final double moveSpeedMultiplier;
    final double attackCooldownTime;
    final double detectionRadius;

    switch (_botDifficulty) {
      case BotDifficulty.easy:
        moveSpeedMultiplier = 0.58;
        attackCooldownTime = 1.80;
        detectionRadius = 320.0;
        break;
      case BotDifficulty.normal:
        moveSpeedMultiplier = 0.88;
        attackCooldownTime = 1.05;
        detectionRadius = 450.0;
        break;
      case BotDifficulty.hard:
        moveSpeedMultiplier = 1.15;
        attackCooldownTime = 0.60;
        detectionRadius = 650.0;
        break;
    }

    for (final bot in _bots) {
      if (!bot.isAlive) continue;

      if (bot.attackCooldownTimer > 0) bot.attackCooldownTimer -= dt;
      if (bot.attackAnimTimer > 0) bot.attackAnimTimer -= dt;
      if (bot.hitFlashTimer > 0) bot.hitFlashTimer -= dt;

      final double dx = player.x - bot.x;
      final double dy = player.y - bot.y;
      final double distSq = dx * dx + dy * dy;
      final double detectionRadiusSq = detectionRadius * detectionRadius;

      // Aim at player
      bot.angle = math.atan2(dy, dx);

      // State: Chase or keep optimal combat distance
      final double optimalRange;
      switch (bot.weapon) {
        case WeaponType.sword:
          optimalRange = 45.0; // Melee rush
          break;
        case WeaponType.bow:
          optimalRange = 220.0; // Stand off distance
          break;
        case WeaponType.bomb:
          optimalRange = 140.0; // Medium distance
          break;
      }
      final double optimalRangeSq = optimalRange * optimalRange;

      bool shouldMove = distSq < detectionRadiusSq;
      double moveDirection = 1.0;

      if (bot.weapon == WeaponType.bow && distSq < (140.0 * 140.0)) {
        // Back away if player gets too close
        moveDirection = -1.0;
      } else if (distSq <= optimalRangeSq) {
        shouldMove = false;
      }

      if (shouldMove) {
        final double distToPlayer = math.sqrt(distSq);
        final double speed = bot.weapon.moveSpeed * moveSpeedMultiplier;
        final double dirX = (dx / distToPlayer) * moveDirection;
        final double dirY = (dy / distToPlayer) * moveDirection;

        bot.walkCycle += dt * 12.0;

        final double nextX = (bot.x + dirX * speed * dt).clamp(24.0, mapWidth - 24.0);
        if (!_isCollidingWithObstacle(nextX, bot.y, 18.0)) {
          bot.x = nextX;
        }

        final double nextY = (bot.y + dirY * speed * dt).clamp(24.0, mapHeight - 24.0);
        if (!_isCollidingWithObstacle(bot.x, nextY, 18.0)) {
          bot.y = nextY;
        }
      }

      // Attack if within weapon range and off cooldown
      final double attackRangeSq = bot.weapon.attackRange * bot.weapon.attackRange;
      if (distSq <= attackRangeSq && bot.attackCooldownTimer <= 0) {
        bot.attackCooldownTimer = attackCooldownTime;
        _executeBotAttack(bot, player);
      }
    }
  }

  void _executeBotAttack(PlayerModel bot, PlayerModel player) {
    bot.attackAnimTimer = 0.25;

    switch (bot.weapon) {
      case WeaponType.sword:
        _slashes.add(SlashEffect(
          x: bot.x + math.cos(bot.angle) * 20,
          y: bot.y + math.sin(bot.angle) * 20,
          angle: bot.angle,
          radius: 65,
        ));
        // Check if player hit by sword slash (dist <= 65)
        final double dx = player.x - bot.x;
        final double dy = player.y - bot.y;
        if ((dx * dx + dy * dy) <= (65.0 * 65.0)) {
          _damagePlayer(bot.weapon.baseDamage);
        }
        break;

      case WeaponType.bow:
        final arrowSpeed = 520.0;
        _projectiles.add(Projectile(
          id: UniqueKey().toString(),
          ownerId: bot.id,
          x: bot.x + math.cos(bot.angle) * 22,
          y: bot.y + math.sin(bot.angle) * 22,
          vx: math.cos(bot.angle) * arrowSpeed,
          vy: math.sin(bot.angle) * arrowSpeed,
          angle: bot.angle,
          damage: bot.weapon.baseDamage,
        ));
        break;

      case WeaponType.bomb:
        _bombs.add(BombEntity(
          id: UniqueKey().toString(),
          ownerId: bot.id,
          x: bot.x + math.cos(bot.angle) * 75,
          y: bot.y + math.sin(bot.angle) * 75,
          damage: bot.weapon.baseDamage,
        ));
        break;
    }
  }

  /// Triggers the active player attack based on selected weapon.
  void performActiveAttack() {
    if (_isPaused) return;
    final player = _player;
    if (player == null || !player.isAlive || player.attackCooldownTimer > 0) return;

    player.attackCooldownTimer = player.weapon.attackCooldown;
    player.attackAnimTimer = 0.28;

    switch (player.weapon) {
      case WeaponType.sword:
        swingSword();
        break;
      case WeaponType.bow:
        fireArrow();
        break;
      case WeaponType.bomb:
        plantBomb();
        break;
    }
  }

  /// SWORD LOGIC: Sweeping arc slash damaging nearby bots with knockback.
  void swingSword() {
    final player = _player;
    if (player == null) return;

    final slashX = player.x + math.cos(player.angle) * 22;
    final slashY = player.y + math.sin(player.angle) * 22;

    _slashes.add(SlashEffect(
      x: slashX,
      y: slashY,
      angle: player.angle,
      radius: player.weapon.attackRange,
    ));

    final double rangeSq = player.weapon.attackRange * player.weapon.attackRange;
    int hitCount = 0;
    for (final bot in _bots) {
      if (!bot.isAlive) continue;

      final double dx = bot.x - player.x;
      final double dy = bot.y - player.y;
      final double distSq = dx * dx + dy * dy;

      if (distSq <= rangeSq) {
        // Angle check: within 120-degree frontal cone
        final botAngle = math.atan2(dy, dx);
        double angleDiff = (botAngle - player.angle).abs();
        if (angleDiff > math.pi) angleDiff = 2 * math.pi - angleDiff;

        if (angleDiff <= math.pi / 2.8) {
          // Check line of sight (not blocked by brick wall)
          if (!_isLineBlockedByWall(player.x, player.y, bot.x, bot.y)) {
            _damageBot(bot, player.weapon.baseDamage, dx, dy);
            hitCount++;
          }
        }
      }
    }

    _lastCombatAction = hitCount > 0
        ? '⚔️ Sword struck $hitCount enemy brawler(s) for ${player.weapon.baseDamage.toInt()} dmg!'
        : '⚔️ Sword sliced the air with a swift strike';
  }

  /// BOW LOGIC: Fires a high-velocity arrow blocked by city obstacles.
  void fireArrow() {
    final player = _player;
    if (player == null) return;

    const double arrowSpeed = 560.0;
    final spawnX = player.x + math.cos(player.angle) * 24;
    final spawnY = player.y + math.sin(player.angle) * 24;

    _projectiles.add(Projectile(
      id: UniqueKey().toString(),
      ownerId: player.id,
      x: spawnX,
      y: spawnY,
      vx: math.cos(player.angle) * arrowSpeed,
      vy: math.sin(player.angle) * arrowSpeed,
      angle: player.angle,
      damage: player.weapon.baseDamage,
    ));

    _lastCombatAction = '🏹 Arrow fired across the street!';
  }

  /// BOMB LOGIC: Deploys a ticking tactical explosive with massive area damage.
  void plantBomb() {
    final player = _player;
    if (player == null) return;

    // Place or throw bomb 80px forward
    final targetX = (player.x + math.cos(player.angle) * 80).clamp(30.0, mapWidth - 30.0);
    final targetY = (player.y + math.sin(player.angle) * 80).clamp(30.0, mapHeight - 30.0);

    _bombs.add(BombEntity(
      id: UniqueKey().toString(),
      ownerId: player.id,
      x: targetX,
      y: targetY,
      fuseTimer: 1.5,
      blastRadius: 95.0,
      damage: player.weapon.baseDamage,
    ));

    _lastCombatAction = '💣 Tactical bomb deployed! Detonating in 1.5s...';
  }

  /// Updates projectile flight and obstacle/entity impact checks.
  void _updateProjectiles(double dt) {
    for (int i = _projectiles.length - 1; i >= 0; i--) {
      final p = _projectiles[i];
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.lifetime -= dt;

      // Out of bounds or expired
      if (p.lifetime <= 0 || p.x < 0 || p.x > mapWidth || p.y < 0 || p.y > mapHeight) {
        _projectiles.removeAt(i);
        continue;
      }

      // Check collision with city obstacles (cars, barriers, walls)
      bool hitObstacle = false;
      for (final obs in _obstacles) {
        if (obs.blocksProjectiles && obs.rect.contains(Offset(p.x, p.y))) {
          hitObstacle = true;
          break;
        }
      }
      if (hitObstacle) {
        _projectiles.removeAt(i);
        continue;
      }

      // Check collision with characters
      const double hitRadiusSq = 20.0 * 20.0;
      if (p.ownerId == 'local_player') {
        // Player's arrow hits bot
        for (final bot in _bots) {
          if (!bot.isAlive) continue;
          final double dx = bot.x - p.x;
          final double dy = bot.y - p.y;
          if ((dx * dx + dy * dy) <= hitRadiusSq) {
            _damageBot(bot, p.damage, p.vx, p.vy);
            _projectiles.removeAt(i);
            break;
          }
        }
      } else {
        // Bot's arrow hits player
        final player = _player;
        if (player != null && player.isAlive) {
          final double dx = player.x - p.x;
          final double dy = player.y - p.y;
          if ((dx * dx + dy * dy) <= hitRadiusSq) {
            _damagePlayer(p.damage);
            _projectiles.removeAt(i);
          }
        }
      }
    }
  }

  /// Updates bomb fuses, triggers blast detonations, and checks wall coverage.
  void _updateBombs(double dt) {
    for (int i = _bombs.length - 1; i >= 0; i--) {
      final bomb = _bombs[i];
      bomb.fuseTimer -= dt;

      if (bomb.hasDetonated) {
        // Detonate bomb
        _explosions.add(ExplosionEffect(
          x: bomb.x,
          y: bomb.y,
          maxRadius: bomb.blastRadius,
        ));

        final double blastRadiusSq = bomb.blastRadius * bomb.blastRadius;

        // Damage bots within blast radius
        for (final bot in _bots) {
          if (!bot.isAlive) continue;
          final double dx = bot.x - bomb.x;
          final double dy = bot.y - bomb.y;
          final double distSq = dx * dx + dy * dy;
          if (distSq <= blastRadiusSq) {
            if (!_isLineBlockedByWall(bomb.x, bomb.y, bot.x, bot.y)) {
              final double dist = math.sqrt(distSq);
              final damageRatio = 1.0 - (dist / bomb.blastRadius) * 0.4;
              _damageBot(bot, bomb.damage * damageRatio, dx, dy);
            }
          }
        }

        // Damage player if caught in blast
        final player = _player;
        if (player != null && player.isAlive) {
          final double dx = player.x - bomb.x;
          final double dy = player.y - bomb.y;
          final double distSq = dx * dx + dy * dy;
          if (distSq <= blastRadiusSq) {
            if (!_isLineBlockedByWall(bomb.x, bomb.y, player.x, player.y)) {
              final double dist = math.sqrt(distSq);
              final damageRatio = 1.0 - (dist / bomb.blastRadius) * 0.4;
              _damagePlayer(bomb.damage * damageRatio);
            }
          }
        }

        _lastCombatAction = '💥 Bomb detonated with massive shockwave!';
        _bombs.removeAt(i);
      }
    }
  }

  void _updateVisualEffects(double dt) {
    _explosions.removeWhere((e) {
      e.timer -= dt;
      return e.isFinished;
    });

    _slashes.removeWhere((s) {
      s.timer -= dt;
      return s.isFinished;
    });
  }

  void _damageBot(PlayerModel bot, double amount, double knockX, double knockY) {
    bot.health = (bot.health - amount).clamp(0.0, bot.maxHealth);
    bot.hitFlashTimer = 0.22;

    // Apply knockback
    final len = math.sqrt(knockX * knockX + knockY * knockY);
    if (len > 0) {
      bot.x = (bot.x + (knockX / len) * 22).clamp(24.0, mapWidth - 24.0);
      bot.y = (bot.y + (knockY / len) * 22).clamp(24.0, mapHeight - 24.0);
    }

    if (bot.health <= 0) {
      _player?.kills++;
      _lastCombatAction = '🎯 Target eliminated! ${bot.name} was defeated.';
    }
  }

  void _damagePlayer(double amount) {
    final player = _player;
    if (player == null) return;

    player.health = (player.health - amount).clamp(0.0, player.maxHealth);
    player.hitFlashTimer = 0.22;

    if (player.health <= 0) {
      _lastCombatAction = '💀 You have been defeated!';
    }
  }

  /// Checks if circle intersects with any city obstacle bounding box.
  bool _isCollidingWithObstacle(double cx, double cy, double radius) {
    for (final obs in _obstacles) {
      final rect = obs.rect;
      final closestX = cx.clamp(rect.left, rect.right);
      final closestY = cy.clamp(rect.top, rect.bottom);
      final distanceX = cx - closestX;
      final distanceY = cy - closestY;
      if ((distanceX * distanceX + distanceY * distanceY) < (radius * radius)) {
        return true;
      }
    }
    return false;
  }

  /// Checks if line of sight between two points is blocked by a solid brick wall.
  bool _isLineBlockedByWall(double x1, double y1, double x2, double y2) {
    for (final obs in _obstacles) {
      if (obs.blocksExplosion) {
        // Line-segment intersection with obstacle rect
        if (obs.rect.contains(Offset((x1 + x2) / 2, (y1 + y2) / 2))) {
          return true;
        }
      }
    }
    return false;
  }

  /// Ends and tears down the active match session.
  void quitMatch() {
    _gameLoopTimer?.cancel();
    _gameLoopTimer = null;
    _gameStopwatch?.stop();
    _gameStopwatch = null;
    _lastTickMicros = 0;
    _isMatchActive = false;
    _isGameOver = false;
    _isVictory = false;
    _isPaused = false;
    _player = null;
    _bots.clear();
    _projectiles.clear();
    _bombs.clear();
    _explosions.clear();
    _slashes.clear();
    _movementInput = Offset.zero;
    notifyListeners();
  }

  @override
  void dispose() {
    _gameLoopTimer?.cancel();
    _gameStopwatch?.stop();
    canvasTickNotifier.dispose();
    super.dispose();
  }
}
