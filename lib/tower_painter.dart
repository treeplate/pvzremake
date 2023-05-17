import 'dart:ui';

import 'package:pvzremake/grid.dart';

import 'tower.dart';

TowerPainter? paintTower(Tower? tower) {
  switch (tower) {
    case BasicTower():
      return BasicTowerPainter();
    case null:
      return null;
  }
}

abstract class TowerPainter extends GridCellPainter {}

class BasicTowerPainter extends TowerPainter {
  @override
  void paint(Canvas canvas, Size size, Offset offset) {
    throw UnimplementedError();
  }
}
