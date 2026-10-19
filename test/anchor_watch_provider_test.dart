import 'package:flutter_test/flutter_test.dart';
import 'package:kipmarine/features/anchor_watch/providers/anchor_watch_provider.dart';
import 'package:kipmarine/features/navigation/models/navigation_data.dart';

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
  TestWidgetsFlutterBinding.ensureInitialized();

  late AnchorWatchProvider provider;

  setUp(() {
    provider = AnchorWatchProvider();
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

    provider.updatePosition(_position());

    expect(provider.isGpsLost, isFalse);
    expect(provider.config?.isActive, isTrue);
  });
}
