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
      return LaneClearer0Painter();
    case LaneClearer():
      throw UnimplementedError('LaneClearer with style ${tower.style}');
    case BasicWall():
      return BasicWallPainter();
    case BasicCoinTower():
      return BasicCoinTowerPainter();
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
    case BasicEnemy(style: 1):
      return BasicEnemy1Painter();
    case BasicEnemy():
      throw UnimplementedError('BasicEnemy with style ${enemy.style}');
  }
}

ProjectilePainter paintProjectile(Projectile enemy) {
  switch (enemy) {
    case BasicProjectile():
      return BasicProjectilePainter();
    case LaneClearerProjectile(style: 0):
      return LaneClearer0Painter();
    case LaneClearerProjectile():
      throw UnimplementedError('LaneClearer with style ${enemy.style}');
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
  static BasicTowerPainter singleton = BasicTowerPainter._();

  BasicTowerPainter._();

  factory BasicTowerPainter() {
    return singleton;
  }

  @override
  String get name => "basic_tower";
}

class BasicWallPainter extends ImagePainter implements TowerPainter {
  static BasicWallPainter singleton = BasicWallPainter._();

  BasicWallPainter._();

  factory BasicWallPainter() {
    return singleton;
  }

  @override
  String get name => "basic_wall";
}

class LaneClearer0Painter extends ImagePainter
    implements TowerPainter, ProjectilePainter {
  static LaneClearer0Painter singleton = LaneClearer0Painter._();

  LaneClearer0Painter._();

  factory LaneClearer0Painter() {
    return singleton;
  }

  @override
  String get name => "lane_clearer";
}

class BasicCoinTowerPainter extends ImagePainter implements TowerPainter {
  static BasicCoinTowerPainter singleton = BasicCoinTowerPainter._();

  BasicCoinTowerPainter._();

  factory BasicCoinTowerPainter() {
    return singleton;
  }

  @override
  String get name => "basic_coin_tower";
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
  static BasicEnemy0Painter singleton = BasicEnemy0Painter._();

  BasicEnemy0Painter._();

  factory BasicEnemy0Painter() {
    return singleton;
  }

  @override
  String get name => "basic_enemy_0";
}

class BasicEnemy1Painter extends ImagePainter implements EnemyPainter {
  static BasicEnemy1Painter singleton = BasicEnemy1Painter._();

  BasicEnemy1Painter._();

  factory BasicEnemy1Painter() {
    return singleton;
  }

  @override
  String get name => "basic_enemy_1";
}

abstract class ProjectilePainter extends GridCellPainter {}

class BasicProjectilePainter extends ImagePainter implements ProjectilePainter {
  static BasicProjectilePainter singleton = BasicProjectilePainter._();

  BasicProjectilePainter._();

  factory BasicProjectilePainter() {
    return singleton;
  }

  @override
  String get name => "basic_projectile";
}

class CoinWidget extends StatelessWidget {
  const CoinWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.sunny,
      color: Colors.yellow,
    );
  }
}

Widget renderThing(
  Object? thing,
) {
  if (thing == null) {
    return SizedBox(
      width: cellDim,
      height: cellDim,
    );
  }
  if (thing is Enemy) {
    return GridCellWidget(paintEnemy(thing));
  }
  if (thing is Tower) {
    return GridCellWidget(paintTower(thing));
  }
  if (thing is Floor) {
    return GridCellWidget(paintFloor(thing));
  }
  if (thing is Widget) {
    return thing;
  }
  return Text(
    'unknown thing $thing',
    style: const TextStyle(color: Colors.red),
  );
}

Row parseInlinedIcons(({String text, List<Object?> objs}) args) {
  List<Widget> result = [];
  StringBuffer buffer = StringBuffer();
  bool parsingKey = false;
  for (int rune in args.text.runes) {
    if (parsingKey) {
      if (rune == 0x7D) {
        result.add(renderThing(args.objs[int.parse(buffer.toString())]));
        buffer = StringBuffer();
        parsingKey = false;
      } else {
        buffer.writeCharCode(rune);
      }
    } else {
      if (rune == 0x7B) {
        result.add(Text(
          buffer.toString(),
          style: const TextStyle(fontSize: 30, color: Colors.black),
        ));
        buffer = StringBuffer();
        parsingKey = true;
      } else {
        buffer.writeCharCode(rune);
      }
    }
  }
  if (parsingKey) {
    result.add(renderThing(args.objs[int.parse(buffer.toString())]));
  } else {
    result.add(Text(
      buffer.toString(),
      style: const TextStyle(fontSize: 30, color: Colors.black),
    ));
  }
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: result,
  );
}
