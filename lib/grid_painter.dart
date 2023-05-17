import 'package:flutter/material.dart';

class GridDrawer extends StatelessWidget {
  const GridDrawer(this.grid, this.width, {Key? key}) : super(key: key);
  final List<GridCellPainter?> grid;
  final int width;
  int get height => grid.length ~/ width;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Stack(
        children: [
          Positioned(
              left: constraints.maxWidth / 2 + (-cellDim * width / 2),
              top: constraints.maxHeight / 2 + (-cellDim * height / 2),
              child: CustomPaint(
                painter: GridPainter(
                  width,
                  height,
                  grid,
                ),
              ))
        ],
      );
    });
  }
}

const double cellDim = 100;

class GridPainter extends CustomPainter {
  GridPainter(this.width, this.height, this.grid);
  final int width;
  final int height;
  final List<GridCellPainter?> grid;
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
  @override
  void paint(Canvas canvas, Size size) {
    Size cellSize = const Size(cellDim, cellDim);
    for (int y = 0; y < height; y += 1) {
      for (int x = 0; x < width; x += 1) {
        grid[x + (y * width)]
            ?.paint(canvas, cellSize, Offset(x * cellDim, y * cellDim));

        canvas.drawRect(
            Offset(x * cellDim, y * cellDim) & cellSize,
            Paint()
              ..color = Colors.black
              ..style = PaintingStyle.stroke);
      }
    }
  }
}

abstract class GridCellPainter {
  void paint(Canvas canvas, Size size, Offset offset);
}
