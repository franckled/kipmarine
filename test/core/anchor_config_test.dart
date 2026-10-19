import 'package:flutter_test/flutter_test.dart';
import 'package:kipmarine/features/anchor_watch/models/anchor_config.dart';

void main() {
  group('AnchorConfig', () {
    test('round-trips the active anchor configuration', () {
      final original = AnchorConfig(
        anchorLatitude: 42.681,
        anchorLongitude: 9.304,
        radiusMeters: 42,
        isActive: true,
        currentDistance: 18.5,
        isAlarmTriggered: true,
      );

      final restored = AnchorConfig.fromJson(original.toJson());

      expect(restored.anchorLatitude, closeTo(42.681, 1e-9));
      expect(restored.anchorLongitude, closeTo(9.304, 1e-9));
      expect(restored.radiusMeters, 42);
      expect(restored.isActive, isTrue);
      expect(restored.currentDistance, 18.5);
      expect(restored.isAlarmTriggered, isTrue);
    });

    test('restores defaults for optional legacy fields', () {
      final restored = AnchorConfig.fromJson({
        'anchorLatitude': 42.0,
        'anchorLongitude': 9.0,
        'radiusMeters': 35.0,
      });

      expect(restored.isActive, isFalse);
      expect(restored.currentDistance, 0);
      expect(restored.isAlarmTriggered, isFalse);
    });
  });
}
