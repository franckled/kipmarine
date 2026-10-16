import 'dart:math';

class MarineUnits {
  /// Convertit les m/s (GPS natif) en Nœuds (kn)
  static double msToKnots(double ms) => ms * 1.94384;

  /// Convertit les mètres en Milles Nautiques (NM)
  static double metersToNauticalMiles(double meters) => meters / 1852.0;

  /// Calcule la distance exacte en mètres entre deux coordonnées GPS
  static double haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000.0; // Rayon de la Terre en mètres
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degree) => degree * pi / 180.0;
}
