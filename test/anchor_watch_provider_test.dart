import 'package:flutter_test/flutter_test.dart';
import 'package:kipmarine/core/services/alarm_service.dart';
import 'package:kipmarine/features/anchor_watch/providers/anchor_watch_provider.dart';
import 'package:kipmarine/features/navigation/models/navigation_data.dart';

class _FakeAlarmService implements AnchorAlarmController {
  bool _isPlaying = false;
  int triggerCount = 0;

  @override
  bool get isPlaying => _isPlaying;

  @override
  Future<bool> prepareForMonitoring() async => true;

  @override
  Future<void> triggerAlarm() async {
    triggerCount++;
    _isPlaying = true;
  }

  @override
  Future<void> stopAlarm() async {
    _isPlaying = false;
  }
}

NavigationData _position({
  DateTime? timestamp,
  double latitude = 42.0,
  double longitude = 9.0,
}) {
  return NavigationData(
    latitude: latitude,
    longitude: longitude,
    speedInKnots: 0,
    speedMs: 0,
    heading: 0,
    headingIsValid: false,
    accuracy: 4,
    altitude: 0,
    timestamp: timestamp ?? DateTime.now(),
  );
}

void main() {
  late AnchorWatchProvider provider;
  late _FakeAlarmService alarmService;

  setUp(() {
    alarmService = _FakeAlarmService();
    provider = AnchorWatchProvider(alarmService: alarmService);
  });

  tearDown(() {
    provider.dispose();
  });

  test('does not activate anchor watch with a stale GPS position', () {
    final stalePosition = _position(
      timestamp: DateTime.now().subtract(const Duration(seconds: 20)),
    );

    provider.dropAnchor(stalePosition);

    expect(provider.config, isNull);
    expect(provider.isGpsLost, isFalse);
    expect(alarmService.triggerCount, 0);
  });

  test('triggers the drift alarm outside the radius and stops it on return', () {
    provider.dropAnchor(_position());
    provider.updatePosition(_position(latitude: 42.001));

    expect(provider.isAlarmTriggered, isTrue);
    expect(provider.config!.currentDistance, greaterThan(35));
    expect(alarmService.isPlaying, isTrue);
    expect(alarmService.triggerCount, 1);

    provider.updatePosition(_position());

    expect(provider.isAlarmTriggered, isFalse);
    expect(provider.config!.currentDistance, 0);
    expect(alarmService.isPlaying, isFalse);
  });

  test('reports GPS loss and clears it after a fresh fix returns', () {
    provider.dropAnchor(_position());
    expect(provider.config?.isActive, isTrue);
    expect(provider.isGpsLost, isFalse);

    provider.updatePosition(
      _position(
        timestamp: DateTime.now().subtract(const Duration(seconds: 20)),
        latitude: 42.001,
      ),
    );

    expect(provider.isGpsLost, isTrue);
    expect(provider.config?.currentDistance, 0);
    expect(alarmService.triggerCount, 1);

    provider.updatePosition(_position());

    expect(provider.isGpsLost, isFalse);
    expect(provider.config?.isActive, isTrue);
    expect(alarmService.isPlaying, isFalse);
  });
}
