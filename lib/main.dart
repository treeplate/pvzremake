import 'package:flutter/material.dart';
import 'package:pvzremake/tower.dart';
import 'floor.dart';
import 'grid_painter.dart';
import 'logic.dart';
import 'painter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Taawer Defens'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TowerArea towerArea = TowerArea(
    width: 10,
    height: 5,
    floors: List.generate(
      10 * 5,
      (index) => index % 10 == 0 ? NoFloor() : BasicFloor(0),
    ),
  );

  late List<TowerPainter?> towers =
      towerArea.towers.map((e) => paintTower(e)).toList();

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    towers = towerArea.towers.map((e) => paintTower(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Stack(
          children: [
            GridDrawer(
              towerArea.floors.map((e) => paintFloor(e)).toList(),
              towerArea.width,
              onTap: (x, y) {
                setState(() {
                  if (towerArea.towers[x + y * towerArea.width] == null) {
                    towerArea.towers[x + y * towerArea.width] = BasicTower();
                  }
                });
              },
            ),
            IgnorePointer(
              child: GridDrawer(towers, towerArea.width),
            )
          ],
        ),
      ),
    );
  }
}
