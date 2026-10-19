import 'package:flutter_test/flutter_test.dart';
import 'package:kipmarine/features/navigation/models/navigation_data.dart';

NavigationData _data({
  DateTime? timestamp,
  double latitude = 42.0,
  double longitude = 9.0,
  double speedInKnots = 3.0,
  double heading = 90.0,
  bool headingIsValid = true,
  double accuracy = 4.0,
}) {
  return NavigationData(
    latitude: latitude,
    longitude: longitude,
    speedInKnots: speedInKnots,
    speedMs: 1.5,
    heading: heading,
    headingIsValid: headingIsValid,
    accuracy: accuracy,
    altitude: 0,
    timestamp: timestamp ?? DateTime.now(),
  );
}

void main() {
  group('NavigationData', () {
    test('considers a recent valid fix fresh', () {
      expect(_data().hasFreshPosition, isTrue);
    });

    test('rejects a stale fix and reports GPS lost', () {
      final data = _data(
        timestamp: DateTime.now().subtract(const Duration(seconds: 20)),
      );

      expect(data.hasFreshPosition, isFalse);
      expect(data.hasValidCourse, isFalse);
      expect(data.signalStatus, GpsSignalStatus.lost);
    });

    test('rejects coordinates outside geographic bounds', () {
      final data = _data(latitude: 95);

      expect(data.hasFreshPosition, isFalse);
      expect(data.signalStatus, GpsSignalStatus.lost);
    });

    test('accepts course only when moving and heading is valid', () {
      expect(_data(speedInKnots: 2, heading: 359.9).hasValidCourse, isTrue);
      expect(_data(speedInKnots: 0.1).hasValidCourse, isFalse);
      expect(_data(headingIsValid: false).hasValidCourse, isFalse);
    });

    test('classifies fresh GPS accuracy', () {
      expect(_data(accuracy: 4).signalStatus, GpsSignalStatus.excellent);
      expect(_data(accuracy: 8).signalStatus, GpsSignalStatus.good);
      expect(_data(accuracy: 15).signalStatus, GpsSignalStatus.fair);
      expect(_data(accuracy: 30).signalStatus, GpsSignalStatus.poor);
    });
  });
}
