import 'package:flutter/material.dart';
import 'package:pvzremake/tower.dart';
import 'enemy.dart';
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

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  TowerArea towerArea = TowerArea(
    width: 10,
    height: 5,
    floors: List.generate(
      10 * 5,
      (index) => index % 10 == 0 ? NoFloor() : BasicFloor(0),
    ),
    hidingEnemies: [
      (BasicEnemy(0, 10, 0), 60 * 5),
      (BasicEnemy(1, 10, 0), 60 * 5),
      (BasicEnemy(2, 10, 0), 60 * 5),
      (BasicEnemy(3, 10, 0), 60 * 5),
      (BasicEnemy(4, 10, 0), 60 * 5),
      (BasicEnemy(0, 10, 0), 60 * 10),
    ],
  );

  late List<TowerPainter?> towers =
      towerArea.towers.map((e) => paintTower(e)).toList();

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    towers = towerArea.towers.map((e) => paintTower(e)).toList();
  }

  @override
  void initState() {
    super.initState();

    createTicker((Duration d) {
      setState(() {
        towerArea.tick();
      });
    }).start();
  }

  Tower? Function()? newTower;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("You have ${towerArea.money}"),
                  const CoinWidget(),
                ],
              ),
              TextButton(
                onPressed: () {
                  newTower = () {
                    if (towerArea.money >= 100) {
                      towerArea.money -= 100;
                      return BasicTower();
                    }
                    return null;
                  };
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GridCellWidget(BasicTowerPainter()),
                    const Text('100'),
                    const CoinWidget(),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  newTower = () {
                    if (towerArea.money >= 50) {
                      towerArea.money -= 50;
                      return BasicWall();
                    }
                    return null;
                  };
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GridCellWidget(BasicWallPainter()),
                    const Text('50'),
                    const CoinWidget(),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  newTower = () {
                    if (towerArea.money >= 50) {
                      towerArea.money -= 50;
                      return BasicCoinTower();
                    }
                    return null;
                  };
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GridCellWidget(BasicCoinTowerPainter()),
                    const Text('50'),
                    const CoinWidget(),
                  ],
                ),
              ),
            ],
          ),
          Center(
            child: GridDrawer(
              towerArea.floors.map((e) => paintFloor(e)).toList(),
              towerArea.width,
              onTap: (x, y) {
                setState(() {
                  if (towerArea.towers[x + y * towerArea.width] == null &&
                      newTower != null) {
                    towerArea.towers[x + y * towerArea.width] = newTower!();
                  }
                });
              },
            ),
          ),
          Center(
            child: IgnorePointer(
              child: GridDrawer(towers, towerArea.width),
            ),
          ),
          IgnorePointer(
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                children: towerArea.enemies
                    .map(
                      (e) => Positioned(
                        left: e.x * cellDim +
                            (constraints.maxWidth / 2 -
                                (cellDim * towerArea.width) / 2),
                        top: e.y * cellDim +
                            (constraints.maxHeight / 2 -
                                (cellDim *
                                        towerArea.towers.length /
                                        towerArea.width) /
                                    2),
                        child: GridCellWidget(paintEnemy(e)),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          IgnorePointer(
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                children: towerArea.projectiles
                    .map(
                      (e) => Positioned(
                        left: e.x * cellDim +
                            (constraints.maxWidth / 2 -
                                (cellDim * towerArea.width) / 2),
                        top: e.y * cellDim +
                            (constraints.maxHeight / 2 -
                                (cellDim *
                                        towerArea.towers.length /
                                        towerArea.width) /
                                    2),
                        child: GridCellWidget(paintProjectile(e)),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) => Stack(
              children: [
                for ((double, double) coin in towerArea.coins)
                  Positioned(
                    left: coin.$1 * cellDim +
                        (constraints.maxWidth / 2 -
                            (cellDim * towerArea.width) / 2),
                    top: coin.$2 * cellDim +
                        (constraints.maxHeight / 2 -
                            (cellDim *
                                    towerArea.towers.length /
                                    towerArea.width) /
                                2),
                    child: IconButton(
                      icon: const CoinWidget(),
                      onPressed: () {
                        towerArea.money += 50;
                        towerArea.coins.remove(coin);
                      },
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
