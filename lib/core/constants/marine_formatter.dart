class MarineFormatter {
  /// Convertit une latitude décimale en format marin (ex: 42° 38.452' N)
  static String formatLatitude(double latitude) {
    final latDir = latitude >= 0 ? 'N' : 'S';
    final absLat = latitude.abs();
    final degrees = absLat.floor();
    final minutes = (absLat - degrees) * 60;
    return "$degrees° ${minutes.toStringAsFixed(3)}' $latDir";
  }

  /// Convertit une longitude décimale en format marin (ex: 009° 15.120' E)
  static String formatLongitude(double longitude) {
    final lonDir = longitude >= 0 ? 'E' : 'W';
    final absLon = longitude.abs();
    final degrees = absLon.floor().toString().padLeft(3, '0');
    final minutes = (absLon - absLon.floor()) * 60;
    return "$degrees° ${minutes.toStringAsFixed(3)}' $lonDir";
  }

  /// Formate le cap (COG) sur 3 chiffres (ex: 045°)
  static String formatHeading(double heading) {
    final rounded = heading.round() % 360;
    return "${rounded.toString().padLeft(3, '0')}°";
  }
}
