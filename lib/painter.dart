import 'dart:async';
import 'dart:ui' as ui show Image, decodeImageFromList;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  BasicTowerPainter() {
    loadUiImage('images/basic_tower.png').then((value) {
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
