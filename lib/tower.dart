sealed class Tower {
  double get health;
  set health(double h);
}

sealed class Projectile {
  double x;
  int y;
  int get damage;
  Projectile(this.y, this.x);
}

/// Shoots projectiles straight.
class BasicTower extends Tower {
  @override
  double health = 300;
  String toString() {
    return "basic tower";
  }
}

/// Does nothing.
class BasicWall extends Tower {
  @override
  double health = 4000;
  String toString() {
    return "basic wall";
  }
}

class BasicCoinTower extends Tower {
  @override
  double health = 300;
  String toString() {
    return "basic coin tower";
  }
}

class BasicProjectile extends Projectile {
  BasicProjectile(super.y, super.x);

  @override
  int get damage => 20;
}

/// Clears the lane of [Enemy]s.
/// Cannot be manually removed.
class LaneClearer extends Tower {
  final int style; // purely for decoration

  LaneClearer(this.style);

  @override
  double get health => 1;
  @override
  set health(double h) {
    throw StateError('LaneClearers cannot be damaged');
  }
}
