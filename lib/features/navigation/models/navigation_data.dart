import 'package:geolocator/geolocator.dart';
import '../../../core/constants/marine_units.dart';

enum GpsSignalStatus { excellent, good, fair, poor, lost }

class NavigationData {
  final double latitude;
  final double longitude;
  final double speedInKnots;
  final double speedMs;

  /// Cap GPS sur le fond, en degrés, ou null si indisponible.
  final double? heading;

  final double accuracy;
  final double altitude;
  final DateTime timestamp;

  NavigationData({
    required this.latitude,
    required this.longitude,
    required this.speedInKnots,
    required this.speedMs,
    required this.heading,
    required this.accuracy,
    required this.altitude,
    required this.timestamp,
  });

  factory NavigationData.fromPosition(Position position) {
    final rawSpeed = position.speed.isFinite && position.speed >= 0
        ? position.speed
        : 0.0;

    final rawHeading = position.heading;
    final validHeading = rawHeading.isFinite &&
            rawHeading >= 0 &&
            rawHeading < 360
        ? rawHeading
        : null;

    return NavigationData(
      latitude: position.latitude,
      longitude: position.longitude,
      speedInKnots: MarineUnits.msToKnots(rawSpeed),
      speedMs: rawSpeed,
      heading: validHeading,
      accuracy: position.accuracy,
      altitude: position.altitude,
      timestamp: position.timestamp,
    );
  }

  /// Le COG est exploitable si le bateau avance
  /// et si la précision GPS est suffisante.
  bool get hasValidCourse =>
      speedMs >= 0.5 &&
      accuracy.isFinite &&
      accuracy > 0 &&
      accuracy <= 25 &&
      heading != null &&
      heading!.isFinite &&
      heading! >= 0 &&
      heading! < 360;

  GpsSignalStatus get signalStatus {
    if (!accuracy.isFinite || accuracy <= 0) {
      return GpsSignalStatus.lost;
    }
    if (accuracy <= 5) return GpsSignalStatus.excellent;
    if (accuracy <= 10) return GpsSignalStatus.good;
    if (accuracy <= 20) return GpsSignalStatus.fair;
    return GpsSignalStatus.poor;
  }
}
