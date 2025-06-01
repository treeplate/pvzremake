import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
      theme: ThemeData.dark(
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

class Level {
  final int? height;
  final List<Tower?>? towers;
  final int width;
  final List<(Enemy, int)> hidingEnemies;
  final List<Floor> floors;

  factory Level.noFirstColumn(int height, int width,
      List<(Enemy, int)> hidingEnemies, Floor Function(int) genFloor) {
    return Level(
      height,
      width,
      hidingEnemies,
      List.generate(
        width * height,
        (index) => index % width == 0 ? NoFloor() : genFloor(index),
      ),
    );
  }

  factory Level.floorsByRow(int height, int width,
          List<(Enemy, int)> hidingEnemies, Floor Function(int) genFloor) =>
      Level.noFirstColumn(
        height,
        width,
        hidingEnemies,
        (index) => genFloor(index ~/ width),
      );

  TowerArea startLevel() {
    return TowerArea(
      width: width,
      height: height,
      floors: floors,
      hidingEnemies: hidingEnemies,
      towers: towers,
    );
  }

  const Level(this.height, this.width, this.hidingEnemies, this.floors,
      {this.towers});
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  List<Level> levels = [
    Level.floorsByRow(
      5,
      10,
      [
        (BasicEnemy(2, 10, 0), 60 * 3),
        (BasicEnemy(2, 10, 0), 60 * 10),
        (BasicEnemy(2, 10, 0), 60 * 13),
        (BasicEnemy(2, 10, 1), 60 * 24),
        (BasicEnemy(2, 10, 0), 60 * 27),
        (BasicEnemy(2, 10, 0), 60 * 31),
        (BasicEnemy(2, 10, 0), 60 * 35),
      ],
      (index) => index != 2 ? EmptyFloor() : BasicFloor(0),
    ),
    Level(
      null,
      10,
      [
        (BasicEnemy(2, 10, 0), 60 * 5),
        (BasicEnemy(2, 10, 0), 60 * 12),
        (BasicEnemy(1, 10, 0), 60 * 13),
        (BasicEnemy(3, 10, 0), 60 * 30),
        (BasicEnemy(1, 10, 0), 60 * 60),
        (BasicEnemy(2, 10, 0), 60 * 60),
        (BasicEnemy(3, 10, 0), 60 * 60),
        (BasicEnemy(1, 10, 1), 60 * 60),
      ],
      List.generate(
        10 * 5,
        (index) => index % 10 == 0
            ? NoFloor()
            : (index ~/ 10 >= 1 && index ~/ 10 <= 3)
                ? BasicFloor(0)
                : EmptyFloor(),
      ),
      towers: List.generate(
        10 * 5,
        (index) => index % 10 == 0
            ? LaneClearer(0)
            : index == 24
                ? BasicTower()
                : null,
      ),
    ),
    Level(
      null,
      10,
      [
        (BasicEnemy(2, 10, 0), 60 * 5), // placeholder
      ],
      List.generate(
        10 * 5,
        (index) => index % 10 == 0 ? NoFloor() : BasicFloor(0),
      ),
      towers: List.generate(
        10 * 5,
        (index) => index % 10 == 0
            ? LaneClearer(0)
            : index == 24 // placeholder index
                ? BasicWall()
                : null,
      ),
    )
  ];
  int index = 0;
  int tutorialProgress = 0;
  List<({String text, List<Object?> objs})> tutorialMessages = [
    (
      text: 'Press the {0} to select that for placing.',
      objs: [BasicTower()],
    ),
    (
      text: 'Now press a {1} to place your {0}.',
      objs: [BasicTower(), BasicFloor(0)],
    ),
    (
      text: 'Now, once it appears, press the {0} to help fund your {1}.',
      objs: [const CoinWidget(), BasicTower()],
    ),
    (
      text:
          'Continue until the {0} indicator registers 100 {0}. This is equivalent to two falling {0}s.',
      objs: [const CoinWidget()],
    ),
    (
      text: 'Perfect, now place another {0}.',
      objs: [BasicTower()],
    ),
    (
      text:
          'The {0}s will help defend against the {1}s and {2}s. You can continue placing them.',
      objs: [BasicTower(), BasicEnemy(0, 0, 0), BasicEnemy(0, 0, 1)],
    ), // 5
    (
      text: 'You unlocked {0}! {0}s make {1}. Place a {0}.',
      objs: [BasicCoinTower(), const CoinWidget()],
    ),
    (
      text: 'Place another {0}.',
      objs: [BasicCoinTower()],
    ),
    (
      text: 'Place at least one {0} per row.',
      objs: [BasicCoinTower()],
    ),
    (
      text: '',
      objs: [],
    ),
    (
      text: '{0}s are very strong and will last for longer than {1}s and {2}s.',
      objs: [BasicWall(), BasicCoinTower(), BasicTower()],
    ),
  ];
  late TowerArea towerArea = levels[index].startLevel()
    ..tickEnemies = false
    ..money = 100;

  late List<TowerPainter?> towers =
      towerArea.towers.map((e) => paintTower(e)).toList();

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    towers = towerArea.towers.map((e) => paintTower(e)).toList();
  }

  static const Set<int> pausedTutorials = {0, 1};

  Duration previousDuration = Duration.zero;
  double frameRate = double.nan;
  late final Ticker ticker;

  @override
  void initState() {
    super.initState();

    ticker = createTicker((Duration d) {
      frameRate = 1 / ((d - previousDuration).inMicroseconds / 1000000);
      previousDuration = d;
      setState(() {
        if (!(pausedTutorials.contains(tutorialProgress))) {
          towerArea.tick();
          if (towerArea.hidingEnemies.isEmpty && towerArea.enemies.isEmpty) {
            index++;
            if (index >= levels.length) {
              showDialog(context: context, builder: (context) {
                return AlertDialog(
                  title: const Text('Tutorial Complete'),
                  content: const Text('You have completed the tutorial!'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              });
              ticker.stop();
              return;
            }
            towerArea = levels[index].startLevel()..money = 50;
            tutorialProgress++;
            if (tutorialProgress == 6) {
              towerArea.tickEnemies = false;
            }
          }
        }
      });
    })..start();
  }

  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  Tower? Function()? newTower;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size(1000, 1000),
          child: parseInlinedIcons(tutorialMessages[tutorialProgress])),
      bottomNavigationBar: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${frameRate.isFinite ? frameRate.round() : frameRate} fps",
              style: const TextStyle(color: Colors.white),
            )
          ]),
      body: FittedBox(
        child: SizedBox(
          width: 400 + cellDim * towerArea.width,
          height: cellDim * towerArea.width,
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "You have ${towerArea.money}",
                        style: const TextStyle(color: Colors.white),
                      ),
                      const CoinWidget(),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      if (tutorialProgress == 0) tutorialProgress = 1;
                      newTower = () {
                        if (towerArea.money >= 100) {
                          towerArea.money -= 100;
                          if (tutorialProgress < 5) {
                            tutorialProgress++;
                            if (tutorialProgress == 5) {
                              towerArea.tickEnemies = true;
                            }
                          }
                          return BasicTower();
                        }
                        return null;
                      };
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GridCellWidget(BasicTowerPainter()),
                        const Text(
                          '100',
                          style: TextStyle(color: Colors.white),
                        ),
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
                        const Text(
                          '50',
                          style: TextStyle(color: Colors.white),
                        ),
                        const CoinWidget(),
                      ],
                    ),
                  ),
                  if (tutorialProgress > 5)
                    TextButton(
                      onPressed: () {
                        newTower = () {
                          if (towerArea.money >= 50) {
                            towerArea.money -= 50;
                            if (tutorialProgress < 9) {
                              tutorialProgress++;
                              if (tutorialProgress == 9) {
                                towerArea.tickEnemies = true;
                              }
                            }
                            return BasicCoinTower();
                          }
                          return null;
                        };
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GridCellWidget(BasicCoinTowerPainter()),
                          const Text(
                            '50',
                            style: TextStyle(color: Colors.white),
                          ),
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
                          newTower != null &&
                          towerArea.floors[x + y * towerArea.width]
                              is BasicFloor) {
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
                    children: [
                      ...towerArea.enemies
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
                      ...towerArea.projectiles
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
                    ],
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
                            if (tutorialProgress == 3) {
                              tutorialProgress = 4;
                            }
                            if (tutorialProgress == 2) {
                              tutorialProgress = 3;
                            }
                            towerArea.money += 50;
                            towerArea.coins.remove(coin);
                          },
                        ),
                      ),
                    Positioned(
                      left: (constraints.maxWidth / 2 -
                          ((cellDim + 10) * towerArea.width) / 2),
                      top: (towerArea.towers.length / towerArea.width) *
                              (cellDim + 10) +
                          (constraints.maxHeight / 2 -
                              ((cellDim + 10) *
                                      towerArea.towers.length /
                                      towerArea.width) /
                                  2),
                      child: IconButton(
                        icon: const Icon(Icons.fullscreen),
                        onPressed: () {
                          cellDim += 10;
                        },
                      ),
                    ),
                    Positioned(
                      left: (constraints.maxWidth / 2 -
                          ((cellDim) * towerArea.width) / 2),
                      top: (towerArea.towers.length / towerArea.width) *
                              (cellDim) +
                          (constraints.maxHeight / 2 -
                              ((cellDim) *
                                      towerArea.towers.length /
                                      towerArea.width) /
                                  2),
                      child: IconButton(
                        icon: const Icon(Icons.fullscreen_exit),
                        onPressed: () {
                          cellDim -= 10;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
