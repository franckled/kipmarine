import 'package:geolocator/geolocator.dart';
import '../../../core/constants/marine_units.dart';

enum GpsSignalStatus { excellent, good, fair, poor, lost }

class NavigationData {
  final double latitude;
  final double longitude;
  final double speedInKnots; // SOG en nœuds
  final double speedMs; // Vitesse brute en m/s
  final double heading; // COG en degrés [0-360]
  final bool headingIsValid;
  final double accuracy; // Précision GPS en mètres
  final double altitude; // Altitude en mètres
  final DateTime timestamp;

  NavigationData({
    required this.latitude,
    required this.longitude,
    required this.speedInKnots,
    required this.speedMs,
    required this.heading,
    this.headingIsValid = true,
    required this.accuracy,
    required this.altitude,
    required this.timestamp,
  });

  factory NavigationData.fromPosition(Position position) {
    final rawSpeed =
        position.speed.isFinite && position.speed >= 0 ? position.speed : 0.0;

    final validHeading = position.heading.isFinite &&
        position.heading >= 0 &&
        position.heading < 360;

    return NavigationData(
      latitude: position.latitude,
      longitude: position.longitude,
      speedInKnots: MarineUnits.msToKnots(rawSpeed),
      speedMs: rawSpeed,
      heading: validHeading ? position.heading : 0.0,
      headingIsValid: validHeading,
      accuracy: position.accuracy,
      altitude: position.altitude,
      timestamp: position.timestamp,
    );
  }

  /// Évite d'utiliser un relevé GPS trop ancien.
  bool get hasFreshPosition {
    final age = DateTime.now().difference(timestamp);
    return age >= const Duration(seconds: -5) &&
        age <= const Duration(seconds: 15);
  }

  /// Le COG n'est exploitable que si le bateau avance,
  /// que le cap est valide et que le relevé GPS est récent.
  bool get hasValidCourse =>
      hasFreshPosition &&
      headingIsValid &&
      speedInKnots >= 0.5 &&
      heading.isFinite &&
      heading >= 0 &&
      heading < 360;

  GpsSignalStatus get signalStatus {
    if (accuracy <= 5) return GpsSignalStatus.excellent;
    if (accuracy <= 10) return GpsSignalStatus.good;
    if (accuracy <= 20) return GpsSignalStatus.fair;
    return GpsSignalStatus.poor;
  }
}
