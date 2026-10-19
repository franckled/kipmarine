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
    final validAccuracy =
        position.accuracy.isFinite && position.accuracy >= 0
            ? position.accuracy
            : double.infinity;
    final validLatitude = position.latitude.isFinite &&
        position.latitude >= -90 &&
        position.latitude <= 90;
    final validLongitude = position.longitude.isFinite &&
        position.longitude >= -180 &&
        position.longitude <= 180;

    return NavigationData(
      latitude: validLatitude ? position.latitude : 0.0,
      longitude: validLongitude ? position.longitude : 0.0,
      speedInKnots: MarineUnits.msToKnots(rawSpeed),
      speedMs: rawSpeed,
      heading: validHeading ? position.heading : 0.0,
      headingIsValid: validHeading,
      accuracy: validAccuracy,
      altitude: position.altitude.isFinite ? position.altitude : 0.0,
      timestamp: position.timestamp,
    );
  }

  /// Vrai uniquement si le relevé est récent et ses coordonnées valides.
  bool get hasFreshPosition {
    final age = DateTime.now().difference(timestamp);
    return age >= const Duration(seconds: -5) &&
        age <= const Duration(seconds: 15) &&
        latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180 &&
        accuracy.isFinite &&
        accuracy >= 0;
  }

  /// Le COG est pertinent si le relevé est récent et le bateau avance.
  bool get hasValidCourse =>
      hasFreshPosition &&
      headingIsValid &&
      speedInKnots >= 0.5 &&
      heading.isFinite &&
      heading >= 0 &&
      heading < 360;

  /// Qualité du dernier relevé; « perdu » signifie que le relevé n'est plus frais.
  GpsSignalStatus get signalStatus {
    if (!hasFreshPosition) return GpsSignalStatus.lost;
    if (accuracy <= 5) return GpsSignalStatus.excellent;
    if (accuracy <= 10) return GpsSignalStatus.good;
    if (accuracy <= 20) return GpsSignalStatus.fair;
    return GpsSignalStatus.poor;
  }
}
