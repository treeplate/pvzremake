sealed class Enemy {
  double x;
  int y;
  int get health;
  set health(int h);

  double speed(int millisecondsPerTick);
  Enemy(this.y, int width) : x = width.toDouble();
}

class BasicEnemy extends Enemy {
  final int style; // purely for decoration
  BasicEnemy(super.y, super.width, this.style);

  @override
  String toString() => 'basic on lane $y x $x style $style';

  @override
  double speed(int millisecondsPerTick) =>
      ((1 / 5) / 1000) * millisecondsPerTick;

  @override
  int health = 190;
}
