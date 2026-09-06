import 'package:characters/characters.dart';

class UrduUnit {
  final String display;
  final String normalized;
  final String comparisonKey;

  UrduUnit({
    required this.display,
    required this.normalized,
    required this.comparisonKey,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UrduUnit && other.comparisonKey == comparisonKey;
  }

  @override
  int get hashCode => comparisonKey.hashCode;
}

class UrduWord {
  final String original;
  final List<UrduUnit> units;

  UrduWord({
    required this.original,
    required this.units,
  });

  int get length => units.length;
}
