import 'package:flutter_test/flutter_test.dart';
import 'package:unitify/core/constants/conversion_catalog.dart';
import 'package:unitify/services/conversion_service.dart';

void main() {
  const service = ConversionService();

  double convert(String categoryId, String fromId, String toId, double value) {
    final category = categoryById(categoryId);
    return service
        .convert(
          category: category,
          from: category.unit(fromId),
          to: category.unit(toId),
          value: value,
        )
        .value!;
  }

  group('linear conversions', () {
    test(
      'kilometers to meters',
      () => expect(convert('length', 'km', 'm', 1), 1000),
    );
    test(
      'inches to centimeters',
      () => expect(convert('length', 'in', 'cm', 1), closeTo(2.54, 1e-12)),
    );
    test(
      'kilograms to pounds',
      () =>
          expect(convert('mass', 'kg', 'lb', 1), closeTo(2.2046226218, 1e-10)),
    );
    test(
      'US gallon to liters',
      () => expect(
        convert('volume', 'us_gal', 'l', 1),
        closeTo(3.785411784, 1e-12),
      ),
    );
    test(
      'GiB to bytes',
      () => expect(convert('data', 'gib', 'byte', 1), 1073741824),
    );
    test(
      'hour to seconds',
      () => expect(convert('time', 'hr', 'sec', 1), 3600),
    );
  });

  group('temperature conversions', () {
    test(
      'freezing point',
      () => expect(convert('temperature', 'c', 'f', 0), closeTo(32, 1e-12)),
    );
    test(
      'boiling point',
      () => expect(convert('temperature', 'c', 'f', 100), closeTo(212, 1e-12)),
    );
    test(
      'Celsius to Kelvin',
      () => expect(convert('temperature', 'c', 'k', 0), closeTo(273.15, 1e-12)),
    );
    test('rejects below absolute zero', () {
      final category = categoryById('temperature');
      final result = service.convert(
        category: category,
        from: category.unit('c'),
        to: category.unit('k'),
        value: -273.151,
      );
      expect(result.isValid, isFalse);
      expect(result.error, contains('absolute zero'));
    });
  });

  group('edge cases and inverse conversions', () {
    test('round trip retains precision', () {
      final miles = convert('length', 'km', 'mi', 123.456);
      expect(convert('length', 'mi', 'km', miles), closeTo(123.456, 1e-10));
    });
    test(
      'fuel reciprocal conversion',
      () => expect(
        convert('fuel', 'l100km', 'usmpg', 8),
        closeTo(29.401822875, 1e-9),
      ),
    );
    test('fuel zero is handled safely', () {
      final category = categoryById('fuel');
      final result = service.convert(
        category: category,
        from: category.unit('l100km'),
        to: category.unit('usmpg'),
        value: 0,
      );
      expect(result.isValid, isFalse);
    });
    test('negative physical quantity is rejected', () {
      final category = categoryById('mass');
      expect(
        service
            .convert(
              category: category,
              from: category.unit('kg'),
              to: category.unit('lb'),
              value: -1,
            )
            .isValid,
        isFalse,
      );
    });
  });
}
