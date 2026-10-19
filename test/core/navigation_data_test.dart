import 'package:flutter_test/flutter_test.dart';
import 'package:kipmarine/features/navigation/models/navigation_data.dart';

NavigationData _data({
  double speedMs = 2,
  double? heading = 90,
  double accuracy = 5,
}) {
  return NavigationData(
    latitude: 42.7,
    longitude: 9.4,
    speedInKnots: speedMs * 1.94384,
    speedMs: speedMs,
    heading: heading,
    accuracy: accuracy,
    altitude: 0,
    timestamp: DateTime.utc(2026, 10, 19),
  );
}

void main() {
  group('NavigationData', () {
    test('accepts a valid GPS course while moving', () {
      expect(_data().hasValidCourse, isTrue);
    });

    test('does not treat a stationary heading as COG', () {
      expect(_data(speedMs: 0).hasValidCourse, isFalse);
    });

    test('rejects a missing heading or inaccurate GPS course', () {
      expect(_data(heading: null).hasValidCourse, isFalse);
      expect(_data(accuracy: 30).hasValidCourse, isFalse);
    });

    test('classifies GPS accuracy', () {
      expect(_data(accuracy: 3).signalStatus, GpsSignalStatus.excellent);
      expect(_data(accuracy: 8).signalStatus, GpsSignalStatus.good);
      expect(_data(accuracy: 15).signalStatus, GpsSignalStatus.fair);
      expect(_data(accuracy: 35).signalStatus, GpsSignalStatus.poor);
      expect(_data(accuracy: 0).signalStatus, GpsSignalStatus.lost);
    });
  });
}
