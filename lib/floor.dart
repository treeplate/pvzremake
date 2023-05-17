sealed class Floor {}

class BasicFloor extends Floor {
  final int style; // purely for decoration

  BasicFloor(this.style);
}

/// no [Tower]s can be placed, don't put [Enemy]s on this lane
class EmptyFloor extends Floor {}

/// same as [EmptyFloor] apart from decoration - a [LaneClearer] should start here
class NoFloor extends Floor {}
