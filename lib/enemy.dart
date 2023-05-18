sealed class Enemy {
  double x;
  int y;

  double speed(int millisecondsPerTick);
  Enemy(this.y, int width) : x = width.toDouble();
}

class BasicEnemy extends Enemy {
  final int style; // purely for decoration
  BasicEnemy(super.y, super.width, this.style);

  @override
  double speed(int millisecondsPerTick) => 0.0002142704 / millisecondsPerTick;
}
