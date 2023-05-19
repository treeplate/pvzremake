import 'package:flutter/material.dart';

class GridDrawer extends StatelessWidget {
  const GridDrawer(this.grid, this.width, {Key? key, this.onTap})
      : super(key: key);
  final List<GridCellPainter?> grid;
  final int width;
  int get height => grid.length ~/ width;
  final void Function(int x, int y)? onTap;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return GestureDetector(
        onTapDown: (TapDownDetails details) {
          Offset position = details.localPosition;
          int x = (position.dx / cellDim).floor();
          int y = (position.dy / cellDim).floor();
          if (onTap != null) onTap!(x, y);
        },
        child: CustomPaint(
          size: Size(width * cellDim, height * cellDim),
          painter: GridPainter(
            width,
            height,
            grid,
          ),
        ),
      );
    });
  }
}

double cellDim = 30;

class GridPainter extends CustomPainter {
  GridPainter(this.width, this.height, this.grid);
  final int width;
  final int height;
  final List<GridCellPainter?> grid;
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
  @override
  void paint(Canvas canvas, Size size) async {
    Size cellSize = Size(cellDim, cellDim);
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

class GridCellWidget extends StatelessWidget {
  const GridCellWidget(this.cell, {Key? key}) : super(key: key);
  final GridCellPainter? cell;
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(cellDim, cellDim),
      painter: GridCellCustomPainter(
        cell,
      ),
    );
  }
}

class GridCellCustomPainter extends CustomPainter {
  GridCellCustomPainter(this.cell);
  final GridCellPainter? cell;
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
  @override
  void paint(Canvas canvas, Size size) async {
    Size cellSize = Size(cellDim, cellDim);
    cell?.paint(canvas, cellSize, Offset.zero);
  }
}

abstract class GridCellPainter {
  void paint(Canvas canvas, Size size, Offset offset);
}
