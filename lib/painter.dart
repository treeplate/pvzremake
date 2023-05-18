import 'dart:async';
import 'dart:ui' as ui show Image, decodeImageFromList;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'enemy.dart';
import 'floor.dart';
import 'grid_painter.dart';
import 'tower.dart';

Future<ui.Image> loadUiImage(String imageAssetPath) async {
  final ByteData data = await rootBundle.load(imageAssetPath);
  final Completer<ui.Image> completer = Completer();
  ui.decodeImageFromList(Uint8List.view(data.buffer), (ui.Image img) {
    return completer.complete(img);
  });
  return completer.future;
}

TowerPainter? paintTower(Tower? tower) {
  switch (tower) {
    case BasicTower():
      return BasicTowerPainter();
    case null:
      return null;
    case LaneClearer(style: 0):
      return LaneClearerPainter();
    case LaneClearer():
      throw UnimplementedError('LaneClearer with style ${tower.style}');
  }
}

FloorPainter? paintFloor(Floor floor) {
  switch (floor) {
    case BasicFloor(style: 0):
      return BasicFloor0Painter();
    case EmptyFloor():
      return EmptyFloorPainter();
    case NoFloor():
      return null;
    case BasicFloor():
      throw UnimplementedError('BasicFloor with style ${floor.style}');
  }
}

EnemyPainter paintEnemy(Enemy enemy) {
  switch (enemy) {
    case BasicEnemy(style: 0):
      return BasicEnemy0Painter();
    case BasicEnemy():
      throw UnimplementedError('BasicEnemy with style ${enemy.style}');
  }
}

abstract class TowerPainter extends GridCellPainter {}

abstract class ImagePainter extends GridCellPainter {
  String get name;

  ImagePainter() {
    loadUiImage('images/$name.png').then((value) {
      towerImage = value;
      inited = true;
    });
  }
  late final ui.Image towerImage;
  bool inited = false;
  @override
  void paint(Canvas canvas, Size size, Offset offset) async {
    if (!inited) {
      canvas.drawOval(offset & size, Paint()..style = PaintingStyle.stroke);
    } else {
      paintImage(
          canvas: canvas,
          rect: offset & size,
          image: towerImage,
          scale: 16 / cellDim,
          filterQuality: FilterQuality.none);
    }
  }
}

class BasicTowerPainter extends ImagePainter implements TowerPainter {
  @override
  String get name => "basic_tower";
}

class LaneClearerPainter extends ImagePainter implements TowerPainter {
  @override
  String get name => "lane_clearer";
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

abstract class EnemyPainter extends GridCellPainter {}

class BasicEnemy0Painter extends ImagePainter implements EnemyPainter {
  @override
  String get name => "basic_enemy_0";
}
