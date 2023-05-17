import 'package:flutter/material.dart';
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
    width: 9,
    height: 5,
    floors: List.generate(
      9 * 5,
      (index) => BasicFloor(0),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          GridDrawer(towerArea.floors.map((e) => paintFloor(e)).toList(),
              towerArea.width),
          GridDrawer(towerArea.towers.map((e) => paintTower(e)).toList(),
              towerArea.width)
        ],
      ),
    );
  }
}
