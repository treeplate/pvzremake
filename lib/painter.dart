import 'package:flutter/material.dart';

import 'floor.dart';
import 'grid_painter.dart';
import 'tower.dart';

TowerPainter? paintTower(Tower? tower) {
  switch (tower) {
    case BasicTower():
      return BasicTowerPainter();
    case null:
      return null;
  }
}

FloorPainter paintFloor(Floor floor) {
  switch (floor) {
    case BasicFloor():
      switch (floor.style) {
        case 0:
          return BasicFloor0Painter();
        default:
          throw UnimplementedError('style ${floor.style}');
      }
    case EmptyFloor():
      return EmptyFloorPainter();
  }
}

abstract class TowerPainter extends GridCellPainter {}

class BasicTowerPainter extends TowerPainter {
  @override
  void paint(Canvas canvas, Size size, Offset offset) {
    throw UnimplementedError();
  }
}

abstract class FloorPainter extends GridCellPainter {}

/// Classic floor.
class BasicFloor0Painter extends FloorPainter {
  @override
  void paint(Canvas canvas, Size size, Offset offset) {
    canvas.drawRect(offset & size, Paint()..color = Colors.green);
  }
}

class EmptyFloorPainter extends FloorPainter {
  @override
  void paint(Canvas canvas, Size size, Offset offset) {
    canvas.drawRect(offset & size, Paint()..color = Colors.brown);
  }
}
