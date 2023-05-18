import 'dart:math';

import 'enemy.dart';
import 'floor.dart';
import 'tower.dart';

// working title
class TowerArea {
  /// Number of squares in game board.
  final int width;
  late final List<Tower?> towers;
  final List<Floor> floors;
  final List<Enemy> enemies = [];
  final List<(Enemy, int)> hidingEnemies;
  final List<(int, LaneClearer, {Tower? oldTower})> laneClearings = [];
  final List<Projectile> projectiles = [];
  final List<(double, double)> coins = [];

  int ticks = 0;
  int money = 50;
  Random r = Random();

  void tick() {
    for ((Enemy, int) enemy in hidingEnemies) {
      if (enemy.$2 == ticks) {
        print('NEW ENEMY ${enemy.$1}');
        enemies.add(enemy.$1);
      }
      if (enemy.$2 < ticks) {
        print('PAST ENEMY');
      }
    }
    for (Enemy enemy in enemies.toList()) {
      hidingEnemies.removeWhere((e) => e.$1 == enemy);

      if (enemy.x < width &&
          towers[enemy.x.floor() + enemy.y * width] != null) {
        Tower tower = towers[enemy.x.floor() + enemy.y * width]!;
        switch (tower) {
          case BasicTower():
            continue;
          case BasicWall():
            continue;
          case BasicCoinTower():
            tower.health -= 100 / 60;
            if (tower.health <= 0) {
              towers[enemy.x.floor() + enemy.y * width] = null;
            }
          case LaneClearer():
            if (laneClearings.any((element) => element.$2 == tower)) {
              break;
            }
            laneClearings.add((enemy.y, tower, oldTower: null));
        }
      } else {
        enemy.x -= enemy.speed(1000 ~/ 60);
      }
    }
    if (ticks % 60 == 0) {
      for ((int, LaneClearer, {Tower? oldTower}) laneClearer
          in laneClearings.toList()) {
        for (Enemy enemy in enemies.toList()) {
          if (enemy.y == laneClearer.$1) {
            enemies.remove(enemy);
          }
        }
        int oldIndex = towers.indexOf(laneClearer.$2);
        if ((oldIndex + 1) % width == 0) {
          laneClearings.remove(laneClearer);
          towers[oldIndex] = laneClearer.oldTower;
          continue;
        }
        towers[oldIndex] = laneClearer.oldTower;
        laneClearings.add(
            (laneClearer.$1, laneClearer.$2, oldTower: towers[oldIndex + 1]));
        laneClearings.remove(laneClearer);
        towers[oldIndex + 1] = laneClearer.$2;
      }
    }
    int x = 0;
    int y = 0;
    for (Tower? tower in towers) {
      if (x == width) {
        y++;
        x = 0;
      }
      switch (tower) {
        case null:
        case LaneClearer():
        case BasicWall():
          break;
        case BasicTower():
          if (ticks % 90 == 0) {
            projectiles.add(BasicProjectile(y, x.toDouble()));
          }
        case BasicCoinTower():
          if (ticks % (60 * 32) == 0) {
            coins.add((x.toDouble(), y.toDouble()));
          }
      }
      x++;
    }
    for (Projectile projectile in projectiles.toList()) {
      switch (projectile) {
        case BasicProjectile():
          projectile.x += 3 / 60;
      }
      if (enemies.any((element) =>
          element.x.floor() == projectile.x.floor() &&
          element.y == projectile.y)) {
        Enemy enemy = enemies.firstWhere((element) =>
            element.x.floor() == projectile.x.floor() &&
            element.y == projectile.y);
        enemy.health -= projectile.damage;
        projectiles.remove(projectile);
        if (enemy.health <= 0) {
          enemies.remove(enemy);
        }
      }
      if (projectile.x > width) {
        projectiles.remove(projectile);
      }
    }
    ticks++;
    if (ticks % (60 * 9) == 0) {
      coins.add((r.nextDouble() * 10, -1));
    }
    int i = 0;
    for ((double, double) coin in coins) {
      coins[i] = (coin.$1, coin.$2 + .01);
      i++;
    }
  }

  /// [height] or [towers] must be non-null.
  /// [height] and [towers] cannot both be non-null; the height is determined from [width] and [towers].
  /// If [towers] is null, an empty grid based on [width] and [height] will be created.
  TowerArea(
      {required this.width,
      int? height,
      required this.floors,
      List<Tower>? towers,
      required this.hidingEnemies})
      : assert((height == null) != (towers == null)) {
    this.towers = towers ??
        List.generate(width * height!,
            (index) => index % width == 0 ? LaneClearer(0) : null);
  }
}
