import 'package:flutter_test/flutter_test.dart';
import 'package:kipmarine/core/constants/marine_units.dart';

void main() {
  group('MarineUnits', () {
    test('converts metres per second to knots', () {
      expect(MarineUnits.msToKnots(0), 0);
      expect(MarineUnits.msToKnots(1), closeTo(1.94384, 1e-8));
    });

    test('converts metres to nautical miles', () {
      expect(MarineUnits.metersToNauticalMiles(0), 0);
      expect(MarineUnits.metersToNauticalMiles(1852), 1);
      expect(MarineUnits.metersToNauticalMiles(3704), 2);
    });

    test('returns zero distance for identical coordinates', () {
      expect(
        MarineUnits.haversineDistance(42.7, 9.45, 42.7, 9.45),
        closeTo(0, 1e-8),
      );
    });

    test('calculates about 111.2 km for one degree longitude at the equator', () {
      expect(
        MarineUnits.haversineDistance(0, 0, 0, 1),
        closeTo(111195, 100),
      );
    });

    test('distance is symmetric when the points are reversed', () {
      final forward = MarineUnits.haversineDistance(42.7, 9.45, 43.0, 9.8);
      final reverse = MarineUnits.haversineDistance(43.0, 9.8, 42.7, 9.45);

      expect(forward, greaterThan(0));
      expect(reverse, closeTo(forward, 1e-6));
    });
  });
}
