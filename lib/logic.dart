import 'floor.dart';
import 'tower.dart';

// working title
class TowerArea {
  /// Number of squares in game board.
  final int width;
  late final List<Tower?> towers;
  final List<Floor> floors;

  /// [height] or [towers] must be non-null.
  /// [height] and [towers] cannot both be non-null; the height is determined from [width] and [towers].
  /// If [towers] is null, an empty grid based on [width] and [height] will be created.
  TowerArea({
    required this.width,
    int? height,
    required this.floors,
    List<Tower>? towers,
  }) : assert((height == null) != (towers == null)) {
    this.towers = towers ?? List.generate(width * height!, (index) => null);
  }
}
