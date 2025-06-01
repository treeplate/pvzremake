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

/// When this enemy's health goes to 0, it turns into a [BasicEnemy]. Instakills still kill it like other enemies.
class BasicArmoredEnemy extends Enemy {
  final int style; // purely for decoration (style 1 is reserved)
  BasicArmoredEnemy(super.y, super.width, this.style);

  @override
  String toString() => 'basicarmor on lane $y x $x style $style';

  @override
  double speed(int millisecondsPerTick) =>
      ((1 / 5) / 1000) * millisecondsPerTick;

  @override
  int health = 370;
}

/// When this enemy's health goes to 0, it turns into a [BasicArmoredEnemy]. Instakills still kill it like other enemies.
class StrongArmoredEnemy extends Enemy {
  final int style; // purely for decoration (style 1 is reserved)
  StrongArmoredEnemy(super.y, super.width, this.style);

  @override
  String toString() => 'strongarmor on lane $y x $x style $style';

  @override
  double speed(int millisecondsPerTick) =>
      ((1 / 5) / 1000) * millisecondsPerTick;

  @override
  int health = 730;
}
