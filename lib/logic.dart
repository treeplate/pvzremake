import 'tower.dart';

class TowerArea {
  // working title

  /// Number of squares in game board.
  final int width;
  late final List<Tower?> towers;

  /// [height] or [towers] must be non-null.
  /// [height] and [towers] cannot both be null; the height is determined from [width] and [towers].
  /// If [towers] is null, an empty grid based on [width] and [height] will be created.
  TowerArea({required this.width, int? height, List<Tower>? towers})
      : assert((height == null) != (towers == null)) {
    this.towers = towers ?? List.generate(width * height!, (index) => null);
  }
}
