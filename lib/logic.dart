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

  int ticks = 0;
  void tick() {
    for ((Enemy, int) enemy in hidingEnemies) {
      if (enemy.$2 == ticks) {
        enemies.add(enemy.$1);
      }
    }
    for (Enemy enemy in enemies) {
      hidingEnemies.removeWhere((e) => e.$1 == enemy);
      enemy.x -= enemy.speed(1000 ~/ 60);
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
