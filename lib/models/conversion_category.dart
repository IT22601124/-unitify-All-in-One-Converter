import 'conversion_unit.dart';

enum ConversionKind { linear, temperature, fuel }

class ConversionCategory {
  const ConversionCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.iconKey,
    required this.colorValue,
    required this.units,
    this.kind = ConversionKind.linear,
    this.allowNegative = false,
  });

  final String id;
  final String name;
  final String description;
  final String iconKey;
  final int colorValue;
  final List<ConversionUnit> units;
  final ConversionKind kind;
  final bool allowNegative;

  ConversionUnit unit(String id) => units.firstWhere((unit) => unit.id == id);
}
