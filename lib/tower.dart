sealed class Tower {}

/// Shoots projectiles straight.
class BasicTower extends Tower {}

/// Clears the lane of [Enemy]s.
/// Cannot be manually removed.
class LaneClearer extends Tower {
  final int style;

  LaneClearer(this.style);
}
