import '../models/conversion_category.dart';
import '../models/conversion_unit.dart';

class ConversionResult {
  const ConversionResult._(this.value, this.error);

  final double? value;
  final String? error;
  bool get isValid => value != null && error == null;

  factory ConversionResult.success(double value) =>
      ConversionResult._(value, null);
  factory ConversionResult.failure(String error) =>
      ConversionResult._(null, error);
}

class ConversionService {
  const ConversionService();

  ConversionResult convert({
    required ConversionCategory category,
    required ConversionUnit from,
    required ConversionUnit to,
    required double value,
  }) {
    if (!value.isFinite) {
      return ConversionResult.failure('Enter a finite number');
    }
    if (!category.allowNegative && value < 0) {
      return ConversionResult.failure('${category.name} cannot be negative');
    }

    double result;
    switch (category.kind) {
      case ConversionKind.linear:
        result = value * from.toBaseFactor / to.toBaseFactor;
      case ConversionKind.temperature:
        final kelvin = _toKelvin(value, from.id);
        if (kelvin < 0) {
          return ConversionResult.failure(
            'Temperature cannot be below absolute zero',
          );
        }
        result = _fromKelvin(kelvin, to.id);
      case ConversionKind.fuel:
        if (value <= 0 && from.id != to.id) {
          return ConversionResult.failure(
            'Use a value greater than zero for fuel conversions',
          );
        }
        result = _convertFuel(value, from.id, to.id);
    }
    if (!result.isFinite || result.isNaN) {
      return ConversionResult.failure(
        'This value is outside the supported range',
      );
    }
    return ConversionResult.success(result);
  }

  double _toKelvin(double value, String unit) => switch (unit) {
    'c' => value + 273.15,
    'f' => (value - 32) * 5 / 9 + 273.15,
    _ => value,
  };

  double _fromKelvin(double kelvin, String unit) => switch (unit) {
    'c' => kelvin - 273.15,
    'f' => (kelvin - 273.15) * 9 / 5 + 32,
    _ => kelvin,
  };

  double _convertFuel(double value, String from, String to) {
    if (from == to) return value;
    final litersPer100Km = switch (from) {
      'l100km' => value,
      'kml' => 100 / value,
      'usmpg' => 235.214583 / value,
      'impg' => 282.480936 / value,
      _ => value,
    };
    return switch (to) {
      'l100km' => litersPer100Km,
      'kml' => 100 / litersPer100Km,
      'usmpg' => 235.214583 / litersPer100Km,
      'impg' => 282.480936 / litersPer100Km,
      _ => litersPer100Km,
    };
  }

  String formula(
    ConversionCategory category,
    ConversionUnit from,
    ConversionUnit to,
  ) {
    if (from.id == to.id) return 'The source and target units are identical.';
    if (category.kind == ConversionKind.temperature) {
      return 'Temperature conversion uses an offset and scale through Kelvin.';
    }
    if (category.kind == ConversionKind.fuel) {
      return 'Fuel economy units use reciprocal distance-per-volume formulas.';
    }
    final ratio = from.toBaseFactor / to.toBaseFactor;
    return 'Multiply ${from.symbol} by ${_compact(ratio)} to get ${to.symbol}.';
  }

  String _compact(double value) =>
      value.toStringAsPrecision(8).replaceFirst(RegExp(r'\.?0+$'), '');
}
