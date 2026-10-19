import 'package:geolocator/geolocator.dart';
import '../../../core/constants/marine_units.dart';

/// Le COG n'est exploitable que si le bateau se déplace
/// suffisamment et si la précision GPS est acceptable.
bool get hasValidCourse =>
    speedMs >= 0.5 &&
    accuracy > 0 &&
    accuracy <= 25 &&
    heading.isFinite &&
    heading >= 0 &&
    heading < 360;

enum GpsSignalStatus { excellent, good, fair, poor, lost }

class NavigationData {
  final double latitude;
  final double longitude;
  final double speedInKnots; // SOG (Speed Over Ground) en Nœuds
  final double speedMs;      // Vitesse brute en m/s
  final double heading;      // COG (Course Over Ground) en Degrés [0-360]
  final double accuracy;     // Précision GPS en mètres
  final double altitude;     // Altitude en mètres
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

  /// Factory pour convertir une Position issue du package geolocator
  factory NavigationData.fromPosition(Position position) {
    // S'assure que la vitesse n'est pas négative (bruit GPS)
    final rawSpeed = position.speed < 0 ? 0.0 : position.speed;

    return NavigationData(
      latitude: position.latitude,
      longitude: position.longitude,
      speedInKnots: MarineUnits.msToKnots(rawSpeed),
      speedMs: rawSpeed,
      heading: position.heading.isFinite &&
        position.heading >= 0 &&
        position.heading < 360
    ? position.heading
    : 0.0,
      accuracy: position.accuracy,
      altitude: position.altitude,
      timestamp: position.timestamp,
    );
  }

  /// Qualité du signal GPS basée sur la précision en mètres
  GpsSignalStatus get signalStatus {
    if (accuracy <= 5) return GpsSignalStatus.excellent;
    if (accuracy <= 10) return GpsSignalStatus.good;
    if (accuracy <= 20) return GpsSignalStatus.fair;
    return GpsSignalStatus.poor;
  }
}
