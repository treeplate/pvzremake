sealed class Floor {}

class BasicFloor extends Floor {
  final int style; // purely for decoration

  BasicFloor(this.style);
}

class EmptyFloor extends Floor {}
