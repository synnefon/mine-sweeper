import 'package:flutter/foundation.dart';

@immutable
class Location {
  final int x;
  final int y;

  Location({required this.x, required this.y});

  @override
  bool operator ==(Object other) {
    if (other is! Location) return false;

    return other.x == x && other.y == y;
  }

  @override
  int get hashCode => "$x,$y".hashCode;
}
